function addmodel(obj,mObj)
%addmodel  Adds a modeling object to the exam
%
%   addmodel(OBJ,MODEL) adds the modeling object, MODEL, to the qt_exam object
%   specified by OBJ.

    % Grab the current value of the "models" property as these will be needed
    % for validation
    curModels = obj.models;

    if ~any( strcmpi('modelbase',superclasses(mObj)) )
        error(['QUATTRO:' mfilename ':invalidModelObject'],...
              ['When setting the qt_exam property "models", the input must ',...
               'be a modeling sub-class (i.e., a sub-class of MODELBASE).']);
    elseif (numel(mObj)~=1)
        error(['QUATTRO:' mfilename ':wrongNumberOfModels'],...
              ['When setting the qt_exam property "models", the new value ',...
               'must be a scalar modeling object.']);
    elseif ~isempty(curModels) && any( cellfun(@(x) x==mObj,curModels) )
        error(['QUATTRO:' mfilename ':modelExists'],...
              ['When setting the qt_exam property "models", the new ',...
               'modeling object must be unique.']);
    end

    % Add a listener that allows the QT_EXAM object and modeling object to
    % interact following changes to the "dataMode" property of the modeling
    % object
    addlistener(mObj,'dataMode','PostSet',@obj.modelbase_dataMode_postset);

    % Add the event listener that updates the modeling object data
    mObj.eventListeners = addlistener(obj,'newModelData',...
                                     @(src,ed) newModelData_event(mObj,src,ed));

    % Append the validate modeling object to the current cell array and update
    % the property
    curModels{end+1} = mObj;
    obj.models       = curModels;

end %qt_exam.addmodel