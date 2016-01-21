function s = model2str(tag)
%model2str  Convert a model tag to a model package string
%
%   STR = model2str(TAG) converts the model tag specified by the string TAG
%   to an evaluable string STR that specifies all packages necessary for
%   referencing a modeling object.

    % Grab the qt_models information
    mInfo = qt_models.model_info;
    if ~isfield(mInfo,tag)
        error(['QUATTRO:' mfilename ':invalidModelStr'],...
               '"%s" is not a valid QUATTRO model tag',tag);
    end

    % Construt the string
    s = ['qt_models.' mInfo.(tag).ModelInfo.ContainingPackage '.',...
                      mInfo.(tag).ContainingPackage];
    
end %model2str