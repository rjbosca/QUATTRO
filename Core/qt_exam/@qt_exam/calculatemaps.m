function calculatemaps(obj)
%calculatemaps  Calculates parametric maps for QUATTRO images
%
%   calculatemaps(OBJ) calculates the exam type specific parameter maps for
%   the current image stored in the qt_exam object OBJ.

    % Initialize the modeling object
    eType = obj.type;
    if isempty(eType) || strcmpi(eType,'generic')
        return
    end

    % Set the slices on which maps are to be computed
    slInd = obj.sliceIdx(:);
    if obj.opts.multiSlice
        slInd = 1:size(obj.imgs,1);
    end

    % Grab the modeling object from the exam object
    mObj = obj.mapModel;

    % Calculate the VIF for pharmacokinetic sub-classes
    if any(strcmpi( superclasses(mObj),'pk'))
        mObj.vif = obj.calculatevif;
    end

    % Loop through all slices
    for slIdx = slInd

        % Initialize the mask that will be used to crop the computation window.
        % When no ROI with the tag "mask" is present, simply compute the entire
        % image map
        %TODO: what if there is a mask ROI that is completely false? what if it
        %is a single voxel mask? How to find the series point where the mask is
        %located?
        [~,mask] = obj.getroivals('roi','slice',slIdx,...
                                        'series',obj.seriesIdx,'tag','mask');
        if ~any(mask(:))
            mask(:) = true;
        end

        % Update the y-data and fit
        mObj.y         = permute(obj.imgs(slIdx,:).img2mat,[3 1 2]);
        mObj.mapSubset = mask;
        argIn          = {};
        if obj.guiDialogs
            argIn = {'WaitBar',waitbar(0,'0% Complete','Name',...
                       sprintf('Calculating parametric maps: Slice %d',slIdx))};
        end
        mObj.fit(argIn{:});

        % Continue if no results exist for the current loop iteration
        if isempty(mObj.results)
            continue
        end

        % Store the results (provided each specific map's flag is true) and
        % update the map meta-data to ensure that the maps can be stored
        mapNames = fieldnames(mObj.results)';
        for mapName = mapNames

            % Map object alias for programming ease. Also, validate the
            % corresponding qt_option property that specifies the storage flag
            % for this specific map. In the event that no such flag exists,
            % simply store the data
            mapObj = mObj.results.(mapName{1});
            if isprop(obj.opts,[lower(mapObj.tag) 'Map']) &&...
                                           ~obj.opts.([lower(mapObj.tag) 'Map'])
                continue
            end

            % Now that the maps have been computed, grab the associated image
            % header and attach this to each map as header data. Also update a
            % number of fields associated with the new map
            %FIXME: this is temporary code until I have a more permanent
            %solution to modifying qt_image object "metaData"
            mData              = obj.imgs(slIdx,1).metaData;
            for fld = fieldnames(mapObj.metaData)'
                mData.(fld{1}) = mapObj.metaData.(fld{1});
            end
            mData.SeriesNumber = 1000*mData.SeriesNumber+...
                                             find(strcmpi(mapObj.tag,mapNames));
            mapObj.metaData    = mData;

            %TODO: figure out how to handle empty data

            % Store the data in the qt_exam object
            obj.addmap(mapObj,mapName{1},'slice',slIdx);

        end
    end

end %calculatemaps