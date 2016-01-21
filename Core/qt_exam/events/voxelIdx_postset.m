function voxelIdx_postset(~,eventdata)
%voxelIdx_postset  Post-set event for QT_EXAM "voxelIdx" property
%
%   voxelIdx_postset(SRC,EVENT) verifies that the "voxelIdx" property is within
%   appropriate bounds and updates any linked modeling objects

    % QT_EXAM object alias
    obj = eventdata.AffectedObject;
    mIm = obj.image.dimSize;

    % Validate the voxel position
    if (obj.voxelIdx(1)>mIm(2))
        warning(['QUATTRO:' mfilename ':idxOutOfRange'],...
                ['voxelIdx(1) is larger than the maximum extent of the ',...
                 'image. The value has been reset to %d.'],mIm(2));
        obj.voxelIdx(1) = mIm(2);
    end
    if (obj.voxelIdx(2)>mIm(1))
        warning(['QUATTRO:' mfilename ':idxOutOfRange'],...
                ['voxelIdx(2) is larger than the maximum extent of the ',...
                 'image. The value has been reset to %d.'],mIm(1));
        obj.voxelIdx(2) = mIm(1);
    end

    % Determine if any of the modeling objects and update those models that are
    % using the "current pixel" mode
    mdls = obj.models;
    if ~isempty(mdls)
        notify(obj,'newModelData',newModelData_eventdata('pixel','otf'));
    end

end %qt_exam.voxelIdx_postset