function modeling_Callback(hObj,eventdata) %#ok
%modeling_Callback  Callback for handing QUATTRO qt_models requests
%
%   modeling_Callback(H,EVENT)

    % Get exams object and the current figure
    hFig = gcbf;
    obj  = getappdata(hFig,'qtExamObject');

    % Create a modeling object registered with the current qt_exam object
    mObj          = eval([obj.type '(obj,''autoGuess'',true);']);
    mObj.modelVal = obj.opts.modelVal;

    % Calculate the VIF for DCE and DSC exams
    if any( strcmpi( class(mObj), {'dce','dsc'} ) )
        mObj.vif = obj.calculatevif;
    end

    % Create the modeling GUI and attach the new modeling object (also, register
    % this GUI with the qt_exam object)
    obj.register( qimtool(mObj) );

    % Append the new modeling object to old qt_models objects
    oldMObj = getappdata(hFig,'modelsObject');
    if ~isempty(oldMObj)

    end

    % Update the application data
    setappdata(hFig,'modelsObject',mObj);

end %modeling_Callback