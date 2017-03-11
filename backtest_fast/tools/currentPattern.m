function [pattern] = currentPattern(closePrices, patternLength)
    
    pattern = nan(patternLength,1);

    for i = 1:patternLength
        pattern(i) = percentChange(closePrices(1),closePrices(1+i));
    end
    
end