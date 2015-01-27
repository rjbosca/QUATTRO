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
    mObj          = eval([eType '(obj,''autoGuess'',true);']); %non-GUI models object
    mObj.modelVal = eval(['obj.opts.' eType 'Model']);

    % Set the slices on which maps are to be computed
    slInd = obj.sliceIdx(:);
    if obj.opts.multiSlice
        slInd = 1:size(obj.imgs,1);
    end

    % Calculate the VIF for DCE and DSC exams
    if any( strcmpi( class(mObj), {'dce','dsc'} ) )
        mObj.vif = obj.calculatevif;
    end

    % Loop through all slices
    for slIdx = slInd

        % Create the y-data by combining the series for the current slice and
        % initialize the mask that will be used to crop the computation window
        yData = permute(obj.imgs(slIdx,:).img2mat,[3 1 2]);
        mask  = true(obj.image.imageSize); %initialize the mask

        % Determine if a "mask" exists for the current slice
        if isfield(obj.rois,'mask')
            for rIdx = obj.roiIdx.mask

                % Grab the masks for this ROI label
                masks     = obj.rois.mask(rIdx,slIdx,:);
                masksMask = masks.validaterois;

                % Determine if any ROIs exist on the current slice
                if ~any( masksMask(1,1,:) )
                    continue
                end

                % Attempt to first locate the mask ROI on the current series
                %TODO: this code to find a "mask" ROI is really clunky. There
                %has to be a better way to handle this...
                if masksMask(1,1,obj.seriesIdx)
                    mask = mask & masks(1,1,obj.seriesIdx).mask;
                    continue
                else
                    for seIdx = 1:size(masksMask,3)
                        if masksMask(1,1,seIdx)
                            mask = mask & masks(1,1,seIdx).mask;
                            break
                        end
                    end

                end

            end
        end

        % Update the y-data and fit
        mObj.y         = yData;
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
            metaData                   = obj.imgs(slIdx,1).metaData;
            metaData.WindowCenter      = mapObj.metaData.WindowCenter;
            metaData.WindowWidth       = mapObj.metaData.WindowWidth;
            metaData.ImageType         =...
                          sprintf('PROCESSED\\SECONDARY\\%s',upper(mapObj.tag));
            metaData.SeriesNumber      = 1000*metaData.SeriesNumber+...
                                             find(strcmpi(mapObj.tag,mapNames));
            mapObj.metaData            = metaData;

            %TODO: figure out how to handle empty data

            % Store the data in the qt_exam object
            obj.addmap(mapObj,mapName{1},'slice',slIdx);

        end
    end

end %calculatemaps