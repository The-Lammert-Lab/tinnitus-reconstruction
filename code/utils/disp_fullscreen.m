% ### disp_fullscreen
% 
% Expand current figure to full screen and fill with an image.
% 
% **ARGUMENTS:**
% 
%   - img: `n x m x 3` array representing an 
%       image. Typically loaded via imread().
%   - hFig: handle to figure. 
%       Defaults to current figure.
% 
% **OUTPUTS:**
% 
%   - hFig now displays an image.

function disp_fullscreen(img, hFig)
    arguments
        img (:,:,3)
        hFig matlab.ui.Figure = gcf
    end

    screenSize = get(0, 'ScreenSize');
    screenWidth = screenSize(3);
    screenHeight = screenSize(4);

    % Open full screen figure if none provided or the provided was deleted
    hFig.Position = [0 0 screenWidth screenHeight];

    clf(hFig);
    fpos = get(hFig,'Position');
    axOffset = (fpos(3:4)-[size(img,2) size(img,1)])/2;
    ha = axes('Parent',hFig,'Units','pixels', ...
                'Position',[axOffset size(img,2) size(img,1)]);
    imshow(img,'Parent',ha);
end