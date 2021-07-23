function m = hz2mels(f)

m = 2595.*log10(1+(f./700));

return
%eof