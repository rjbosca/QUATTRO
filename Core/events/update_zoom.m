function update_zoom(objFig,eventdata) %#ok<*INUSD>
%update_zoom  Updates QUATTRO GUI following a zoom event
%
%   udpate_zoom(OBJ,EVENTDATA) updates the figure object specified by OBJ
%   to reflect changes in the zoom state. Currently, this function is used
%   only as the "ActionPostCallback" for the zoom functionality of QUATTRO
%
%   See also zoom_Callback

    % Get the necessary handles and QUATTRO objects
    hFig = findobj(objFig,'Tag','figure_main');
    opts = getappdata(hFig,'qtOptsObject');
    img  = getappdata(hFig,'qtImgObject');

    %TODO: determine what to do with linked axes
    if ~strcmp(get(hFig,'Name'),qt_name) && opts.linkAxes %get linked quattro handles
        hQtLink = getappdata(hFig,'linkedfigure');
        hAx     = findobj(hQtLink,'Tag','axes_main');
    end

    % Apply control updates
    if any( img.isZoomed )
        update_controls(hFig,'enable');
    else
        %TODO: this is a little computationally intensive (well, not really), but
        %there has to be a better way to handle "refreshes" 
        update_controls(hFig,'disable','enable');

        % Disable the zoom out feature
        hZoom = zoom(hFig);
        setAllowAxesZoom(hZoom,eventdata.Axes,false);
    end

end %update_zoom