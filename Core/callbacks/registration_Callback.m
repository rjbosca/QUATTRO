function registration_Callback(hObj,eventdata)
%registration_Callback  Callback for handling QUATTRO qt_reg requests

    % Get exams object so that the new window can be registered
    obj = getappdata(gcbf,'qtExamObject');

    % Create the registration object
    regObj = qt_reg(obj);

    % Construct a new image registration tool and register the new window with
    % the current qt_exam object
    obj.register( imregtool(regObj) );

end %registration_Callback