function newModel_event(obj,~,~)
%newModel_event  Callback for QT_EXAM "mapModel" event
%
%   newModel_event(OBJ) creates a new modeling object based on the current state
%   of the qt_options object stored in the qt_exam object OBJ.

    % Store the modeling object
    obj.mapModel = obj.createmodel;

    % Set some parameter mapping specific properties
    obj.mapModel.autoGuess = true;

end %qt_exam.newModel_event