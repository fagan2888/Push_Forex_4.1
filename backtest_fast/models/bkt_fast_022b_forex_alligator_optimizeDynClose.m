classdef bkt_fast_022b_forex_alligator_optimizeDynClose < handle
    
    % bktfast VERSION 4 (with apri_dopo)
    
    properties
        
        outputbkt;
        trades;
        direction;
        chei;
        r;
        openingPrices;
        OpDates;
        indexOpen;
        closingPrices;
        ClDates;
        indexClose;
        latency;
        arrayAperture;
        minimumReturns;
        
    end
    
    
    methods
        
        function obj = spin(obj, Pminute, matrixNewHisData, ~, newTimeScale, dyn2, M, cost, ~, ~, wTP, wSL, plottami)
            
            % Pminute = prezzo al minuto
            % P = prezzo alla new time scale
            % date = data alla new time scale
            % cost = spread per operazione (calcolato quando chiudi)
            % M = periodi su cui calcolare la volatility del TP e SL
            % I tre smooth lo considero sempre di 5, 8, 31 periodi
            % in piu' ho aggiunto una scala "jolly" di 100 periodi

            
            
            %% opera se le derivate di min e max sono allineate (indica un trend)
            
            op = matrixNewHisData(:,1);
            hi = matrixNewHisData(:,2);
            lo = matrixNewHisData(:,3);
            P = matrixNewHisData(:,4);
            date = matrixNewHisData(:,6);
            
            sizeStorico = size(matrixNewHisData,1);
            
            %             pandl = zeros(sizeStorico,1);
            obj.trades = zeros(sizeStorico,1);
            obj.chei=zeros(sizeStorico,1);
            obj.openingPrices=zeros(sizeStorico,1);
            obj.closingPrices=zeros(sizeStorico,1);
            obj.direction=zeros(sizeStorico,1);
            obj.OpDates=zeros(sizeStorico,1);
            obj.ClDates=zeros(sizeStorico,1);
            obj.r =zeros(sizeStorico,1);
            obj.latency= zeros(sizeStorico,1);
            obj.arrayAperture= zeros(sizeStorico,1);
            obj.minimumReturns = zeros(sizeStorico,1);
            
            ntrades = 0;
            obj.indexClose = 0;
            
            % queste sono le tre linee smoothed
            a = (1/5)*ones(1,5);
            SmoothCinque = filter(a,1,P);
            diffCinque = sign( [0 ; diff(SmoothCinque)] );
            
            aa = (1/8)*ones(1,8);
            SmoothOtto = filter(aa,1,P);
            diffOtto = sign( [0 ; diff(SmoothOtto)] );
            
            aaa = (1/31)*ones(1,31);
            SmoothTredici = filter(aaa,1,P);
            diffTredici = sign( [0 ; diff(SmoothTredici)] );
            
            aaaa = (1/99)*ones(1,99);
            SmoothJolly = filter(aaaa,1,P);
            diffJolly = sign( [0 ; diff(SmoothJolly)] );
            
            b = (1/M)*ones(1,M);
            lag = filter(b,1,P);
            fluctuationslag=abs(P-lag);
            
            % il segnale c'e' se le tre linee sono concordi
            s = diffCinque + diffOtto + diffTredici + diffJolly;
            s(abs(s)~=4) = 0;
            s = sign(s);
            
            i = 101;
            indexMin=0;
            
            
            while i < sizeStorico
                
                % se c'e' un pattern doji o engulfing in accordo col segnale e il pattern avviene dentro le medie mobili, apri
                % questo e' doji:
                if   ( abs(s(i)) && P(i-1)==op(i-1) && ( sign(P(i-1)- SmoothCinque(i-1)) == -s(i-1) || sign(P(i-1)- SmoothOtto(i-1)) == -s(i-1) || sign(P(i-1)- SmoothTredici(i-1)) == -s(i-1) ) && s(i)==s(i-1) )
                    
                    segnoOperazione = s(i);
                    
                    ntrades = ntrades + 1;
                    obj.arrayAperture(ntrades)=i;
                    [obj, Pbuy, devFluct2 ] = obj.apri(i, P, fluctuationslag, M, ntrades, segnoOperazione, date);
