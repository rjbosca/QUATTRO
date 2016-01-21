function imgObj_postset(obj,~,~)
%imgObj_postset
%
%   imgObj_postset(OBJ,SRC,EVENT)

    % Create a post-set listener for the "metaData" property and fire the
    % listener now (since the object has already been constructed)
    addlistener(obj.imgObj,'metaData','PostSet',@obj.image_metaData_postset);
    image_metaData_postset(obj,[],struct('AffectedObject',obj.imgObj));

end %qt_image.imgObj_postset