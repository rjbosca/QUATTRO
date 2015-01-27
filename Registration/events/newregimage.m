function newregimage(src,eventdata)
%newregimage  PostSet event for qt_reg properties "imTarget" and "imMoving"
%
%   newregimage(SRC,EVENT)

    % Determine which property was updated
    obj = eventdata.AffectedObject;
    if strcmpi(src.Name,'imTarget')

        % Initialize the image size
        obj.mTarget = size(obj.imTarget);

        % Ensure that the voxel dimension matches the number of image dimensions
        obj.pixdim1 = ones(1,obj.n);

    elseif strcmpi(src.Name,'imMoving')

        % Initialize the image size
        obj.mMoving = size(obj.imMoving);

        % Ensure that the voxel dimension matches the number of image dimensions
        obj.pixdim2 = ones(1,obj.n);

    else
    end

end %qt_reg.newregimage