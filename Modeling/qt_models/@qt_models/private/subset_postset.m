function subset_postset(obj,src,eventdata)
%subset_postset  PostSet event for the qt_models property "subset"
%
%   subset_postset(SRC,EVENT) performs checks on the "subset" property based on
%   the "x" property details

    % Get the qt_modelx object
    obj = eventdata.AffectedObject;

    % Perform event appropriate operations
    if ~isempty(obj.x) && (any(obj.subset>length(obj.x)) ||...
                                             (length(obj.subset)>length(obj.x)))
        error(['qt_models:' src.Name ':invalidSubset'],...
              'subset values must be less than or equal to the length of data');
    end

    % Fit the data if "autoFit" is enabled
    obj.update

end %qt_models.subset_postset