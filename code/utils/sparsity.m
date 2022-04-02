function k = sparsity(A)
    k = nnz(A) / numel(A);
end