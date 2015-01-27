function rois = squeeze_roi_stack(obj,rois)
%squeeze_roi_stack  Removes sub-indices from the qt_exam ROI stack
%
%   ROIS = squeeze_roi_stack(ROIS) squeezes out slices of the ND qt_roi object
%   array ROIS that contain invalid or empty qt_roi objects.

    % Get the ROI array and a mask of valid ROIs, replacing any invalid ROIs
    % with empty qt_roi objects to ensure that any QUATTRO caller does not error
    % when accessing the object
    [rois( ~rois.isvalid )] = deal(qt_roi);%replace invalid ROIs with empty ROIs
    validRoiMask            = rois.validaterois;
    nd                      = ndims(validRoiMask);

    %TODO: you haven't tested the code on multiple ROIs or ROIs placed on
    %slice/series other than 1

    % Loop through each dimension and determine/remove empty sub-indices
    % that allow a collapse in the array size
    isSingle = false(1,nd);
    for dIdx = 1:nd

        % Store the size of the arrays
        m = num2cell( size(rois) );

        % Loop through the indices of the array
        for idx = size(rois,1):-1:1

            % Starting from the extent of the array, check that there are
            % data. If so, exit the loop before removing any data
            if any(validRoiMask(idx,:)) && (dIdx~=1)
                break
            elseif any(validRoiMask(idx,:)) %ROI index can collapse, but not slice/series
                continue
            end

            % Collapse unused dimensions
            rois(idx,:)         = [];
            validRoiMask(idx,:) = [];

            % Reshape
            validRoiMask = reshape(validRoiMask,[],m{2:end});
            rois         = reshape(rois,[],m{2:end});

        end

        % Always check for an empty array after the ROI index loop above as this
        % might have removed all of the data in rois
        if (numel(rois)==0)
            rois = qt_roi.empty(1,0);
            break
        end

        % Store an indicator of the collapsed dimensions
        isSingle(dIdx) = (size(rois,1)==1);

        % Shift the dimensions to left by one
        validRoiMask = shiftdim(validRoiMask,1);
        rois         = shiftdim(rois,1);

    end

    % Loop through each dimensions restoring any singleton dimensions
    for dIdx = 1:nd

        if isSingle(dIdx) && (size(rois,dIdx)~=1)

            % Add a singleton dimension out front
            rois  = shiftdim(rois,-1);

            % Move the dimension to the appropriate place
            idxer           = 1:nd;
            idxer([1 dIdx]) = [dIdx 1];
            rois            = permute(rois,idxer);

        end

    end

end %qt_exam.squeeze_roi_stack