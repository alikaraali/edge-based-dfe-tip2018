function g = g1x(x,y,s1)

s1sq = s1.^2;
g = -(x./(2*pi*s1sq.^2)) .* exp(-(x.^2 + y.^2)./(2*s1sq)); 
