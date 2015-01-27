function val = calcroiextent(obj)
%calcroiextent  Computes the ROI extent
%
%   P = calcroiextent(OBJ) calculates the extent of the current roiview object,
%   OBJ, using the associated qt_roi object properties. The roiview uses any
%   current access to automatically scale the ROI
    
    % Grab the qt_roi object
    roiObj = obj.roiObj;

    % Get the scaled vertices
    verts = roiObj.vertices;
    scale = obj.imageScale;
    if isempty(scale)
        %TODO: I think the problem has been fixed, so eventually I should remove
        %this line.
        error('Why is the scale empty???');
    end
    if isempty(verts) || isempty(scale)
        return
    end

    % Scale the verticies and the new ROI extent
    verts         = scale_roi_verts(verts,['im' roiObj.type],scale);
    obj.roiExtent = [min(verts(:,1)) min(verts(:,2))
                     max(verts(:,1)) max(verts(:,2))];

    % Provide output if requested
    if nargout
        val = obj.roiExtent;
    end

end %roiview.calcroiextent