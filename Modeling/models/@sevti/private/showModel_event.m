function showModel_event(obj,~,~)
%showModel_event  "showModel" SEVTI event
%
%   showModel_event(OBJ,SRC,EVENT) creates general visualizations specific for
%   all MODELBASE sub-class objects following notification of the "showModel"
%   event, where OBJ is a SEVTI sub-class object. SRC and EVENT are unused,
%   but required by the listener syntax 

    % Grab the axis and cache some global values that are used in all additional
    % plots
    hAx = findobj(obj.hFig,'Tag','axes_main');

    %TODO: this method is being called twice when the current ROI selection is
    %changed in the modeling GUI.

    %=================
    % Show the null TI
    %=================
    hNull = findobj(hAx,'Tag','nullTiPlot');
    if isempty(hNull) || ~ishandle(hNull) %new plot

        % Generate a new vertical IMLINE object on the plot
        [hNull,lineObj] = vline(obj.tiInvThresh);

        % Update the "tag" and "color" properties
        set(hNull,'Tag','nullTiPlot');
        lineObj.setColor('r');

    else %update an existing plot

        % Update the IMLINE object's postion
        lineObj      = getappdata(hNull,'roiObjectReference');
        linePos      = lineObj.getPosition;
        linePos(:,1) = obj.tiInvThresh;

        % This is a hack... Before setting the position, the new position
        % callback must be removed. Otherwise, a number of property post-set
        % listeners will be fired, disabling the "autoGuess" property.
        id = getappdata(hNull,'callbackIdentifier');
        lineObj.removeNewPositionCallback(id);

        % Update the position. The position callback will be added below.
        lineObj.setPosition(linePos);

    end

    % Create a position listener for the IMLINE object. The output must be
    % cached as it contains a function handle to be used with the method
    % "removeNewPositionCallback"
    id = lineObj.addNewPositionCallback(@obj.vline_new_position_Callback);
    setappdata(hNull,'callbackFcn',@obj.vline_new_position_Callback);
    setappdata(hNull,'callbackIdentifier',id);

end %sevti.showModel_event