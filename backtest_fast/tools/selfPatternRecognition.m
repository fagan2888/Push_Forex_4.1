function [BestPatternArr, meanPerformanceArr] = selfPatternRecognition(patternArr, performanceArr, minSimilarity,minMeanPips)

[numberOfPatterns,patternLength] = size(patternArr);
howSim = nan(numberOfPatterns,1);

meanPatFound = nan(numberOfPatterns,1);
% stdPatFound = nan(numberOfPatterns,1);
% freqPatFound = nan(numberOfPatterns,1);
BestPatternArr = nan(numberOfPatterns,patternLength);
meanPerformanceArr = nan(numberOfPatterns,1);
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
%         stdPatFound = std(performanceArr(plotme));
%         freqPatFound = quantiPatterns;

%         disp(['mean: ', num2str( meanPatFound(ipat)), ...
%             ' std: ', num2str(stdPatFound(ipat)), ...
%             ' frequency: ', num2str(freqPatFound(ipat)) ])

        if abs(meanPatFound) > minMeanPips

            BestPatternArr(ipat,:) = patternArr(numPat,:);
            meanPerformanceArr(ipat,1) = meanPatFound;
            ipat = ipat + 1;
        
        end
    end
end

% meanPatFound(all(isnan(meanPatFound),2),:) = [];
% stdPatFound(all(isnan(stdPatFound),2),:) = [];
% freqPatFound(all(isnan(freqPatFound),2),:) = [];
BestPatternArr(all(isnan(BestPatternArr),2),:) = [];
meanPerformanceArr(all(isnan(meanPerformanceArr),2),:) = [];


end