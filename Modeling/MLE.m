function out = MLE(x)

if x <=1 || x>=0
    out = 4368*x^5*(1-x)^11;
else
    out = inf;
end