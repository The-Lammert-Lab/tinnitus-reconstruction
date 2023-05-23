% ### disp_fullscreen
% 
% Fill full screen figure with new image.
% 
% **ARGUMENTS:**
% 
%   - img: image loaded via imread()
%   - hFig: handle to maximized figure. 
%       Defaults to current figure handle.
% 
% **OUTPUTS:**
% 
%   - hFig now displays an image.

function disp_fullscreen(img, hFig)
    arguments
        img (:,:,3)
        hFig matlab.ui.Figure = gcf
    end

    clf(hFig);
    fpos = get(hFig,'Position');
    axOffset = (fpos(3:4)-[size(img,2) size(img,1)])/2;
    ha = axes('Parent',hFig,'Units','pixels',...
                'Position',[axOffset size(img,2) size(img,1)]);
    imshow(img,'Parent',ha);
end