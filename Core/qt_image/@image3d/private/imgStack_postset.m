function imgStack_postset(obj,~,~)
%imgStack_postset  Post-set listener for IMAGE3D property "imgStack"
%
%   imgStack_postset(OBJ,SRC,EVENT)


    %-------------------------
    %   Initial Image Cache
    %-------------------------

    % Update the "dimSize" property. IMAGE3D assumes that all IMAGE2D objects in
    % the stack have the same size...
    nSls        = numel(obj.imgStack);
    obj.dimSize = [obj.imgStack(1).dimSize nSls];

    % Initialize the "imageRaw" property
    %FIXME: I am assuming that the image format is DICOM since that is the only
    %format supported currently...
    obj.imageRaw = zeros(obj.dimSize,'uint16');

    % For each of the IMAGE2D objects, determine if there is image data to write
    % to the image cache
    for slIdx = 1:nSls
        imRaw = obj.imgStack(slIdx).imageRaw;
        if ~isempty(imRaw)
            obj.imageRaw(:,:,slIdx) = imRaw;
        end
    end


    %------------------------
    %   Update Coordinates
    %------------------------

    % Update the coordinate transformation property - "coorTrafo". One of the
    % transformation matrices must be taken from one of the IMAGE2D objects in
    % the stack. IMAGE3D assumes that all 2D images have the same in-plane
    % transformation
    obj.coorTrafo = obj.imgStack(1).coorTrafo;

    % Update the slice transformation
    t = obj.imgStack(1).metaData.ImagePositionPatient -...
                                obj.imgStack(end).metaData.ImagePositionPatient;
    t = t/(1-numel(obj.imgStack));
    obj.coorTrafo(1:3,3) = t;

end %image3d.imgStack_postset