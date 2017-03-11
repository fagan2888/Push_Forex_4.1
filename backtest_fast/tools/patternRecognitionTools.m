[~, newHisData] = load_historical('EURUSD_smallsample2014_2015.csv', 1, 30);

[patternArr, performanceArr] = patternStorage(newHisData(:,4), 30);

[pattern] = currentPattern(newHisData(1:30,4), 30);

patternRecognition(patternArr,pattern);