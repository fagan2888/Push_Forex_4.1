function [BestPatternArr, meanPerformanceArr, stdPerformanceArr, trendPerformanceArr] = selfPatternRecognition(patternArr, performanceArr, trendArr, minSimilarity,minMeanPips)

[numberOfPatterns,patternLength] = size(patternArr);
howSim = nan(numberOfPatterns,1);

meanPatFound = nan(numberOfPatterns,1);
stdPatFound = nan(numberOfPatterns,1);
% freqPatFound = nan(numberOfPatterns,1);
trendPatFound = nan(numberOfPatterns,1);
BestPatternArr = nan(numberOfPatterns,patternLength);
meanPerformanceArr = nan(numberOfPatterns,1);
stdPerformanceArr = nan(numberOfPatterns,1);
trendPerformanceArr = nan(numberOfPatterns,1);
ipat = 1;

for numPat=1:numberOfPatterns
    
    quantiPatterns = 0;
    clear plotme
    
    for i=numPat+1:numberOfPatterns
        
        howSim(numPat) = sum( 100.00 - abs(percentChange(patternArr(numPat,:),patternArr(i,:))) ) / patternLength;
        
        if howSim(numPat) > minSimilarity
            
            quantiPatterns=quantiPatterns+1;
            plotme(quantiPatterns) = i;
            
        end
        
    end
    
    if quantiPatterns > 50
        
        meanPatFound = mean(performanceArr(plotme));
        stdPatFound = std(performanceArr(plotme));
        %         freqPatFound = quantiPatterns;
        
        dummyTrendUp = sum( trendArr(plotme)>4 ) / quantiPatterns;
        dummyTrendDown = sum( trendArr(plotme)<-4 ) / quantiPatterns;
        
        if ( dummyTrendUp > 0.45)
            
            trendPatFound(ipat)  = dummyTrendUp;
            
            if abs(meanPatFound) > minMeanPips
                
                BestPatternArr(ipat,:) = patternArr(numPat,:);
                meanPerformanceArr(ipat,1) = meanPatFound;
                stdPerformanceArr(ipat,1) = stdPatFound;
                trendPerformanceArr(ipat,1) = trendPatFound(ipat);
                ipat = ipat + 1;
                
            end
            
        elseif (dummyTrendDown > 0.45 )
            
            trendPatFound(ipat)  = dummyTrendDown;
            
            
            if abs(meanPatFound) > minMeanPips
                
                BestPatternArr(ipat,:) = patternArr(numPat,:);
                meanPerformanceArr(ipat,1) = meanPatFound;
                stdPerformanceArr(ipat,1) = stdPatFound;
                trendPerformanceArr(ipat,1) = trendPatFound(ipat);
                ipat = ipat + 1;
                
            end
            
        end
        
    end
    
end

% meanPatFound(all(isnan(meanPatFound),2),:) = [];
% stdPatFound(all(isnan(stdPatFound),2),:) = [];
% freqPatFound(all(isnan(freqPatFound),2),:) = [];
BestPatternArr(all(isnan(BestPatternArr),2),:) = [];
meanPerformanceArr(all(isnan(meanPerformanceArr),2),:) = [];
stdPerformanceArr(all(isnan(stdPerformanceArr),2),:) = [];
trendPerformanceArr(all(isnan(trendPerformanceArr),2),:) = [];

end