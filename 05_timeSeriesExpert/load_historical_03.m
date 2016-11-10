function [HistData_1min, HistData_freq] = load_historical_03(histName, dateStart, dateStop, timeZoneShift, nData, actTimeScale, newTimeScale)

%%%%%%%%%%%%%%%%%%
% load a historical file and creates matrices of historical at the original and new time scales
% the output columns are (op,hi,lo,cl,vol,date)
% if the file does not contain date, will add a
% fake date column as the last (6th) column
%
% IMPORTANT, please use:
% [HistData_1min,HistData_freq]=fromMT4HystToBktHistorical(actTimeScale,newTimeScale)
% for converting the dowloaded historical data from MT4 to the bkt historical
% standard!
%%%%%%%%%%%%%%%%%%

hisDataRaw = load(histName);

% remove lines with no data (holes)
histData      = hisDataRaw( (hisDataRaw(:,1) ~=0), : );
histData(:,6) = histData(:,6) + (timeZoneShift/24);
dateLastNum   = histData(end,6);
dateLast      = datestr(dateLastNum, 'mm/dd/yyyy HH:MM');
dateFirstNum  = histData(1,6) + ((nData*newTimeScale)/(60*24));
dateFirst     = datestr(dateFirstNum, 'mm/dd/yyyy HH:MM');


[r,c] = size(histData);

if c == 5
    
    histData(1,6) = datenum('01/01/2015 00:00', 'mm/dd/yyyy HH:MM');
    
    for j = 2:r;
        
        histData(j,6) = histData(1,6) + ( (actTimeScale/1440)*(j-1) );
        
    end
    
end


if (dateStart == 0)
    if (dateStop == 0)
        histDataSelected = histData;
    else
        dateStartNum = histData(1,6);
        dateStopNum  = datenum(dateStop, 'mm/dd/yyyy HH:MM');  
        if dateStopNum > dateLastNum
            message = strcat('please indicate a dateStop within:',{' '},dateLast,{' '},...
                'or provide a longer historical. PLEASE: consider you have a timeZoneShift:',{' '},num2str(timeZoneShift));
            h = msgbox(message,'WARN','warn');
            waitfor(h)
            return
        end
        [indexSelected] = find ((histData(:,6) >= dateStartNum) & (histData(:,6) <= dateStopNum));
        histDataSelected = histData(indexSelected, :);
    end
else
    if (dateStop == 0)
        dateStartNum = datenum(dateStart, 'mm/dd/yyyy HH:MM');
        dateStopNum  = histData(end,6);
        if dateStartNum < dateFirstNum
            message = strcat('please indicate a dateStart after:',{' '},dateFirst,{' '},...
                'or provide an older historical. PLEASE: consider you have a timeZoneShift:',{' '},num2str(timeZoneShift),...
                {' '},'and nData:',{' '},num2str(nData));
            h = msgbox(message,'WARN','warn');
            waitfor(h)
            return
        end
        [indexSelected] = find ((histData(:,6) >= dateStartNum) & (histData(:,6) <= dateStopNum));
        histDataSelected = histData((indexSelected(1) - (nData*newTimeScale)):indexSelected(end), :);
    else
        dateStartNum = datenum(dateStart, 'mm/dd/yyyy HH:MM');
        dateStopNum  = datenum(dateStop, 'mm/dd/yyyy HH:MM');
        if dateStopNum > dateLastNum
            message = strcat('please indicate a dateStop within:',{' '},dateLast,{' '},...
                'or provide a longer historical. PLEASE: consider you have a timeZoneShift:',{' '},num2str(timeZoneShift));
            h = msgbox(message,'WARN','warn');
            waitfor(h)
            return
        elseif dateStartNum < dateFirstNum
            message = strcat('please indicate a dateStart after:',{' '},dateFirst,{' '},...
                'or provide an older historical. PLEASE: consider you have a timeZoneShift:',{' '},num2str(timeZoneShift),...
                {' '},'and nData:',{' '},num2str(nData));
            h = msgbox(message,'WARN','warn');
            waitfor(h)
            return
        end
        [indexSelected] = find ((histData(:,6) >= dateStartNum) & (histData(:,6) <= dateStopNum));
        histDataSelected = histData((indexSelected(1) - (nData*newTimeScale)):indexSelected(end), :);
    end
end
HistData_1min = histDataSelected;


% rescale data if requested
if newTimeScale > 1
    
    expert = TimeSeriesExpert_11;
    
    expert.rescaleData(histDataSelected,actTimeScale,newTimeScale);
    
    HistData_freq(:,1) = expert.openVrescaled;
    HistData_freq(:,2) = expert.maxVrescaled;
    HistData_freq(:,3) = expert.minVrescaled;
    HistData_freq(:,4) = expert.closeVrescaled;
    HistData_freq(:,5) = expert.volrescaled;
    HistData_freq(:,6) = expert.openDrescaled;
    
else
    HistData_freq = histDataSelected;
end

end



