function [x] = percentChange(startPoint, currentPoint)

x = ( ( double(currentPoint)-startPoint ) ./ abs(startPoint) ) *100;

if x == 0.0
    x = x + 0.000000001;
end

end