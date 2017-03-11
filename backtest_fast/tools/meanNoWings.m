function [res] = meanNoWings(array, percentile)

myarray = sort(array);
numToTrim = floor( percentile/100*length(array) );

res = mean( myarray(1+numToTrim:end-numToTrim) );


end