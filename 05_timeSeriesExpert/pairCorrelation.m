function [XCF,lags,bounds] = pairCorrelation (smoothingFactors, numLags)

histName1 = 'C:\Users\alericci\Desktop\Forex_nonShared\historical\EURUSD_1m_01062016_04112016_2.csv';
histName2 = 'C:\Users\alericci\Desktop\Forex_nonShared\historical\AUDCAD_1m_01072016_11112016_2.csv';

dateStart = '07/05/2016 00:00';
dateStop  = '11/01/2016 00:00';
timeZoneShift = 0;
nData = 1;
actTimeScale = 1;
newTimeScale = 1440;

[~, histData1] = load_historical_03(histName1, dateStart, dateStop, timeZoneShift, nData, actTimeScale, newTimeScale);
[~, histData2] = load_historical_03(histName2, dateStart, dateStop, timeZoneShift, nData, actTimeScale, newTimeScale);
data1 = diff(histData1(:,4));
data2 = diff(histData2(:,4));

% for testing (peak at lag = 36)
%
% MdlY1 = arima('AR',0.3,'Constant',2,'Variance',1);
% T = 1000;
% data1 = simulate(MdlY1,T);
% data2 = [randn(36,1);data1(1:end-36)+randn(T-36,1)*0.1];

l1 = length (data1);
l2 = length (data2);
l  = min(l1,l2);

n = length(smoothingFactors);
XCF    = zeros((numLags*2)+1,n);
lags   = zeros((numLags*2)+1,n);
bounds = zeros(n,2);

for i = 1: n
    factor = smoothingFactors(i);
    smooth1 = (1/smoothingFactors(i))*ones(1,factor);
    smooth2 = (1/smoothingFactors(i))*ones(1,factor);
    
    histDataSmooth1(:,i) = filter(smooth1,1,data1(1:l));
    histDataSmooth2(:,i) = filter(smooth2,1,data2(1:l));
    [singleXCF,singleLags,singleBounds] = crosscorr(histDataSmooth1(:,i),histDataSmooth2(:,i),numLags,3);
    
    XCF(:,i)    = singleXCF;
    lags(:,i)   = singleLags;
    bounds(i,:) = singleBounds;
    
    plot(lags(:,i),XCF(:,i),'-k'); hold on    
end

figure
subplot(2,1,1)
plot (histDataSmooth1(smoothingFactors(end):end,end),'-r')
hold on
plot (histDataSmooth2(smoothingFactors(end):end,end),'-b')
subplot(2,1,2)
plot (histDataSmooth1(smoothingFactors(1):end,1),'-r')
hold on
plot (histDataSmooth2(smoothingFactors(1):end,1),'-b')

