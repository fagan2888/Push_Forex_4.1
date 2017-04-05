function [meanPatReturn, stdPat, trendPat] = patternRecognitionCompare(NewPatternArr, NewPerformanceArr, BestPatternArr, meanPerformanceArr, stdPerformanceArr, minSimilarity)

% questa serve se hai gia' un array di pattern selezionati e vuoi
% confrontar i ritorni medi con quelli di un nuovo storico

[numberOfPatterns,patternLength] = size(BestPatternArr);
[numberOfNewPatterns,newPatternLength] = size(NewPatternArr);

% condizione: se patternLength~=newPatternLength incazzati

indiceNumNewPat = nan(10,1);

ipat = 0;
meanPatReturn = nan(10,2);
stdPat = nan(10,2);
trendPat = nan(10,2);

for numPat=1:numberOfPatterns
    
    quantiPatterns = 0;
    
    for numNewPat=1:numberOfNewPatterns
        
        howSim = sum( 100.00 - abs(percentChange(BestPatternArr(numPat,:),NewPatternArr(numNewPat,:))) ) / patternLength;
        
        if howSim > minSimilarity
            
            quantiPatterns=quantiPatterns+1;
            indiceNumNewPat(quantiPatterns) = numNewPat;
            
        end
        
    end
    
    if quantiPatterns > 20
        
        ipat = ipat + 1;
        meanPatFound = mean(NewPerformanceArr(indiceNumNewPat));
        stdPatFound = std(NewPerformanceArr(indiceNumNewPat));
        %         freqPatFound = quantiPatterns;
        
        meanPatReturn(ipat,1) = meanPatFound;
        stdPat(ipat,1) = stdPatFound;
        meanPatReturn(ipat,2) = meanPerformanceArr(numPat);
        stdPat(ipat,2) = stdPerformanceArr(numPat);
    end
    
end

end