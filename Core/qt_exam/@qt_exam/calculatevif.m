function vif = calculatevif(obj)
%calculatevif  Calculates the VIF for a DCE/DSC exam
%
%   calculatevif(OBJ) calculates the vascular input function (VIF) from the
%   current indices specified by the qt_exam object (OBJ) property "roiIdx" with
%   the tag 'vif'.
%
%   Algorithm: calculatevif investigates each index specified in the 'vif' field
%              to extract values at each slice location of the respective ROIs.
%              When VIF ROIs exist on all series at a given ROI/slice location,
%              the invidual ROIs at each series point are used to calculate the
%              voxel values - useful when manually mitigating, for example,
%              patient motion. Otherwise, the first ROI found in the seires at
%              the specified ROI/slice location is projected through to all
%              series to calculate the corresponding voxel values.


    vif = []; %initialize the output

    % Validate that there are ROIs with the tag 'vif'
    if ~isfield(obj.rois,'vif')
        return
    end

    % Pre-computation data
    nSeries = size(obj.imgs,2);

    % Loop through each of the VIFs
    vifVoxels = cell(1,nSeries);
    for rIdx = obj.roiIdx.vif

        % Grab the VIFs on this ROI label
        vifs    = obj.rois.vif(rIdx,:,:);
        vifMask = vifs.validaterois;

        % Loop through each slice
        for slIdx = 1:size(vifMask,2)

            slMask = vifMask(1,slIdx,:);
            if ~any(slMask) %no VIFs on this slice
                continue
            end

            % Determine if the VIF is on all the series, in which case grab the
            % label's values. Otherwise, project the first ROI found
            if (numel(slMask)==nSeries) && all(slMask)
                vifVals = obj.getroivals('label',@double,true,...
                                         'roi',rIdx,...
                                         'slice',slIdx,...
                                         'series',find(slMask,1,'first'),...
                                         'tag','vif');
            else %project the first ROI found
                vifVals = obj.getroivals('project',@double,true,...
                                         'roi',rIdx,...
                                         'slice',slIdx,...
                                         'series',find(slMask,1,'first'),...
                                         'tag','vif');
            end

        end

        vifVoxels = cellfun(@combine_values,vifVoxels,vifVals,...
                                                         'UniformOutput',false);

    end %ROI index

    % Finally, average the voxel values and return the VIF
    vif = cellfun(@mean,vifVoxels);

    % Since these computations are expensive, cache the VIF
    obj.vifCache = vif;

end %qt_models.calculatevif


%---------------------------------------------
function voxFull = combine_values(voxFull,vox)
    voxFull = [voxFull(:);vox(:)];
end %combine_values