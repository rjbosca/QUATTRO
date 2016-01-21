function showModel_event(obj,~,~)
%showModel_event  "showModel" modelbase event for PK class
%
%   showModel_event(OBJ,SRC,EVENT) creates visualizations specific to the PK
%   class that are fired following notification of the "showModel" event, where
%   OBJ is a DYNAMIC sub-class object. SRC and EVENT are unused, but required by
%   the listener syntax 

    % Grab the axis and cache some global values that are used in all additional
    % plots
    hAx = findobj(obj.hFig,'Tag','axes_main');


    %=============
    % Show the VIF
    %=============
    if ~isempty(obj.vifProc)

        % Grab the processed x data and try to find a previous plot
        xP   = obj.xProc;
        hVif = findobj(hAx,'Tag','vifPlot');

        % Plot the data
        if isempty(hVif) || ~ishandle(hVif)
            plot(hAx,xP,obj.vifProc,'-r','Tag','vifPlot');
        else
            set(hVif,'XData',xP,'YData',obj.vifProc);
        end

    end

    % The plot functions likes to reset the axis "Tag" property, ensure the
    % value is set to 'axes_main' since this is used to locate the axis.
    set(hAx,'Tag','axes_main');

end %pk.showModel_event