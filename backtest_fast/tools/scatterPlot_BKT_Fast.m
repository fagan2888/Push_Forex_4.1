function scatterPlot_BKT_Fast(xdata, ydata, titlePlot)
%
% plotta scatter plot con linea y=x di guida per vedere se training e paper
% trading sono simili o se c'e' un possibile overfitting

c = linspace(1,10,length(xdata));

figure

scatter(xdata, ydata,[],c,'filled');

hold on

refline(1,0)

xlabel('training')
ylabel('paper trading')
title(titlePlot)

