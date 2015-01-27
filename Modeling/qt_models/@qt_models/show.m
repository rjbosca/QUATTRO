function show(obj)
%show  Displays fitted models in an instance of the modeling GUI
%
%   show(OBJ) displays the results of the fitted models for the qt_models
%   sub-class object specified by OBJ. A modeling GUI must be registered (type
%   "help qt_models.register" for more information) to the qt_model's sub-class
%   to provide visualization functionality

    % Validate that non-map data exist since show is not configured to handle
    % multi-dimensional data. Also ensure that a modeling GUI exists as no data
    % are displayed otherwise
    if isempty(obj.y) || isempty(obj.x) || ~obj.isSingle || obj.isShown ||...
                                        isempty(obj.hFig) || ~ishandle(obj.hFig)
        return
    end

    hAx = findobj(obj.hFig,'Tag','axes_main');

    % Plot the data
    y = obj.yProc;
    if ~isempty(y)

        % Determine if previous data exists or if a new plot must be created
        hData = findobj(hAx,'Tag','dataPlot');
        if isempty(hData) || ~ishandle(hData)

            % Grab the plot context menu from the application data (this was
            % created during GUI creation)
            hMenu = getappdata( hAx,'dataContextMenu');

            % Plot the data
            plot(hAx,obj.xProc,y,'sg',...
                                 'MarkerSize',8,...
                                 'MarkerFaceColor','g',...
                                 'Tag','dataPlot',...
                                 'uicontextmenu',hMenu);

            % Update the next plot property to ensure no plots are overwritten
            set(hAx,'NextPlot','add')

        else
            % Update the data
            set(hData,'XData',obj.xProc,'YData',y);
        end

    end

    % Plot the fitted data
    if isstruct(obj.results) && isfield(obj.results,'Fcn')

        % Determine if previous fitted data plots exist
        hFit = findobj(hAx,'Tag','fitPlot');
        if isempty(hFit) || ~ishandle(hFit)
            x = linspace(0,max(obj.xProc),10*numel(obj.x));
            plot(hAx,x,obj.results.Fcn(x),'b-',...
                                          'Tag','fitPlot');
        else
            x = get(hFit,'XData');
            set(hFit,'YData',obj.results.Fcn(x));
        end

    end

    % The plot functions like to reset the axis "Tag" property, ensure the value
    % is set to 'axes_main' since this is used to located the axis.
    set(hAx,'Tag','axes_main');

    % Call the class specific method for showing data
    obj.processShow;

    % Before exiting the method, update the property "isShown" to reflect the
    % fact that all modeling data has now been shown
    obj.isShown = true;

end %qt_models.show