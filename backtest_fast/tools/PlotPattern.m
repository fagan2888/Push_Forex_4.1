function [] = PlotPattern(patternArr, performanceArr, numPat, quantiplot, plotme, meanPatFound, closePrices)


figure
plot(patternArr(numPat,:),'LineWidth',2)
hold on
%                 plot(patternLength+5,performanceArr(numPat),'*','MarkerSize',10)

for j=1:quantiplot
    plot(patternArr(plotme(j),:))
    %                     plot(patternLength+5,performanceArr(plotme(j)),'o','MarkerSize',7)
end


figure
histogram(performanceArr(plotme),10)


figure
plot(1,meanPatFound,'*','MarkerSize',10)
hold on
for j=1:quantiplot
    plot(j+1,performanceArr(plotme(j)),'o','MarkerSize',7)
end

figure
plot(closePrices)
hold on
for j=1:quantiplot
    plot(plotme(j):plotme(j)+9,closePrices(plotme(j):plotme(j)+9),'r')
end




end