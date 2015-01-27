function report(obj,varargin)
%report  Reports data from an exams object
%
%   report(TYPE,FILE) generates a report of the TYPE specified (see below) and
%   stores those data in a tab delimited in FILE. Valid report type strings are:
%
%       Type        Details
%       -----------------------
%       'pixels'    Reports pixels values within the user-specified ROIs in the
%                   current slice series location for all available parameteric
%                   maps 
%
%       'summary'   Calculates and reports ROI averaged estimated model
%                   parameter values if parameters maps are not present. For
%                   ROIs that do not exist on the entire series, the first
%                   instance of the ROI in the series is used as the ROI for all
%                   other images in the series.
%
%                   Or, reports ROI averaged values for all parameter maps. The
%                   first instance of a multi-series ROI is used to calculate
%                   parameter statistics
%
%       'vif'       Reports the unprocessed signal intensity of the VIF and time
%                   series vector (DCE & DSC exams only) 
%
%
%   report(...,'index',I) reports values for only those ROI indices specified
%   in the vector I.

    % Parse inputs
    [fName,rIdx,rType] = parse_inputs(varargin{:});
    if (~obj.exists.rois.any && ~strcmpi(rType,'vif')) ||...
           (~obj.exists.rois.any && obj.exists.rois.vif && strcmpi(rType,'vif'))
        return
    end

    % Replace empty ROI index with length of ROIs
    if isempty(rIdx)
        rIdx = 1:size(obj.rois.roi,1);
    end

    % Ensure that the indices are valid
    nRoi                     = size(obj.rois.roi,1);
    rIdx(rIdx>nRoi | rIdx<1) = [];
    rIdx                     = round(rIdx);

    % Verify overlays exist or modeling is prepared
    if all(~strcmpi(rType,{'vif','pixel_series'})) &&...
                                      obj.exists.maps.any && obj.exists.rois.any
        s = sort_names( fieldnames(obj.overlays) ); %sorts map names, placing R^2 at the end
        s( strcmpi(s,'Names') ) = []; %these are place holders, not maps
        s( strcmpi(s,'Scale') ) = []; %these are place holders, not maps
    end

    % Open file for writing
    fid = fopen(fName,'w');
    if fid==-1
        errordlg('Unable to open file for writing.');
        return
    end

    % Print header and store position
    hdr = obj.metaData;
    fprintf(fid,'%% MRN: %s\n%% Study Date: %s\n%% %s\n\n',...
                                      hdr.PatientID,hdr.StudyDate,datestr(now));
    initPos = ftell(fid);

    % Write data to file
    endPos = eval(['report_' rType]);

    % Close the file and make sure data were written
    fclose(fid);
    if isempty(endPos) || (initPos==endPos)
        if exist(fName,'file')
            delete(fName);
        end
        errordlg('Data was not written to report.');
    end


