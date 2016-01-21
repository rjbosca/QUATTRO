function newdisp(obj,src,~)
%newdisp  PostSet event for the "dispFields" qt_image property
%
%   newdisp(OBJ,SRC,EVENT)

    if strcmpi(src.Name,'dispFields')

        % Validate all the fields. They should be either one of the meta-data
        % fields or one of the object's properties
        validStrs          = [properties(obj);fieldnames(obj.metaData)];
        dispStrs           = obj.dispFields(:);
        emptyInd           = cellfun(@isempty,dispStrs);
        dispStrs(emptyInd) = [];
        strs               = unique(dispStrs);
        rmIdx              = [];
        for sIdx = 1:length(strs)
            try
                strs{sIdx} = validatestring(strs{sIdx},validStrs);
            catch ME
                if ~strcmpi(ME.identifier,'MATLAB:unrecognizedStringChoice')
                    rethrow(ME);
                end
                rmIdx = [rmIdx;sIdx]; %#ok
                warning('qt_image:invalidDispFld',...
                                  '%s is not a valid display field',strs{sIdx});
            end
        end

        % Remove bad fields
        if ~isempty(rmIdx)
            strs(rmIdx)    = [];
            obj.dispFields = strs;
        end

    elseif strcmpi(src.Name,'dispFormat')
    end

    % Notify the view object
    if ~isempty(obj.imgViewObj)
        notify(obj.imgViewObj,'newText');
    end

end %qt_image.newdisp