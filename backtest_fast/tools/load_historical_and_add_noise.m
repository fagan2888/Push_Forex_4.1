function [hisData, newHisData] = load_historical_and_add_noise(histName, actTimeScale, newTimeScale,randomStrength)

%%%%%%%%%%%%%%%%%%
% load a historical file and creates matrices of historical at the original
% and new time scales with random noise proportional to the average
% volatility of the period (centered at the data point considered, i.e. not
% the historical volatility!!). Suggested randomStrength btw 1 and 2
% the output columns are (op,hi,lo,cl,vol,date)
% if the file has dates in the first column, will delete them and add a
% fake date column as the last (6th) column
%
%%%%%%%%%%%%%%%%%%


            hisDataRaw=load(histName);
            
            % remove lines with no data (holes)
            hisDataTemp = hisDataRaw( (hisDataRaw(:,1) ~=0), : );
            
            [r,c] = size(hisDataTemp);
            
            %remove badly loaded dates (will add fake dates in a sec)
            if c ~= 5
                hisData = hisDataTemp(:,c-4:c);
            else
                hisData = hisDataTemp;
            end
            
            hisData(1,6) = datenum('01/01/2015 00:00', 'mm/dd/yyyy HH:MM');
            
            for j = 2:r;
                hisData(j,6) = hisData(1,6) + ( (actTimeScale/1440)*(j-1) );
            end
            
            volatility_open = min( movingstd(hisData(:,1),10,'central') , 10 );
            volatility_max = min( movingstd(hisData(:,2),10,'central') , 10);
            volatility_min = min( movingstd(hisData(:,3),10,'central') , 10);
            volatility_close = min( movingstd(hisData(:,4),10,'central') , 10);
            volatility_vol = movingstd(hisData(:,5),10,'central');
            
            %randomvec = 2*rand(size(hisData(:,1))) - 1;
            randomvec = randn(size(hisData(:,1))) ;
            
            hisData(:,1) = hisData(:,1) + floor(randomvec .* (randomStrength * volatility_open) );
            hisData(:,2) = hisData(:,2) + floor(randomvec .* (randomStrength * volatility_max));
            hisData(:,3) = hisData(:,3) + floor(randomvec .* (randomStrength * volatility_min) );
            hisData(:,4) = hisData(:,4) + floor(randomvec .* (randomStrength * volatility_close) );
            hisData(:,5) = hisData(:,5) + floor(randomvec .* (randomStrength * volatility_vol) );
            
            
            % rescale data if requested
            if newTimeScale > 1
                
                expert = TimeSeriesExpert_11;
                
                expert.rescaleData(hisData,actTimeScale,newTimeScale);
                
                newHisData(:,1) = expert.openVrescaled;
                newHisData(:,2) = expert.maxVrescaled;
                newHisData(:,3) = expert.minVrescaled;
                newHisData(:,4) = expert.closeVrescaled;
                newHisData(:,5) = expert.volrescaled;
                newHisData(:,6) = expert.openDrescaled;
             
            else
                newHisData = hisData;
            end
            
end