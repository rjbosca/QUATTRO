function axes_ylim_postset(obj,src,eventdata)
%axes_ylim_postset  PostSet event for axis "XLim" property
%
%   axes_ylim_postset(OBJ,SRC,ED) completes imgview (OBJ) changes to the "XLim" 
%   property of the associated axes the zoom operation of the specified the
%   imgview  object (and any other current views), OBJ, by re-rendering on-image
%   text and ROIs.

    % Toggle the on-image text dispaly to "on". This will fire the associated
    % listeners, forcing an update
    obj.isDispText = true;

    % Determine if the window is zoomed and update the associated property
    obj.isZoomed = (obj.imgObj.imageSize(2)~=...
                                           diff(eventdata.AffectedObject.YLim));

end %imgview.axes_ylim_postset