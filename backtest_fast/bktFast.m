classdef bktFast < handle
    
    %%%%%%%%%%%%%%%%
    %%% use it like this:
    % fast = bktFast;
    % fast = fast.optimize('parameters_file.txt')
    %
    %%% or to simply check that an algo it's working:
    %
    % test = bktFast;
    % test = test.tryme('parameters_file.txt')
    %
    %%% or to compare results:
    %
    % test = bktFast;
    % test.plotme('parameters_file.txt')
    %
    %%%%%%%%%%%%%%%%
    
    
    properties
        R_over_maxDD
        bktfastTraining
        performanceTraining
        bktfastPaperTrading
        performancePaperTrad
        bktfastTry
        performanceTry
        
    end
    
    methods
        
        %%%%%%%%%
        
        function [obj] = optimize(obj,parameters)
            
            % DESCRIPTION:
            % -------------------------------------------------------------
            % Performs the optimization of the specified algorithm on given historical data
            %
            % INPUT parameters:
            % -------------------------------------------------------------
            % nameAlgo:                 string containing the name of the algo (your MATLAB function)
            % N:                        first optimization (use array!!!) -> lag,slowly varying
            % M:                        second optimization (use array or put = 1 !!!) -> lead,highly varying
            % N_greater_than_M:         if = 1 then skip loops where n<=m (required in some algo with smoothing)
            % Cross:                    e.g. 'EURUSD'
            % histName:                 filename containing hist prices, e.g. : 'nome_storico.csv'
            % actTimeScale:             timescale of the hist data, in minutes
            % newTimeScale:             new timescale to work with (rescale)
            % transCost:                spread in pips
            % pips_TP:                  max TP
            % pips_SL:                  max allowed SL
            % stdev_TP:                 stdev(volatility) for calculating TP
            % stdev_SL:                 stdev(volatility) for calculating SL
            % WhatToPlot:               what do you want to plot:
            %                              0: nothing
            %                              1: returns of optimized algo(training and papertrading)
            %                              2: + sweepPlot of training
            %                              3: + performance
            % -------------------------------------------------------------
            
            
            %% Import parameters:
            
            fid=fopen(parameters);
            C = textscan(fid, '%s', 'Delimiter', '', 'CommentStyle', '%');
            fclose(fid);
            cellfun(@eval, C{1});
            
            
            algo = str2func(nameAlgo);
            
            
            %% Load, check, and split historical
            
            [hisData, newHisData] = load_historical(histName, actTimeScale, newTimeScale);
            
            [r,~] = size(hisData);
            %[rn,~] = size(newHisData);
            
            if ( exist('reverse_optimization','var') && reverse_optimization == 1 )
                
                % split historical and perform optimization on the MOST RECENT HISTORICAL DATA!!!!
                % default for reverse_optimization: 50% Training, 50% paper trading)
                rTraining = floor(r*0.5);
                rnTraining = floor(rTraining/newTimeScale);
                
                hisDataTraining = hisData(rTraining+1:end,:);
                hisDataPaperTrad = hisData(1:rTraining,:);
                newHisDataTraining = newHisData(rnTraining+1:end,:);
                newHisDataPaperTrad = newHisData(1:rnTraining,:);
                
            else % standard way!
                
                % split historical into trainging set for optimization and paper trading
                % default: 75% Training, 25% paper trading)
                rTraining = floor(r*0.75);
                rnTraining = floor(rTraining/newTimeScale);
                
                % use this to skip some of the very old hist data:
                %             skipMe = floor(r*0.20);
                %             skipMeNewTime = floor(skipMe/newTimeScale);
                %             hisDataTraining = hisData(skipMe:rTraining,:);
                %             newHisDataTraining = newHisData(skipMeNewTime:rnTraining,:);
                
                hisDataTraining = hisData(1:rTraining,:);
                hisDataPaperTrad = hisData(rTraining+1:end,:);
                newHisDataTraining = newHisData(1:rnTraining,:);
                newHisDataPaperTrad = newHisData(rnTraining+1:end,:);
                
            end
            
            %% Perform optimization using training set
            
            matrixsize = max([ N M ]);
            obj.R_over_maxDD = nan(matrixsize);
            index_scatterplot = 1; % used later for scatter plot
            
            tic
            
            for n = N
                
                display(['n =', num2str(n)]);
                
                
                for m = M
                    
                    if( N_greater_than_M && n<=m )
                        continue
                    end
                    
                    %display(['  m =', num2str(m)]);
                    
                    bktfast = feval(algo);
                    %                       spin(            Pmin,           matrixNewTimeScale, actTimeScale, newTimeScale, N, M, transCost, pips_TP, pips_SL, stdev_TP,stdev_SL, plot)
                    bktfast = bktfast.spin(hisDataTraining(:,4), newHisDataTraining, actTimeScale, newTimeScale, n, m, transCost, pips_TP, pips_SL, stdev_TP, stdev_SL, 0);
                    
                    % if there are enough operations then save the stats
                    if bktfast.indexClose>20
                        
                        p = Performance_06;
                        performance = p.calcSinglePerformance(nameAlgo,'bktWeb',histName,Cross,newTimeScale,transCost,10000,10,bktfast.outputbkt,0);
                        
                        obj.R_over_maxDD(n,m) = performance.pipsEarned / abs(performance.maxDD_pips);
                        
                    end
                    
                end
                
                
                % display partial results of optimization
                [current_best,ind_best] = max(obj.R_over_maxDD(n,:));
                
                % perform paper trading and show results only if R/maxDD is decent
                if max(obj.R_over_maxDD(n,:)) > 0.8
                    
                    temp_Training = feval(algo);
                    temp_Training = temp_Training.spin(hisDataTraining(:,4), newHisDataTraining, actTimeScale, newTimeScale, n, ind_best, transCost, pips_TP, pips_SL, stdev_TP, stdev_SL, 0);
                    
                    if temp_Training.indexClose>20
                        performance_temp_Training = p.calcSinglePerformance(nameAlgo,'bktWeb',histName,Cross,newTimeScale,transCost,10000,10,temp_Training.outputbkt,0);
                        
                        avgPipsOperTraining = performance_temp_Training.pipsEarned/temp_Training.indexClose;
                        display(['Train: best R/maxDD= ' , num2str(current_best),'. Avg pips/operat= ',num2str(avgPipsOperTraining),'.  N =', num2str(n),' M =', num2str(ind_best) ]);
                        display(['num operations =', num2str(temp_Training.indexClose) ,', pips earned =', num2str(performance_temp_Training.pipsEarned)]);
                        
                        % try paper trading on partial result and display some numbers
                        
                        temp_paperTrad = feval(algo);
                        temp_paperTrad = temp_paperTrad.spin(hisDataPaperTrad(:,4), newHisDataPaperTrad, actTimeScale, newTimeScale, n, ind_best, transCost, pips_TP, pips_SL, stdev_TP, stdev_SL, 0);
                        performance_temp = p.calcSinglePerformance(nameAlgo,'bktWeb',histName,Cross,newTimeScale,transCost,10000,10,temp_paperTrad.outputbkt,0);
                        
                        avgPipsOperPaperTrad= performance_temp.pipsEarned/temp_paperTrad.indexClose;
                        risultato_temp = performance_temp.pipsEarned / abs(performance_temp.maxDD_pips) ;
                        display(['Papertrad: R/maxDD = ', num2str(risultato_temp),'. Avg pips/operat= ',num2str(avgPipsOperPaperTrad)]);
                        display(['num operations =', num2str(temp_paperTrad.indexClose) ,', pips earned =', num2str(performance_temp.pipsEarned) ]);
                        
                        % store results of training and paper trad for this run used for scatter plot
                        myscatterplot(index_scatterplot,1) = current_best;
                        myscatterplot(index_scatterplot,2) = risultato_temp;
                        myscatterplot(index_scatterplot,3) = avgPipsOperTraining;
                        myscatterplot(index_scatterplot,4) = avgPipsOperPaperTrad;
                        index_scatterplot = index_scatterplot + 1;
                        
                        
                        %plot if it is good:
                        if risultato_temp > 1.0 && WhatToPlot > 1
                            
                            
                            figure
                            subplot(1,2,1);
                            plot(cumsum(temp_Training.outputbkt(:,4).*temp_Training.outputbkt(:,6) - transCost))
                            title(['Temp Training, ', 'N =', num2str(n),' M =', num2str(ind_best) ,'. R/maxDD = ',num2str( current_best) ])
                            hold on
                            subplot(1,2,2);
                            plot(cumsum(temp_paperTrad.outputbkt(:,4).*temp_paperTrad.outputbkt(:,6) - transCost))
                            title(['Temp Paper Trading, ', 'N =', num2str(n),' M =', num2str(ind_best) ,'. R/maxDD = ',num2str( risultato_temp) ])
                            
                        end
                        
                    end
                    
                end
                
            end
            
            hold off
            
            toc
            
            if WhatToPlot > 1
                
                temp=obj.R_over_maxDD;
                temp(isnan( temp) )=0;
                sweepPlot_BKT_Fast(temp)
                
                figure
                contour(temp)
                grid on
                colorbar
                
                figure
                scatter(myscatterplot(:,1), myscatterplot(:,2),'filled');
                hold on
                refline(1,0)
                xlabel('training')
                ylabel('paper trading')
                title('R/maxDD')
                
                figure
                scatter(myscatterplot(:,3), myscatterplot(:,4),'filled');
                hold on
                refline(1,0)
                xlabel('training')
                ylabel('paper trading')
                title('Average pips/operation')
                
            end
            
            %% display results of training
            
            [~, bestInd] = max(obj.R_over_maxDD(:)); % (Linear) location of max value
            [bestN, bestM] = ind2sub(matrixsize, bestInd); % Lead and lag at best value
            
            display(['bestN =', num2str(bestN),' bestM =', num2str(bestM)]);
            
            obj.bktfastTraining = feval(algo);
            obj.bktfastTraining = obj.bktfastTraining.spin(hisDataTraining(:,4), newHisDataTraining, actTimeScale, newTimeScale, bestN, bestM, transCost, pips_TP, pips_SL, stdev_TP, stdev_SL, 0);
            
            p = Performance_06;
            obj.performanceTraining = p.calcSinglePerformance(nameAlgo,'bktWeb',histName,Cross,newTimeScale,transCost,10000,10,obj.bktfastTraining.outputbkt,0);
            
            risultato = obj.performanceTraining.pipsEarned / abs(obj.performanceTraining.maxDD_pips);
            
            if WhatToPlot > 0
                
                figure
                plot(cumsum(obj.bktfastTraining.outputbkt(:,4).*obj.bktfastTraining.outputbkt(:,6) - transCost))
                title(['Training Best Result, Final R over maxDD = ',num2str( risultato) ])
                
            end
            
            
            %% perform paper trading
            
            obj.bktfastPaperTrading = feval(algo);
            obj.bktfastPaperTrading = obj.bktfastPaperTrading.spin(hisDataPaperTrad(:,4), newHisDataPaperTrad, actTimeScale, newTimeScale, bestN, bestM, transCost, pips_TP, pips_SL, stdev_TP, stdev_SL, 0);
            
            obj.performancePaperTrad = p.calcSinglePerformance(nameAlgo,'bktWeb',histName,Cross,newTimeScale,transCost,10000,10,obj.bktfastPaperTrading.outputbkt,0);
            risultato = obj.performancePaperTrad.pipsEarned / abs(obj.performancePaperTrad.maxDD_pips);
            
            if WhatToPlot > 0
                
                figure
                plot(cumsum(obj.bktfastPaperTrading.outputbkt(:,4).*obj.bktfastPaperTrading.outputbkt(:,6) - transCost))
                title(['Paper Trading Result, Final R over maxDD = ',num2str( risultato) ])
                
            end
            
            
            
        end % end function optimize
        
        
        
        %%%%%%%%%
        
        function [obj] = tryme(obj,parameters)
            
            % DESCRIPTION:
            % -------------------------------------------------------------
            % Performs simple run of the specified algorithm on given historical data
            %
            %
            % How to use it:
            %
            % test = bktFast;
            % test = test.tryme('parameters_file.txt')
            %
            % -------------------------------------------------------------
            
            
            %% Import parameters:
            
            fid=fopen(parameters);
            C = textscan(fid, '%s', 'Delimiter', '', 'CommentStyle', '%');
            fclose(fid);
            cellfun(@eval, C{1});
            
            
            algo = str2func(nameAlgo);
            
            
            %% Load and check historical
            
            [hisData, newHisData] = load_historical(histName, actTimeScale, newTimeScale);
            
            % check that M or N are no array
            if (size(M,2)>1 || size(N,2)>1 )
                
                M=M(end);
                N=N(end);
                
            end
            
            
            %% perform try
            
            obj.bktfastTry = feval(algo);
            obj.bktfastTry = obj.bktfastTry.spin(hisData(:,4), newHisData, actTimeScale, newTimeScale, N, M, transCost, pips_TP, pips_SL, stdev_TP, stdev_SL, 0);
            
            p = Performance_06;
            obj.performanceTry = p.calcSinglePerformance(nameAlgo,'bktWeb',histName,Cross,newTimeScale,transCost,10000,10,obj.bktfastTry.outputbkt,1);
            risultato = obj.performanceTry.pipsEarned / abs(obj.performanceTry.maxDD_pips);
            
            if WhatToPlot > 0
                
                figure
                plot(cumsum(obj.bktfastTry.outputbkt(:,4).*obj.bktfastTry.outputbkt(:,6) - transCost))
                title(['Result, Final R over maxDD = ',num2str( risultato) ])
                
                % it is not possible to use this as long as there is
                % hurst etc to calculate...
                %                 pD = PerformanceDistribution_04;
                %                 obj.performanceDistribution = pD.calcPerformanceDistr(nameAlgo,'bktWeb',Cross,N,newTimeScale,transCost,obj.bktfastTry.outputbkt,0,hisData,newHisData,15,10,10,4);
                %
                %
            end
            
            
        end % end of function tryme
        
        
        function [obj] = plotme(obj,parameters)
            
            % DESCRIPTION:
            % -------------------------------------------------------------
            % Performs simple run of the specified algorithm on given historical data
            % and compare result overplotting them on a single plot
            %
            %
            % How to use it:
            %
            % test = bktFast;
            % test = test.plotme('parameters_file.txt')
            %
            % -------------------------------------------------------------
            
            
            %% Import parameters:
            
            fid=fopen(parameters);
            C = textscan(fid, '%s', 'Delimiter', '', 'CommentStyle', '%');
            fclose(fid);
            cellfun(@eval, C{1});
            
            
            algo = str2func(nameAlgo);
            
            
            %% Load and check historical
            
            [hisData, newHisData] = load_historical(histName, actTimeScale, newTimeScale);
            
            figure
            hold on
            
            Legend = cell( length(N), 1);
            LegNum=1;
            
            for i=1:length(N);
                
                n=N(i);
                m=M(i);
                
                
                display(['n =', num2str(n)]);
                
                
                
                if( N_greater_than_M && n<=m )
                    continue
                end
                
                obj.bktfastTry = feval(algo);
                obj.bktfastTry = obj.bktfastTry.spin(hisData(:,4), newHisData, actTimeScale, newTimeScale, n, m, transCost, pips_TP, pips_SL, stdev_TP, stdev_SL, 0);
                
                %                     subpl(LegNum) = subplot( size(N,2), size(M,2), LegNum );
                plot(cumsum(obj.bktfastTry.outputbkt(:,4).*obj.bktfastTry.outputbkt(:,6) - transCost),'color',rand(1,3))
                Legend{LegNum}=strcat( num2str(n),'-',num2str(m) );
                LegNum= LegNum+1;
                
                
            end
            
            %             linkaxes(subpl,'y')
            legend(Legend)
            title('Cumulative Results of various trials')
            
        end % end of function plotme
        
        
        
        function [obj] = shakeme(obj,parameters)
            
            % DESCRIPTION:
            % -------------------------------------------------------------
            % Performs runs of the specified algorithm on a perturbed historical data
            % and compare results overplotting them on a single plot
            %
            %
            % How to use it:
            %
            % test = bktFast;
            % test = test.shakeme('parameters_file.txt')
            %
            % -------------------------------------------------------------
            
            
            %% Import parameters:
            
            fid=fopen(parameters);
            C = textscan(fid, '%s', 'Delimiter', '', 'CommentStyle', '%');
            fclose(fid);
            cellfun(@eval, C{1});
            
            
            algo = str2func(nameAlgo);
            
            figure
            hold on
            
            stepStrength = 0:0.2:1;
            Legend = cell( length(6), 1); % dev'esser lungo come i cicli di strength
            LegNum=1;
            
            i = 1;
            RoverMaxDD = zeros(6,1);
            numOperations = zeros(6,1);
            pipsEarned = zeros(6,1);
            avgPipsOper = zeros(6,1);
            
            for strength = stepStrength
                
                % Load and perturb historica
                [hisDataNoise, newHisDataNoise] = load_historical_and_add_noise(histName, actTimeScale, newTimeScale,strength);
                
                display(['strength =', num2str(strength)]);
                
                
                if( N_greater_than_M && n<=m )
                    continue
                end
                
                obj.bktfastTry = feval(algo);
                obj.bktfastTry = obj.bktfastTry.spin(hisDataNoise(:,4), newHisDataNoise, actTimeScale, newTimeScale, N, M, transCost, pips_TP, pips_SL, stdev_TP, stdev_SL, 0);
                
                p = Performance_06;
                performance = p.calcSinglePerformance(nameAlgo,'bktWeb',histName,Cross,newTimeScale,transCost,10000,10,obj.bktfastTry.outputbkt,0);
                
                % save results
                RoverMaxDD(i) = performance.pipsEarned / abs(performance.maxDD_pips);
                numOperations(i) = obj.bktfastTry.indexClose;
                pipsEarned(i) = performance.pipsEarned;
                avgPipsOper(i) = pipsEarned(i)/numOperations(i);
                i = i+1;
                
                % plot profits together
                plot(cumsum(obj.bktfastTry.outputbkt(:,4).*obj.bktfastTry.outputbkt(:,6) - transCost),'color',rand(1,3))
                Legend{LegNum}=num2str(strength);
                LegNum= LegNum+1;
                
                
                legend(Legend)
                title('Cumulative Results of various trials with different historical perturbations')
                
            end
            
            % plot metrics for comparison:
            figure
            subplot(2,2,1);
            scatter(stepStrength,RoverMaxDD,'filled')
            title('R/maxDD')
            hold on
            subplot(2,2,2);
            scatter(stepStrength,numOperations,'filled')
            title('num Operations')
            subplot(2,2,3);
            scatter(stepStrength,pipsEarned,'filled')
            title('pips Earned')
            subplot(2,2,4);
            scatter(stepStrength,avgPipsOper,'filled')
            title('avg Pips per Operaz')
            
            
            
        end % end of function shakeme
        
    end % end of methods
    
end % end of classdef