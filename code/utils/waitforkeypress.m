% ### waitforkeypress
% 
% Wait for a keypress, ignoring mouse clicks.
% Returns 1 when a key is pressed.
% Returns -1 when the function encounters an error
% which usually happens when the figure is deleted.
% 
% **ARGUMENTS:**
% 
%   - verbose: `bool`, default: true
% 
% **OUTPUTS:**
% 
%   - k: `1 x 1` scalar,
%       `1` when a key is pressed, `-1` if an error occurs

function k = waitforkeypress(verbose)
    arguments
        verbose (1,1) {mustBeNumericOrLogical} = true
    end

    k = 0;
    while k == 0
        try
            k = waitforbuttonpress;
        catch
            corelib.verb(verbose, 'INFO waitforkeypress', 'waitforkeypress exited unexpectedly.')
            k = -1;
            return
        end
    end
end % function
