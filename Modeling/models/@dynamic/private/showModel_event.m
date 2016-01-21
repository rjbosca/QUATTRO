function showModel_event(obj,~,~)
%showModel_event  "showModel" modelbase event for DYNAMIC class
%
%   showModel_event(OBJ,SRC,EVENT) creates visualizations specific to the
%   DYNAMIC class that are fired following notification of the "showModel"
%   event, where OBJ is a DYNAMIC sub-class object. SRC and EVENT are unused,
%   but required by the listener syntax

    % Grab the axis and cache some global values that are used in all additional
    % plots
    hAx = findobj(obj.hFig,'Tag','axes_main');


    %========================
    % Show the injection time
    %========================
    hPre  = findobj(hAx,'Tag','arrivalPlot');
    xData = repmat(obj.injectionTime,[2 1]);
    yData = get(hAx,'YLim');
    if isempty(hPre) || ~ishandle(hPre) %new plot
        plot(hAx,xData,yData,'-g','Tag','arrivalPlot');
    else %update existing plot
        set(hPre,'XData',xData,'YData',yData);
    end


    %============================
    % Show the recirculation time
    %============================
    hRecirc = findobj(hAx,'Tag','recircPlot');
    xData   = repmat(obj.recircTime,[2 1]);
    if isempty(hRecirc) || ~ishandle(hRecirc) %new plot
        plot(hAx,xData,yData,'-r','Tag','recircPlot');
    else%update existing plot
        set(hRecirc,'XData',xData,'YData',yData);
    end

    % The plot functions likes to reset the axis "Tag" property, ensure the
    % value is set to 'axes_main' since this is used to locate the axis.
    set(hAx,'Tag','axes_main');

end %dynamic.showModel_event