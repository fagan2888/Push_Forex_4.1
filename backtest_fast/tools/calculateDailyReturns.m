function [dailyReturns] = calculateDailyReturns( indexClose, returns, actTimeScale, newTimeScale, sizeStoricoActTime)

numberOfDays = ceil(sizeStoricoActTime*actTimeScale/3600 - 100*newTimeScale/3600);
dailyReturns = zeros(numberOfDays,1);

dailyIndex = ceil(indexClose.*newTimeScale/3600);

for i = 1:length(indexClose)
    
    dailyReturns(dailyIndex(i)) = dailyReturns(dailyIndex(i)) + returns(dailyIndex(i));
    
    
end


end