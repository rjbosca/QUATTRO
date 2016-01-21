function showModel_event(obj,~,~)
%showModel_event  "showModel" MODELBASE event
%
%   showModel_event(OBJ,SRC,EVENT) creates general visualizations specific for
%   all MODELBASE sub-class objects following notification of the "showModel"
%   event, where OBJ is a MODELBASE sub-class object. SRC and EVENT are unused,
%   but required by the listener syntax 

    % Grab the axis and cache some global values that are used in all additional
    % plots
    hAx = findobj(obj.hFig,'Tag','axes_main');


    %==============
    % Show the data
    %==============

    % Determine if previous data exists or if a new plot must be created
    hData = findobj(hAx,'Tag','dataPlot');
    if isempty(hData) || ~ishandle(hData) %create a new plot

        % Grab the plot context menu from the application data (this was
        % created during GUI creation)
        hMenu = getappdata( hAx,'dataContextMenu');

        % Plot the data
        plot(hAx,obj.xProc,obj.yProc,'sg',...
                                     'MarkerSize',8,...
                                     'MarkerFaceColor','g',...
                                     'Tag','dataPlot',...
                                     'uicontextmenu',hMenu);

    else %update an existing plot
        set(hData,'XData',obj.xProc,'YData',obj.yProc);
    end


    %===================
    % Show the model fit
    %===================

    % Plot the fitted data
    pFcn = obj.plotFcn;
    if ~isempty(pFcn)

        % Determine if previous fitted data plots exist
        hFit = findobj(hAx,'Tag','fitPlot');
        if isempty(hFit) || ~ishandle(hFit)
            x = linspace(0,max(obj.xProc),10*numel(obj.x));
            plot(hAx,x,pFcn(x),'b-','Tag','fitPlot');
        else
            x = get(hFit,'XData');
            set(hFit,'YData',pFcn(x));
        end

    end


    % The plot functions likes to reset the axis "Tag" property, ensure the
    % value is set to 'axes_main' since this is used to locate the axis.
    set(hAx,'Tag','axes_main');

end %modelbase.showModel_event