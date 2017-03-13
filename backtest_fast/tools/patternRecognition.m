function [meanPatReturn, stdPat, trendPat] = patternRecognition(pattern, BestPatternArr, meanPerformanceArr, stdPerformanceArr, trendPerformanceArr, minSimilarity)

    [numberOfPatterns,patternLength] = size(BestPatternArr);
    meanPatReturn = 0;
    stdPat = 0;
    trendPat = 0;

    for numPat=1:numberOfPatterns
        
        howSim = sum( 100.00 - abs(percentChange(BestPatternArr(numPat,:),pattern)) ) / patternLength;
        
        if howSim > minSimilarity
            
            meanPatReturn = meanPerformanceArr(numPat);
            stdPat = stdPerformanceArr(numPat);
            trendPat = trendPerformanceArr(numPat);
            break
            
        end
        
    end

end