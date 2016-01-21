function lim_postset(obj,~,eventdata)
%lim_postset  PostSet event for X/Y axis limits property
%
%   lim_postset(OBJ,SRC,EVENT) completes roiview (OBJ) changes to the "XLim" 
%   property of the associated axes by re-rendering on-image ROIs. This usually
%   occurs during zoom and pan operations.

    %TODO: the following code is temporary until I figure out why the
    %"roiExtent" is empty
    if isempty(obj.roiExtent);
        obj.calcroiextent;
    end

    % Create the axis extent matrix
    hAx       = eventdata.AffectedObject;
    roiExtent = obj.roiExtent;
    axExtent  = [hAx.XLim(:) hAx.YLim(:)];

    % Cache the "render" property here it can be tested against the new "render"
    % property value set in the code below. This allows for avoidance of
    % redundantly setting the constraint function.
    render     = obj.render;

    % Determine if any of the ROIs are off the image and update the "render"
    % property as necessary (i.e., always assign a value as AbortSet=true). This
    % same task could be easily accomplished by getting the "isOnImage"
    % property, but I believe the syntax here to be faster. Also, 
    obj.render = ~(all(roiExtent(:,1)<axExtent(1,1)) ||...
                   all(roiExtent(:,2)<axExtent(1,2)) ||...
                   all(roiExtent(:,1)>axExtent(2,1)) ||...
                   all(roiExtent(:,2)>axExtent(2,2))) && render;
    if obj.render
        % Always use the absolute maximum extent, which is simply the extrma of
        % the respective ROI and axis extremas
        extent   = [min( [roiExtent(1,:);axExtent(1,:)] )
                    max( [roiExtent(2,:);axExtent(2,:)] )];
        fcnInput = mat2cell(extent,2,[1 1]);

        % Re-render the ROI 
        constFcn = make_constraint_fcn(fcnInput,[],['im' obj.roiObj.type]);
        obj.hRoi.setPositionConstraintFcn(constFcn);
    end

end %roiview.lim_postset