%------------------------------Reporting Functions------------------------------

    % Pixel reporting function
    function endPos = report_pixels %#ok<*DEFNU>

        % Generate ROI header
        roiHdr = ['x\ty\tz\tx_p\ty_p\tz_p\t' repmat('%s\t',1,length(s))];
        roiHdr(end) = 'n'; roiHdr = sprintf(roiHdr,s{:});

        % Get/write data
        roi = obj.regions; sp = [hdr.PixelSpacing(:)' hdr.SliceThickness];
        m = size(obj.images(1,1)); se = get(obj.h_sl(2),'Value');
        for i = rIdx

            roi_hdr_written = false; %use flag to inform if header is written

            for j = 1:min([obj.size('headers',1) obj.size('images',1)])
                % Get mask
                mask = obj.get_mask('size',m','index',{i,j,se});
                if isempty(mask)
                    continue
                end

                % Write header for ith ROI
                if ~roi_hdr_written
                    data_str = sprintf('%% ROI Name: %s\n%s\n',...
                                                     roi(i).names,roiHdr);
                    fprintf(fid,'%s',data_str); roi_hdr_written = true;
                end

                % Generate coordinates and data matrix
                [y x] = find(mask); z = repmat(j,size(x));
                c_p = pix2phys([x y z],sp); data = permute([x y z c_p],[2 1]);

                for k = 1:length(s) %overlay loop
                    % Get overlay and store data
                    im = obj.overlays(j,s{k});
                    if strcmpi(s{k},'adc')
                        im = im*1e9;
                    end
                    data = [data; im(mask).'];
                end

                % Write pixel data to file
                w_str = ['%10.0f\t%10.0f\t%10.0f\t%5.4f\t%5.4f\t%5.4f\t',...
                                                     repmat('%5.5f\t',1,k)];
                w_str(end) = 'n';
                fprintf(fid,'%s',sprintf(w_str,data));

            end %slice loop

            % Writes spacing for next ROI
            fprintf(fid,'%s',sprintf('\n\n'));

        end %roi loop

        endPos = ftell(fid);

    end %report_pixels


    % ROI summary reporting function
    function endPos = report_summary %#ok<*STOUT>

        % User specifies map types
        eType = obj.type;
        if exist('s','var')
            if strcmpi(eType,'dce')
                initVals = [2 4 5 10 11];
            else
                initVals = length(s);
            end
            [s,ok] = cine_dlgs('summarize_data',s,initVals);
            if ~ok
                return
            end
        else
            s = {};
        end

        % Get some exam information
        exId  = obj.metaData.StudyID;
        serId = obj.metaData.SeriesNumber;

        % Create a qt_models object to perform the fitting
        mObj = eval([obj.type '(obj,''autoGuess'',true);']);

        % Prepare the parameters names/units for writing
        prms     = fieldnames(  mObj.paramUnits );
        prmUnits = struct2cell( mObj.paramUnits );

        % Write the header
        fprintf(fid,'%%ROI Averaged Modeling - ');
        fprintf(fid,'%s\n',mObj.modelNames{mObj.modelVal});
        fprintf(fid,'%%Exam/Series\t\tSlice\tROI');
        for prmIdx = 1:numel(prms)
            if isempty( prmUnits{prmIdx} )
                fprintf(fid,'\t\t%s',prms{prmIdx});
            else
                fprintf(fid,'\t\t%s (%s)',prms{prmIdx},prmUnits{prmIdx});
            end
        end
        fprintf(fid,'\t\tR^2\n');
        fprintf(fid,'%%           \t\t     \t\t\t   ');
        fprintf(fid,'\n%%%s\n',repmat('=',[1 53]));

        % Perform ROI calculations. These calculations are only performed on the
        % "none" ROI tag
        for roiIdx = rIdx %ROI index loop

            % Get slice location of ROI
            roiSub    = permute( obj.rois.roi(roiIdx,:,:), [2 3 1] );
            slInds    = find( any( roiSub.validaterois, 2 ) );
            isSameSe  = (size(roiSub,2)==size(obj.imgs,2));
            for slIdx = slInds(:)' %Slice loop

                % Get ROI series data
                roiMask = (roiSub(slIdx,:).validaterois);
                if isSameSe && all(roiMask) %case for the ROI being on all series
                    %TODO: write this code!
                else
                    seIdx      = find(roiMask,1,'first');
                    mObj.y = obj.getroivals('project',@mean,true,...
                                            'roi',    roiIdx,...
                                            'slice',  slIdx,...
                                            'series', seIdx,...
                                            'tag',   'roi');
                end

                % Fit the ROI data (get VIF if appropriate)
                if any( strcmpi(obj.type,{'dce','dsc'}) )
                    mObj.get_vif;
                end
                mObj.fit;

                % Verify that the model fit
                fitResults = mObj.results;
                if isempty(fitResults)
                    warning(['QUATTRO:' mfilename ':failedModeling'],...
                                        'Unable to fit data. Aborting summary');
                    endPos = [];
                    return
                end

                % Write data
                fprintf(fid,'%s/%d\t\t%d\t%s',exId,...
                                              serId,...
                                              slIdx,...
                                              roiSub(slIdx,seIdx).name);
                for prmIdx = 1:numel(prms)
                    u = fitResults.(prms{prmIdx}).convert( prmUnits{prmIdx} );
                    fprintf(fid,'\t\t%f',u.value);
                end
                fprintf(fid,'\t\t%f',mObj.results.RSq.value);
                fprintf(fid,'\n');
            end %slice loop
        end %roi loop

        if isempty(s)
            endPos = ftell(fid);
            return
        end

        % Calculate ROI average values over maps
        for roiIdx = 1:10
            for slIdx = 1:length(s) %Map loop (e.g. S.I., kTrans, etc.)

                % Stores the contour name
                data{end+1,1} = [obj.roi.name{roiIdx} '--' getMapName(s{slIdx})];

                % Get series indices
                if slIdx==1 %pixel value case
                    series_inds = 1:hdrs('size',2);
                else
                    series_inds = 1;
                end

                for k = series_inds %series loop

                    % Stores column titles 
                    data{end+1,1} = ['Series ' num2str(k)];
                    if k==min(series_inds)
                        [data{end,2:7}] = deal('Mean','Std. Dev.','COV',...
                                               'Kurtosis','NaN Ratio','Area');
                    end

                    for l = 1:hdrs('size',1) %slice loop
                        mask = obj.roi.get_mask('size',m_mask,...
                                                          'index',{roiIdx,l,k});
                        if isempty(mask)
                            data{end+1,1} = ['Slice ' num2str(l)];
                            continue
                        end

                        % Get the appropriate image/map
                        if slIdx==1 %pixel value case
                            im = double(headers.user.exams.img.images{l,k});
                        else
                            im = (overlays('get',l,map_names{slIdx}));
                        end
                        if isempty(im)
                            data{end+1,1} = ['Slice ' num2str(l)];
                            continue
                        end

                        % Store ROI values
                        roi_vals = im(mask);

                        % Stores row title and values
                        vals = roi_vals(~isnan(roi_vals) & ~isinf(roi_vals));
                        [data{end+1,1:7}] = deal(['Slice ' num2str(l)],...
                                                  mean(vals),std(vals),...
                                                  std(vals)/mean(vals)*100,...
                                                  kurtosis(vals),...
                                                 (numel(roi_vals)-numel(vals))/numel(roi_vals),...
                                                  numel(roi_vals));
                    end %slice
                end %series
            end %data type
        end %roi

        % Default save
        if ~isnumeric( file_name )
            xlswrite([file_name 'xls'], data_summary);
            save([file_name 'mat'],'AllData');
        else
            xlswrite( [directory strtok( file_name, '.' ) '.xls'], data_summary );
        end

    end %report_rois


    % ROI pixel series reporting function
    function endPos = report_pixel_series

        % Create a modeling object
        mObj = eval([obj.types{obj.exam_index} '(obj.h_q);']);
        
        % Generate ROI header
        roiHdr = ['x\ty\tz\tx_p\ty_p\tz_p\t' repmat('%f\t',1,numel(mObj.xProc))];
        roiHdr(end) = 'n'; roiHdr = sprintf(roiHdr,mObj.xProc);

        % Get/write data
        roi = obj.regions; sp = [hdr.PixelSpacing(:)' hdr.SliceThickness];
        m = size(obj.images(1,1)); se = get(obj.h_sl(2),'Value');
        for roiIdx = rIdx

            roi_hdr_written = false; %use flag to inform if header is written

            for slIdx = 1:min([obj.size('headers',1) obj.size('images',1)])
                % Get mask
                mask = obj.get_mask('size',m','index',{roiIdx,slIdx,se});
                if isempty(mask)
                    continue
                end

                % Stack the images to create the y data
                mObj.y = obj.stack_images(slIdx);

                % Write header for ith ROI
                if ~roi_hdr_written
                    dataStr = sprintf('%% ROI Name: %s\n%s\n',...
                                                      roi(roiIdx).names,roiHdr);
                    fprintf(fid,'%s',dataStr);
                    roi_hdr_written = true;
                end

                % Generate coordinates and data matrix
                [y,x] = find(mask); z = repmat(slIdx,size(x));
                c_p = pix2phys([x y z],sp); data = permute([x y z c_p],[2 1]);

                for seIdx = 1:size(mObj.yProc,3)
                    im   = mObj.yProc(:,:,seIdx);
                    data = [data; im(mask).'];
                end %series loop

                % Write pixel data to file
                w_str = ['%10.0f\t%10.0f\t%10.0f\t%5.4f\t%5.4f\t%5.4f\t',...
                                                     repmat('%5.5f\t',1,seIdx)];
                w_str(end) = 'n';
                fprintf(fid,'%s',sprintf(w_str,data));

            end %slice loop

            % Writes spacing for next ROI
            fprintf(fid,'%s',sprintf('\n\n'));

        end %ROI loop

        endPos = ftell(fid);

    end %report_pixel_series

    % VIF reporting function
    function endPos = report_vif
        % Check for VIF
        if ~any( cell2mat(obj.regions('isvif')) )
            if obj.guiWanings
                warndlg('No VIF found.','Error: No VIF');
            end
            warning(['qt_exam:' mfilename ':missingOrInvalidVif'],...
                    ['Unable to detect a valid VIF in the current exam.\n',...
                     'No VIF report was created.\n']);
            set(handles.menu_report_vif,'Enable','off');
            return
        end

        % Create a models object to create the VIF
        mObj = dce(obj.h_q,'autoShow',false);
        if isempty(mObj.vifProc)
            warndlg('Unable to compute VIF','Error: Invalid VIF');
            return
        end

        % Write VIF
        fprintf(fid,'%s\t%s\n','Time (s)','Delta S.I. (a.u.)');
        fprintf(fid,'%5.3f\t%12.8f\n',[60*mObj.xProc(:)';mObj.vif(:)']);

        endPos = ftell(fid);
    end %report_vif
end


%------------------------------
function sSort = sort_names(s)

    sSort = sort( lower(s) );

    % Revert case
    for idx = 1:length(s)
        cInd = strcmpi(s{idx},sSort);
        if any(cInd)
            [sSort{cInd}] = deal(s{idx});
        end

        % Find R^2
        if any(cInd) && sum(cInd)==1 && strcmpi(s{idx},'r_squared')
            sSort{end+1} = sSort{cInd}; %#ok
            sSort(cInd)  = [];
        elseif any(cInd) && strcmpi(s{idx},'r_squared')
            error(['QUATTRO:' mfilename ':nameChk'],'Multiple R^2 maps found');
        end
    end

end %sort_names


%------------------------------------------
function varargout = parse_inputs(varargin)

    % Set up parser
    validTypes = {'pixels','summary','vif'};
    p = inputParser;
    p.addRequired('type',@(x) any(strcmpi(x,validTypes)));
    p.addRequired('file',@ischar);
    p.addParamValue('index',[],@(x) isnumeric(x) && (any(size(x))==1));

    % Parse inputs/deal outputs
    p.parse(varargin{:});
    varargout = struct2cell(p.Results);

end