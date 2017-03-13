function [returns] = bktPatterns(closePrices, BestPatternArr, meanPerformanceArr, stdPerformanceArr, trendPerformanceArr, minSimilarity)

[~,patternLength] = size(BestPatternArr);

cost = 3;

ntrades = 0;

tic

for i = (patternLength+1):length(closePrices)
    
    pattern=nan(patternLength,1);
    
    for y = 1:patternLength
        pattern(y) = percentChange(closePrices(i-patternLength),closePrices(i-patternLength+y));
    end
    
    [meanPatReturn, stdPat, ~] = patternRecognition(pattern', BestPatternArr, meanPerformanceArr, stdPerformanceArr, trendPerformanceArr, minSimilarity);
    
    if abs(meanPatReturn) > 0
        
        segnoOperazione = sign(meanPatReturn);
        ntrades = ntrades + 1;
        
        Pbuy = closePrices(i);
        
        TakeP = min(stdPat,50);
        StopL = min(stdPat,50);
        TakeProfitPrice = Pbuy + segnoOperazione * TakeP;
        StopLossPrice =  Pbuy - segnoOperazione * StopL;
        
        for j = i:length(closePrices)
            
            condTP = ( sign( closePrices(j) - TakeProfitPrice ) * segnoOperazione );
            condSL = ( sign( StopLossPrice - closePrices(j) ) ) * segnoOperazione;
            
            if ( condTP >=0 ) || ( condSL >= 0 )
                
                returns(ntrades) = (closePrices(j)-Pbuy)*segnoOperazione - cost;
                
                i = j;
                
                break
                
            end
            
            i = j;      
   
        end
        
    end
    
    
end

figure
plot(cumsum(returns))

toc

end
