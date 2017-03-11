
function [patternArr, performanceArr, trendArr] = patternStorage(closePrices, patternLength)

x = length(closePrices)-3*patternLength;

patternArr = nan(50000,patternLength);
performanceArr = nan(50000,1);
trendArr = nan(50000,1);
numPatterns = 1;

tic

for y = 1:x
    
    pattern=nan(patternLength,1);
    
    for i = 1:patternLength
        pattern(i) = percentChange(closePrices(y),closePrices(y+i));
    end
    
    outcomeRange = closePrices(y+patternLength+5:y+patternLength+10);
    currentPoint = closePrices(y+patternLength);
    signedOutcomeRange = sign(closePrices(y+patternLength+5:y+patternLength+10) - currentPoint); % array col segno rispetto all'ultimo punto del pattern
        
    avgOutcome = mean(outcomeRange);
    SignOutcome = sum(signedOutcomeRange);   % la "forza" del trend e' proporzionale al num di punti considerati
%     futureOutcome = percentChange(currentPoint, avgOutcome);
    futureOutcome = avgOutcome - currentPoint;
    
    patternArr(numPatterns,:) = pattern;
    performanceArr(numPatterns) = futureOutcome;
    trendArr(numPatterns) = SignOutcome;
    numPatterns = numPatterns + 1;
    
end

    % rimuovi righe se ne hai preallocate troppe
    patternArr(all(isnan(patternArr),2),:) = [];
    performanceArr(all(isnan(performanceArr),2),:) = [];
    trendArr(all(isnan(trendArr),2),:) = [];

    display(['length of pattern array: ' num2str(size(patternArr,1)) ])
    display(['length of performance array (the same): ' num2str(size(performanceArr,1)) ])
    display(['length of trend array (the same): ' num2str(size(trendArr,1)) ])
    toc

end