%                     [obj, Pbuy, i, indexMin, devFluct2] = apri_dopo(obj, i, Pminute, newTimeScale, fluctuationslag, M, ntrades, segnoOperazione, date);
                    
                    volatility = min(floor(wTP*devFluct2),50);
                    TakeP = volatility;
                    StopL = volatility;
                    TakeProfitPrice = Pbuy + segnoOperazione * TakeP;
                    StopLossPrice =  Pbuy - segnoOperazione * StopL;
                    %
                    %                     display(['Pbuy =' num2str(Pbuy)]);
                    %                     display(['Noper=' num2str(ntrades), 'volatility=' num2str(volatility)]);
                    %                     display(['segnoOperazione =' num2str(segnoOperazione)]);
                    %                     display(['TakeProfitPrice =' num2str(TakeProfitPrice)]);
                    %                     display(['StopLossPrice =' num2str(StopLossPrice)]);
                    %
                    for j = (newTimeScale*(i)+indexMin):length(Pminute)
                        
                        indice_I = floor(j/newTimeScale);
                        
                        %%%%%%%%%%% dynamicalTPandSL
                        
                                                dynamicParameters {1} = 1;
                                                dynamicParameters {2} = 1+ 0.1*dyn2;
                                                [TakeProfitPrice,StopLossPrice,TakeP,StopL,~] = closingShrinkingBands(Pbuy,Pminute(j),segnoOperazione,TakeP,StopL, 0, dynamicParameters);
