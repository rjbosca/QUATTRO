function imageRaw_postset(obj,~,~)
%imageRaw_postset  
%
%   imageRaw_postset(OBJ,SRC,EVENT)

    % Update the image object properties according to actual image data
    if ~obj.isPropsUpdated && any(obj.imageRaw(:))

        % Update the dimension size
        obj.dimSize = size(obj.imageRaw);

        % Update the min/max voxel elements
        %TODO: should the meta-data also be updated???
        obj.elementMin = double( min(obj.imageRaw(:)) );
        obj.elementMax = double( max(obj.imageRaw(:)) );
    %     mData(1).SmallestImagePixelValue = obj.elementMin;
    %     mData(1).LargestImagePixelValue  = obj.elementMax;

        % Update the "isPropsUpdated" flag to reflect the fact that all image
        % object properties have alread been updated so these operations need
        % not be performed more than once.
        obj.isPropsUpdated = true;

    end

end %imagebase.imageRaw_postset