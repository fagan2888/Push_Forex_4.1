
function [inputResultsMatrix2_]=compareOnlineWithBkt ();

AlgoMagicNumber = 100502;
newTimeScale = 30;
startingDate = '07/04/2015 15:00';
Fullname = 'C:\Users\alericci\Desktop\Forex 4.0 noShared\test exe\1002\serverTest_19102016.csv';

% bkt_Algo_002=bktOffline_02;
% bkt_Algo_002=bkt_Algo_002.spin('parameters_Offline_Algo_002.txt');

[inputResultsMatrix2_]=fromWebPageToMatrix(AlgoMagicNumber,newTimeScale, Fullname);

% [HistData_1min,HistData_freq]=fromMT4HystToBktHistorical(actTimeScale,newTimeScale)
% 
% Algo1002_19082016_19102016=Algo1002_19102016(77:end,:);
% P1002=Performance_07;
% P1002=P1002.calcComparedPerformance('Algo1002','bktWeb','demo','EURUSD',30,1,0,10000,10,bkt_Algo_1002.outputBktOffline,Algo1002_19082016_19102016,1);
% 
% 
% 
% 
% 
%date_1002_online(:,1)=cellstr(datestr(Algo1002_19082016_19102016(:,7), 'mm/dd/yyyy HH:MM'));
% date_1002_online(:,2)=cellstr(datestr(Algo1002_19082016_19102016(:,8), 'mm/dd/yyyy HH:MM'));
% date_1002_bkt(:,2)=cellstr(datestr(bkt_Algo_1002.outputBktOffline(:,8), 'mm/dd/yyyy HH:MM'));
% date_1002_bkt(:,1)=cellstr(datestr(bkt_Algo_1002.outputBktOffline(:,7), 'mm/dd/yyyy HH:MM'));
% d30=datestr(HistData_freq(:,6), 'mm/dd/yyyy HH:MM');
% d30str = cellstr(d30)


% P1002=Performance_07;
% P1002=P1002.calcComparedPerformance('Algo1002','bktWeb','demo','EURUSD',30,1,0,10000,10,bkt_Algo_1002.outputBktOffline,Algo1002_01082016_19102016,1);
% plot(bkt_Algo_1002.outputBktOffline(:,7),cumsum(bkt_Algo_1002.performance.netReturns_pips(:,1)),'-ob');
% hold on
% plot(Algo1002_01082016_19102016(:,7),cumsum(Algo1002_01082016_19102016(:,4)),'-or');