%                                                  display(['TP =', num2str(TakeP),' SL =', num2str(StopL)]);
%                                                  display(['StopLossPrice =', num2str(StopLossPrice)]);
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        condTP = ( sign( Pminute(j) - TakeProfitPrice ) * segnoOperazione );
                        condSL = ( sign( StopLossPrice - Pminute(j) ) ) * segnoOperazione;
                        
                        if ( condTP >=0 ) || ( condSL >= 0 )
                            
                            obj.r(indice_I) = (Pminute(j)-Pbuy)*segnoOperazione - cost;
                            obj.closingPrices(ntrades) = Pminute(j);
                            obj.minimumReturns(ntrades)=calculate_min_return(Pbuy, Pminute(newTimeScale*i:j), segnoOperazione);
                            obj.ClDates(ntrades) = date(indice_I); %controlla
                            i = indice_I;
                            obj.chei(ntrades)=i;
                            obj.indexClose = obj.indexClose + 1;
                            obj.latency(ntrades)=j - newTimeScale*obj.indexOpen;
                            
                            %                             display( '---------------------' );
                            break
                            
                        end
                        
                        i = indice_I;
                        obj.trades(i) = 1;
                        
                    end
                    
                end
                
                i = i + 1;
                
            end
            
            %             pandl = cumsum(r);
            %             sh = pandl(end);
            %
            %
            %             cumprof= cumsum(r(r~=0))*10;
            %             profittofinale = sum(r);
            %
            
            obj.outputbkt(:,1) = obj.chei(1:obj.indexClose);                    % index of stick
            obj.outputbkt(:,2) = obj.openingPrices(1:obj.indexClose);      % opening price
            obj.outputbkt(:,3) = obj.closingPrices(1:obj.indexClose);        % closing price
            obj.outputbkt(:,4) = (obj.closingPrices(1:obj.indexClose) - ...
                obj.openingPrices(1:obj.indexClose)).*obj.direction(1:obj.indexClose);   % returns
            obj.outputbkt(:,5) = obj.direction(1:obj.indexClose);              % direction
            obj.outputbkt(:,6) = ones(obj.indexClose,1);                    % real
            obj.outputbkt(:,7) = obj.OpDates(1:obj.indexClose);              % opening date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
            obj.outputbkt(:,8) = obj.ClDates(1:obj.indexClose);                % closing date in day to convert use: d2=datestr(outputDemo(:,2), 'mm/dd/yyyy HH:MM')
            obj.outputbkt(:,9) = ones(obj.indexClose,1)*1;                 % lots setted for single operation
            obj.outputbkt(:,10) = obj.latency(1:obj.indexClose);        % number of minutes the operation was open
            obj.outputbkt(:,11) = obj.minimumReturns(1:obj.indexClose,1);      % minimum return touched during dingle operation
            
            obj.latency = obj.latency(1:obj.indexClose);
            obj.arrayAperture = obj.arrayAperture(1:obj.indexClose);
            
            obj.direction=obj.direction(1:obj.indexClose);
            
            % Plot a richiesta
            if plottami
                
                figure
                ax(1) = subplot(2,1,1);
                plot(P), grid on
                hold on
                plot(mid,'black')
                plot(uppr, 'red')
                plot(lowr,'red')
                legend('Price','mid','upper','lower')
                title(['Bollinger con lookperiod ',num2str(N)])
                ax(2) = subplot(2,1,2);
                plot(cumsum(obj.outputbkt(:,4))), grid on
                legend('Cumulative Return')
                title('Cumulative Returns ')
                %linkaxes(ax,'x')
                
            end %if
            
        end
        
        
        function [obj, Pbuy, devFluct2] = apri(obj, i, P, fluctuationslag, M, ntrades, segnoOperazione, date)
            
            obj.trades(i) = 1;
            Pbuy = P(i);
            %devFluct2 = 1; % lo impongo sempre uguale a 1
            devFluct2 = std(fluctuationslag((i-(100-M)):i));
            obj.direction(ntrades)= segnoOperazione;
            obj.openingPrices(ntrades) = Pbuy;
            obj.OpDates(ntrades) = date(i);
            obj.indexOpen = i;
            
        end
        
        
        function [obj, Pbuy, i, indexMin, devFluct2] = apri_dopo(obj, i, Pminute, newTimeScale, fluctuationslag, M, ntrades, segnoOperazione, date)
            
            % questa funzione non apre subito ma vede prima se il prezzo al
            % minuto segue il segnale di apertura o no. Se non lo segue
            % aspetta prima di aprire che il prezzo sia in linea con il segnale
            
            %P_trigger = P(i);
            
            for ii = (newTimeScale*(i)+1):length(Pminute) % parto dal minuto dopo il segnale
                
                i = floor(ii/newTimeScale);
                
                if sign( Pminute(ii) - Pminute(ii-1)- 1*segnoOperazione ) == segnoOperazione
                    
                    obj.trades(i) = 1;
                    Pbuy = Pminute(ii);
                    %devFluct2 = 1; % lo impongo sempre uguale a 1
                    devFluct2 = std(fluctuationslag((i-(100-M)):i));
                    obj.direction(ntrades)= segnoOperazione;
                    obj.openingPrices(ntrades) = Pbuy;
                    obj.OpDates(ntrades) = date(i);
                    obj.indexOpen = i;
                    indexMin = ii - newTimeScale*i;
                    
                    break
                    
                end
                
            end
            
        end
        
        
        %         function [obj] = chiudi_per_SL(obj, Pbuy, indice_I, segnoOperazione, devFluct2, wSL, cost, ntrades, date)
        %
        %             obj.r(indice_I) = - wSL*devFluct2 - cost;
        %             obj.closingPrices(ntrades) = Pbuy - segnoOperazione*floor(wSL*devFluct2);
        %             obj.ClDates(ntrades) = date(indice_I); %controlla
        %
        %         end
        %
        %         function [obj] = chiudi_per_TP(obj, Pbuy, indice_I, segnoOperazione, devFluct2, wTP, cost, ntrades, date)
        %
        %             obj.r(indice_I) = wTP*devFluct2 - cost;
        %             obj.closingPrices(ntrades) = Pbuy + segnoOperazione*floor(wTP*devFluct2);
        %             obj.ClDates(ntrades) = date(indice_I); %controlla
        %
        %         end
        
        
    end
    
    
end
