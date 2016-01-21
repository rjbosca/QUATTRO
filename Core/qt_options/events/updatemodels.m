function updatemodels(src,~)
%updatemodels  Updates pertient qt_models objects in the QUATTRO environment
%
%   updatemodels(SRC,EVENT) updates the option OPT with the new value VAL. This
%   is a linker function that notifies other GUIs (e.g. qt_models GUI) of
%   changes in the qt_options object

    if isempty(src.hQt) || ~ishandle(src.hQt)
        return
    end

    % Get models object and loop through all objects
    %FIXME: this function used to look for the modeling object in QUATTRO's
    %application data. Because of the increasing complexity of the modeling
    %package this is no longer viable. Fix this code so that it can be used in a
    %much more general way (i.e., when a qt_options property that is also a
    %modeling object property is updated, update the modeling object)
    mObj = [];
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