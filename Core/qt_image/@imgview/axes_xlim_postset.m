function axes_xlim_postset(obj,~,eventdata)
%axes_xlim_postset  Post-set event for axis "XLim" property
%
%   axes_xlim_postset(OBJ,SRC,ED) completes imgview (OBJ) changes to the "XLim" 
%   property of the associated axes the zoom operation of the specified the
%   imgview  object (and any other current views), OBJ, by re-rendering on-image
%   text and ROIs.

    % Toggle the on-image text dispaly to "on". This will fire the associated
    % listeners, forcing an update
    %FIXME: this used to be how the text was updated following a change in the
    %zoom, but how is this supposed to work if the user has requested that no
    %on-image text be displayed?
%     obj.isDispText = true;

    % Determine if the window is zoomed and update the associated property
    obj.isZoomed = (obj.imgObj.dimSize(1)~=diff(eventdata.AffectedObject.XLim));

end %imgview.axes_xlim_postset