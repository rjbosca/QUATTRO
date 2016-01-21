function subset_postset(obj,src,~)
%subset_postset  Post-set event for the modeling property "subset"
%
%   subset_postset(SRC,EVENT) performs checks on the "subset" property based on
%   the "x" property details

    % Perform event appropriate operations
    if ~isempty(obj.x) && (any(obj.subset>length(obj.x)) ||...
                                             (length(obj.subset)>length(obj.x)))
        error(['QUATTRO:' src.Name ':invalidSubset'],...
              ['Numeric index values for the property "%s" must be less ',...
               'than or equal to the LENGTH(OBJ.x). Logicial masks must be ',...
               'the same length as the property "x".'],src.Name);
    end

    % Check for NaN values within the "y" properties. The corresponding
    % positions within "subset" should be set to false. This code is redundant
    % with the "y" property code, but ensures that the user cannot re-enable
    % infinite or not-a-number values.
    if ~isempty(obj.y) && (numel(obj.y)==numel(obj.subset))
        obj.subset( isnan(obj.x) | isinf(obj.x) ) = false;
    end

    % Notify any model updaters
    notify(obj,'updateModel');

end %modelbase.subset_postset