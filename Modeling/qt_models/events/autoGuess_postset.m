function autoGuess_postset(src,eventdata)
%autoGuess_postset  PostSet event for qt_models property "autoGuess"
%
%   autoGuess_postset(SRC,EVENT) handles PostSet events for the qt_models
%   property "autoGuess", where SRC is the event source data and EVENT is the
%   event object. 
%
%   Changes to the "autoGuess" property only fire the fitting algorithms (if
%   "autoFit" is true).

    % Grab the modeling object
    obj = eventdata.AffectedObject;

    % Fit the data again using the new guess
    if obj.autoFit
        obj.fit;
    end

end %qt_models.autoGuess_postset