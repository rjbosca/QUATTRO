function modelStr = modelclass2str(modelStr)
%modelclass2str  Convert a modeling class name to a full package string
%
%   S = modelclass2str(MODEL) converts the modeling class, specified by the
%   string MODEL, to an evaluable package string

    % Determine all of the model types
    modelTypes = qt_models.model_info;

    % Loop through the model types to see if the model class exists
    for fld = fieldnames(modelTypes)'
        mClasses = meta.package.fromName( qt_models.model2str(fld{1}) );
        cNames   = cellfun(@(x) strrep(x,[mClasses.Name '.'],''),...
                               {mClasses.ClassList.Name},'UniformOutput',false);
        if any(strcmpi(modelStr,cNames))
            modelStr = [mClasses.Name '.' modelStr]; %#ok
            return
        end
    end

end %modelclass2str