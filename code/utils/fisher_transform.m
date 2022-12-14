function y = fisher_transform(x)
    y = (1/2) * log((1 + x) ./ (1 - x));
end