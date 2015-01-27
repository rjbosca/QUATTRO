function updatemodels(src,eventdata)
%updatemodels  Updates pertient qt_models objects in the QUATTRO environment
%
%   updatemodels(SRC,EVENT) updates the option OPT with the new value VAL. This
%   is a linker function that notifies other GUIs (e.g. qt_models GUI) of
%   changes in the qt_options object

    obj = eventdata.AffectedObject;
    if isempty(obj.hQt) || ~ishandle(obj.hQt)
        return
    end

    % Get models object and loop through all objects
    mObj = getappdata(obj.hQt,'modelsObject');
    if isempty(mObj)
        return
    end

    % Try to update the new property. Since the modeling objects consist of a
    % collection of sub-classes of the qt_models class, trying to set the
    % updated property in an object of unknown class will likely throw an error
    try
        mObj.(src.Name) = obj.(src.Name);
    catch ME
        if ~strcmpi(ME.identifier,'MATLAB:noPublicFieldForClass')
            rethrow(ME)
        end
    end

end %updatemodels