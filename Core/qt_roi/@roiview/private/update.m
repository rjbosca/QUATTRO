function update(obj)
%update  Updates roiview object display properties
%
%   update(OBJ) updates the roiview object, OBJ, according to the current state
%   of the properties. This function is used primarily for updating position
%   constraint functions according to the current image view and for interactive
%   creation of new ROIs

    %TODO: the following code assumes that an object that already has listeners
    %for the events defined below has those events defined previously. Determine
    %if this is a reasonable assumption. My gut feeling: if the qt_roi framework
    %does not exapnd to include additional listeners other than those defined
    %below, there shouldn't be an issue.

    % Define some listeners up front to ensure zoom and pan operations perform
    % appropriately. Cache this listener to be deleted during object destruction
    if isempty(obj.handleListeners)
        obj.handleListeners = addlistener(obj.hAxes,'XLim',...
                                                    'PostSet',@obj.lim_postset);
        obj.handleListeners = addlistener(obj.hAxes,'YLim',...
                                                    'PostSet',@obj.lim_postset);
    end

    % Get the image handle
    hAx = obj.hAxes;
    hIm = findobj(hAx,'Type','image');
    if any( [isempty(hIm) ~obj.render ~obj.isOnImage] )
        return
    end

    % Ensure the current ROI object has the appropriate setting from the image
    % scale
    if isempty(obj.imageScale)
        obj.imageScale = size( get(hIm,'CData') );
    end

    % At this point, the user is either in the process of creating an ROI or has
    % specified all necessary information and is simply showing the ROI. The
    % first case requires creation of an interactive ROI
    if isempty(obj.roiObj.position)
        obj.createroi;
    else

        % Create a position constraint function based on the current image view
        constFcn = make_constraint_fcn(obj.hAxes,[],['im' obj.roiObj.type]);

        % Show the ROIs and update the display flag
        obj.hRoi = feval(['im' obj.roiObj.type],hAx,obj.roiPosition,...
                                              'PositionConstraintFcn',constFcn);
        obj.hRoi.setColor(obj.roiObj.color);
        obj.hRoi.addNewPositionCallback( @obj.newposition_Callback );

        % Update the "roiStats" property of the qt_roi object if needed
        if isempty(obj.roiObj.roiStats)
            qt_roi.calcstats(obj.roiObj);
        end
    end

end %roiview.update