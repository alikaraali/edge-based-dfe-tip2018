function g = g1y(x,y,s1)

s1sq = s1.^2;
g = -(y./(2*pi*s1sq.^2)) .* exp(-(x.^2 + y.^2)./(2*s1sq)); 
