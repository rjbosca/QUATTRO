function show(obj)
%show  Displays fitted models in an instance of the modeling GUI
%
%   show(OBJ) displays the results of the fitted models for the qt_models
%   sub-class object specified by OBJ. A modeling GUI must be registered (type
%   "help modelbase.register" for more information) to the modeling object
%   to provide visualization functionality

    % Validate that non-map data exist since show is not configured to handle
    % multi-dimensional data. Also ensure that a modeling GUI exists as no data
    % are displayed otherwise
    if isempty(obj.y) || isempty(obj.x) || ~obj.isSingle || obj.isShown ||...
                                        isempty(obj.hFig) || ~ishandle(obj.hFig)
        return
    end

    % Notify the modelbase sub-class object to update any additional class
    % specific listeners
    notify(obj,'showModel');

    % Before exiting the method, update the property "isShown" to reflect the
    % fact that all modeling data has now been shown
    obj.isShown = true;

end %modelbase.show