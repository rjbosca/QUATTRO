function val = model2val(str)
%model2val  Model index from a model class name
%
%   N = model2val(MODEL) converts the model, specified by the string MODEL, to a
%   model index N. This is convenient for assigning pop-up menu 'Value'
%   properties

    % Determine if the entire class name (including containing packages was
    % specified). Otherwise, get the full value
    metaClass = meta.class.fromName(str);
    if isempty(metaClass)
        %TODO: write this code...
    end

    % Parse the containing package. The modeling package heirarchy requires
    % looking an extra level above the class' containg package
    metaPkg = metaClass.ContainingPackage;

    % Find the value by comparing the model class name to all class names
    val     = find( strcmpi(str,{metaPkg.ClassList.Name}) );

end %model2val