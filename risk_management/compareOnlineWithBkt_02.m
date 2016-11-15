
function [OperationsOnline,OperationsBkt,PerformanceOnline,PerformanceBkt,HistData_1min,HistData_freq]=compareOnlineWithBkt_02(FullnameOrServername,histDataFormat,parameters)

%
% DESCRIPTION:
% -------------------------------------------------------------
% This function compares the perfromance of a specified Algo obtained by
% the DEMO system the BKT or REAL. If the historical is not in the Standard format 
% the function reformats it and saves it on the same name.
% Before to running it modify the Algo parameter file please.
% 
% WARNINGS:
% -------------------------------------------------------------
% 1) DO NOT SAVE THE HISTORICAL DATA INTO A FOLDER WITH A
% NAME CONTAINING SPACES and DOTS !!!!
% 2) please set in parameters: calcPerformance = 0; calcPerDistribution = 0; !!!
% 
% INPUT parameters:
% -------------------------------------------------------------
% FullnameOrServername  ... the name of the server origin for dowloading the operations executed by the Algo: 'ServerTest' or
%                           'ServerProd' or the path of the dowloaded '../operations.csv'
% parameters            ... parameter file containing all the information of the specified Algo and the historical data for the BKT 
%                           
% OUTPUT parameters:
% -------------------------------------------------------------
% OperationsOnline      ... operations performed by the Algo online
% OperationsBkt         ... operations performed by the Algo in BKT
% PerformanceOnline     ... performance of the Algo calculated on OperationsOnline
% PerformanceBkt        ... performance of the Algo calculated on OperationsBkt
% HistData_1min         ... historical data at 1 min (actTimeScale)
% HistData_freq         ... historical data at the newTimeScale
%
% EXAMPLE of use:
% -------------------------------------------------------------
% [OperationsOnline,OperationsBkt,PerformanceOnline,PerformanceBkt,HistData_1min,HistData_freq]=compareOnlineWithBkt_02('ServerTest','standard','parameters_Offline_Algo_100804_invertedSupertrend_EURUSD.txt');
%

if strcmp(histDataFormat,'standard')
    c=1;
elseif strcmp(histDataFormat,'MT4')
    c=2;
else
    h=msgbox('please indicate as histDataFormat: standard or MT4','WARN','warn');
    waitfor(h)
    return
end

fid=fopen(parameters);
C = textscan(fid, '%s', 'Delimiter', '', 'CommentStyle', '%');
fclose(fid);
cellfun(@eval, C{1});


% --------- start function ----------- %
switch c
    case 1
        display('Historical Data with standard format');
    case 2
        display('Historical Data with MT4 format ... reformatting');
        [~,~] = fromMT4HystToBktHistorical_02(actTimeScale,newTimeScale,histName);
end

bkt_Algo = bktOffline_02;
bkt_Algo = bkt_Algo.spin(parameters);
HistData_1min = bkt_Algo.starthisData;
HistData_freq = bkt_Algo.newHisData;
OperationsBkt = bkt_Algo.outputBktOffline;

dateFirstNum  = HistData_1min(1,6);
dateLastNum   = HistData_1min(end,6);
[OperationsOnline]=fromWebOperToMatrix_03(AlgoMagicNumber,dateFirstNum,dateLastNum,newTimeScale,FullnameOrServername);

PerformanceBkt = Performance_08;
PerformanceBkt = PerformanceBkt.calcSinglePerformance('BKT',parameters,OperationsBkt);
PerformanceOnline = Performance_08;
PerformanceOnline = PerformanceOnline.calcSinglePerformance('DEMO',parameters,OperationsOnline);


% --------- plot results ----------- %
figure
subplot(2,1,1)
plot(OperationsBkt(:,8),cumsum(PerformanceBkt.netReturns_pips),'-ob');
hold on
plot(OperationsOnline(:,8),cumsum(PerformanceOnline.netReturns_pips),'-or');
ylabel('cumulative Profit and Loss');
h_legend=legend('bkt','online');
set(h_legend,'FontSize',18);
title (AlgoMagicNumber,'FontSize',20)
subplot(2,1,2)
plot(OperationsBkt(:,8),PerformanceBkt.netReturns_pips,'-ob');
hold on
plot(OperationsOnline(:,8),PerformanceOnline.netReturns_pips,'-or');
ylabel('single operation Profit and Loss ');
h_legend=legend('bkt','online');
set(h_legend,'FontSize',18);

% 


% fileID = fopen('scan1.dat');
% dates = textscan(fileID,'%s %*[^\n]');
% fclose(fileID);
% dates{1}

% try 
%    D = datenum(Inpt,'dd mmm yyyy HH:MM:SS.FFF')
% catch
%    error('Incorrect Format')
% end



% DateStart = '09/19/2016 19:30';
% FullnameOrServername = 'C:\Users\alericci\Desktop\Forex 4.0 noShared\test exe\1002\serverTest_19102016.csv';
% Histfilename = 'EURUSD_01082016_Algo1002';
% Histfiledir = 'C:\Users\alericci\Desktop\Forex 4.0 noShared\performance comparison\19102016\';
% HistFullname  = strcat(Histfiledir, Histfilename,'.csv');

% date_1002_online(:,1)=cellstr(datestr(Algo1002_19082016_19102016(:,7), 'mm/dd/yyyy HH:MM'));
% date_1002_online(:,2)=cellstr(datestr(Algo1002_19082016_19102016(:,8), 'mm/dd/yyyy HH:MM'));
% date_1002_bkt(:,2)=cellstr(datestr(bkt_Algo_1002.outputBktOffline(:,8), 'mm/dd/yyyy HH:MM'));
% date_1002_bkt(:,1)=cellstr(datestr(bkt_Algo_1002.outputBktOffline(:,7), 'mm/dd/yyyy HH:MM'));
% d30=datestr(HistData_freq(:,6), 'mm/dd/yyyy HH:MM');
% d30str = cellstr(d30)

% [OnlineOperations]=fromWebPageToMatrix_02(100804,30,'ServerTest');
%
% Algo1002_19082016_19102016=Algo1002_19102016(77:end,:);

% P1002=Performance_07;
% P1002=P1002.calcComparedPerformance('Algo1002','bktWeb','demo','EURUSD',30,1,0,10000,10,bkt_Algo_1002.outputBktOffline,Algo1002_01082016_19102016,1);
% plot(bkt_Algo_1002.outputBktOffline(:,7),cumsum(bkt_Algo_1002.performance.netReturns_pips(:,1)),'-ob');
% hold on
% plot(Algo1002_01082016_19102016(:,7),cumsum(Algo1002_01082016_19102016(:,4)),'-or');