
function [OperationsOnline,OperationsBkt,PerformanceOnline,PerformanceBkt,HistData_1min,HistData_freq]=compareOnlineWithBkt(FullnameOrServername,parameters)

%
% DESCRIPTION:
% -------------------------------------------------------------
% This function compares the perfromance of a specified Algo obtained by
% the DEMO system the BKT or REAL.
% Before to running it modify the Algo parameter file please.
% 
% WARNINGS:
% -------------------------------------------------------------
% % DO NOT SAVE THE HISTORICAL DATA INTO A FOLDER WITH A
% NAME CONTAINING SPACES and DOTS !!!!
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
% [OperationsOnline,OperationsBkt,PerformanceOnline,PerformanceBkt,HistData_1min,HistData_freq]=compareOnlineWithBkt('ServerTest','parameters_Offline_Algo_100804_invertedSupertrend_EURUSD.txt')
%

fid=fopen(parameters);
C = textscan(fid, '%s', 'Delimiter', '', 'CommentStyle', '%');
fclose(fid);
cellfun(@eval, C{1});


% --------- start function ----------- %
[OperationsOnline]=fromWebPageToMatrix_02(AlgoMagicNumber,newTimeScale,FullnameOrServername);

[HistData_1min,HistData_freq]=fromMT4HystToBktHistorical_02(actTimeScale,newTimeScale,histName);

bkt_Algo = bktOffline_02;
bkt_Algo = bkt_Algo.spin(parameters);
OperationsBkt = bkt_Algo.outputBktOffline;

PerformanceBkt = Performance_08;
PerformanceBkt = PerformanceBkt.calcSinglePerformance('BKT',parameters,OperationsBkt);
PerformanceOnline = Performance_08;
PerformanceOnline = PerformanceOnline.calcSinglePerformance('DEMO',parameters,OperationsOnline);



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