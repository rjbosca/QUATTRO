function sort(obj)
%sort  Sorts QT_EXAM data according to the QT_EXAM property "type"
%
%   sort(OBJ) sorts the data stored in the current QT_EXAM object, OBJ,
%   according to the value of the "type" (type 'help qt_exam.type' for more
%   information) property. The property "imgs" is updated following the sort
%   operation.

    % Grab the images from the qt_exam object
    imgs  = obj.imgs(:);
    hdrs  = [imgs(:).metaData]';
    nImgs = numel(imgs);

    % Grab all the potentially necessary tags
    tagEchoTime  = dicomlookup('0018','0081'); %EchoTime
    tagFlipAngle = dicomlookup('0018','1314'); %FlipAngle
    tagInvTime   = dicomlookup('0018','0082'); %InversionTime
    tagRepTime   = dicomlookup('0018','0080'); %RepetitionTime
    tagSliceLoc  = dicomlookup('0020','1041'); %SliceLocation

    % Determine the number of slice locations
    [imgs,sliceLocs] = imgs.sort(tagSliceLoc);
    nSlices          = numel(sliceLocs);
    nSeries          = nImgs/nSlices;

    % The number of series points should correspond to the number of images
    % divided by the number of slice locations (i.e. mod(nImgs,nSlices)==0).
    if mod(nImgs,nSlices)
        error(['qt_exam:' mfilename ':incongruentImgStack'],...
              ['Image stack could not be sorted by slice/series because ',...
               'mod(nImages,nSlices)~=0. Unable to prepare the exam as a ',...
               '"%s" exam'],obj.type);
    end

    %TODO: what happens if ROIs exist? The ROIs should track with their current
    %position. Make sure that this sort functionality does that...

    % Sort the images according to exam type
    switch lower(obj.type)
        case 'dce'

            % Determine which field should be used
            flds  = {dicomlookup('0018','1060'),...TriggerTime (GE)
                     dicomlookup('0008','0032')}; %AcquisitionTime
            flds  = flds( isfield(hdrs,flds) );
            nFlds = cellfun(@(x) numel(unique( [hdrs.(x)] )),flds);

            % Grab the tag to use for sorting. The first condition was designed
            % to handle 3D T1-weighted FSPGR acquisitions and the second was
            % designed to handle 2D T2(*) acquisitions
            flds = flds( (nSeries==nFlds) | (nFlds==(nSlices*nSeries)) );
            if isempty(flds)
                error(['qt_exam:' mfilename ':unknownDceTimeFld'],...
                                       'Unable to detect the DCE time stamps.');
            elseif (numel(flds)>1)
                flds = flds(1);
            end

            % Sort the images by acquisition position and store the data
            imgs = imgs.sort(flds{:});

        case 'multiflip'

            % Sort the images by flip angle
            imgs = imgs.sort(tagFlipAngle);

        case 'multite'

            % Sort the images by echo time
            imgs = imgs.sort(tagEchoTime);

        case 'multiti'

            % Sort the images by inversion time
            imgs = imgs.sort(tagInvTime);

        case 'multitr'

            % Sort the images by repetition time
            imgs = imgs.sort(tagRepTime);

        otherwise
    end

    % Finally, reshape/sort the images according to slice location size and
    % store
    imgs     = reshape(imgs,nSlices,[]);
    obj.imgs = imgs.sort(tagSliceLoc);

end %qt_exam.sort