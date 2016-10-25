
function [OperationsOnline,OperationsBkt,PerformanceOnline,PerformanceBkt,HistData_1min,HistData_freq]=compareOnlineWithBkt

AlgoMagicNumber = 100804;
AlgoName = strcat('Algo','_',num2str(AlgoMagicNumber));
cross =  'EURUSD';
histName = 'MT4';
transCost = 1;
initialStack = 10000;
leverage = 10;
actTimeScale = 1;
newTimeScale = 30;
% DateStart = '09/19/2016 19:30';
% FullnameOrServername = 'C:\Users\alericci\Desktop\Forex 4.0 noShared\test exe\1002\serverTest_19102016.csv';
FullnameOrServername = 'ServerTest';
Histfilename = 'EURUSD_01082016_Algo1002';
Histfiledir = 'C:\Users\alericci\Desktop\Forex 4.0 noShared\performance comparison\19102016\';
HistFullname  = strcat(Histfiledir, Histfilename,'.csv');
AlgoParamsFile = 'parameters_Offline_Algo_100804_invertedSupertrend_EURUSD.txt';
plotPerformance = 1;


% --------- start function ----------- %
[OperationsOnline]=fromWebPageToMatrix_02(AlgoMagicNumber,newTimeScale,FullnameOrServername);

[HistData_1min,HistData_freq]=fromMT4HystToBktHistorical_02(actTimeScale,newTimeScale,HistFullname);

bkt_Algo = bktOffline_02;
bkt_Algo = bkt_Algo.spin(AlgoParamsFile);
OperationsBkt = bkt_Algo.outputBktOffline;

PerformanceBkt = Performance_07;
PerformanceBkt = PerformanceBkt.calcSinglePerformance(AlgoName,'bktWeb',histName,cross,newTimeScale,transCost,initialStack,leverage,OperationsBkt,plotPerformance);
PerformanceOnline = Performance_07;
PerformanceOnline = PerformanceOnline.calcSinglePerformance(AlgoName,'demo',histName,cross,newTimeScale,0,initialStack,leverage,OperationsOnline,plotPerformance);


% 
% 
%date_1002_online(:,1)=cellstr(datestr(Algo1002_19082016_19102016(:,7), 'mm/dd/yyyy HH:MM'));
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