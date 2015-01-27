function autofit_postset(src,eventdata)
%autofit_postset  PostSet event for qt_models property "autofit"
%
%   autofit_postset(SRC,EVENT)

    % Get the modeling object
    obj = eventdata.AffectedObject;

    % Determine if results exist and fit the data otherwise
    if ~isfield(obj.results,'Fcn') || ~isfield(obj.results,'Params')
        obj.fit;
    end

end %qt_models.autofit_postset