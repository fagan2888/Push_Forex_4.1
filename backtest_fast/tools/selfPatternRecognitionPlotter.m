function [meanPatFound,stdPatFound,trendPatFound, freqPatFound] = selfPatternRecognitionPlotter(patternArr, performanceArr, trendArr, minSimilarity, closePrices)

[numberOfPatterns,patternLength] = size(patternArr);
howSim = nan(numberOfPatterns,1);

meanPatFound = nan(numberOfPatterns,1);
stdPatFound = nan(numberOfPatterns,1);
freqPatFound = nan(numberOfPatterns,1);
trendPatFound = nan(numberOfPatterns,1);
ipat = 1;

for numPat=1:numberOfPatterns
    
    clear plotme
    quantiplot = 0;
    
    for i=numPat+1:numberOfPatterns
        
        howSim(numPat) = sum( 100.00 - abs(percentChange(patternArr(numPat,:),patternArr(i,:))) ) / patternLength;
        
        if howSim(numPat) > minSimilarity
            
            quantiplot=quantiplot+1;
            plotme(quantiplot) = i;
            %             figure
            %             plot(patternArr(numPat,:))
            %             hold on
            %             plot(patternArr(i,:))
            %
            %             disp('Press a key !')
            %             pause;
            
        end
        
    end
    
    if quantiplot>50
        
        meanPatFound(ipat) = meanNoWings(performanceArr(plotme),5); % uso meanNoWings per escludere il 5% delle code nel calcolare la media
        stdPatFound(ipat) = std(performanceArr(plotme));
        freqPatFound(ipat)   = quantiplot;
        trendPatFound(ipat)  = sum( abs(trendArr(plotme))>4 ) / quantiplot; % non mi convince xe non tiene conto del segno di ciascun trend
        dummyTrendUp = sum( trendArr(plotme)>4 ) / quantiplot;
        dummyTrendDown = sum( trendArr(plotme)<-4 ) / quantiplot;
        
        if ( dummyTrendUp > 0.45 || dummyTrendDown > 0.45 )
            
            disp(['mean: ', num2str( meanPatFound(ipat)), ...
                ' std: ', num2str(stdPatFound(ipat)), ...
                ' frequency: ', num2str(freqPatFound(ipat)), ...
                ' trend power: ', num2str(trendPatFound(ipat)) ])
            disp([ 'trend Up: ', num2str(dummyTrendUp), ...
                ' trend Down: ', num2str(dummyTrendDown) ])
            
            PlotPattern(patternArr, performanceArr, numPat, quantiplot, plotme, meanPatFound(ipat),closePrices)
            
            disp('Press a key !')
            pause;
            
        end
        
        ipat = ipat + 1;
    end
end

meanPatFound(all(isnan(meanPatFound),2),:) = [];
stdPatFound(all(isnan(stdPatFound),2),:) = [];
freqPatFound(all(isnan(freqPatFound),2),:) = [];
trendPatFound(all(isnan(trendPatFound),2),:) = [];

end