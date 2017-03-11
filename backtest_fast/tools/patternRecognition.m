function [meanPatReturn] = patternRecognition(pattern, BestPatternArr, meanPerformanceArr, minSimilarity)

    [numberOfPatterns,patternLength] = size(BestPatternArr);
    meanPatReturn = 0;

    for numPat=1:numberOfPatterns
        
        howSim = sum( 100.00 - abs(percentChange(BestPatternArr(numPat,:),pattern)) ) / patternLength;
        
        if howSim > minSimilarity
            
            meanPatReturn = meanPerformanceArr(numPat);
            break
            
        end
        
    end

end