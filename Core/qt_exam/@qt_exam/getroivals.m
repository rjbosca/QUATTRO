function [y,roiMask] = getroivals(obj,varargin)
%getroivals  Returns pixel values in an ROI
%
%   [A,M] = getroivals(OBJ) gets all pixels of the currently selected ROI as the
%   numeric vector A from the QT_EXAM object OBJ. An optional output of the bit
%   mask (M) used to derive the voxels values can be requested. This syntax is
%   the same as getroivals(OBJ,'roi')
%
%   [...] = getroivals(OBJ,TYPE) gets ROI valus using one of the following
%   methods specified by the string TYPE:
%
%       Type            Description
%       ----------------------------
%       'roi'           Returns image voxel values from the current ROI
%                       selection at the specified imaging volume slice/series
%                       location
%
%       'voi'           Returns voxel values from the current ROI selection for
%                       all ROIs at the current series location across all slice
%                       locations. When using this voxel extraction method,
%                       getroivals first attempts to determine if the given ROI
%                       is on all series using the ROIs at each location to
%                       extract voxels. If this operation fails, the first
%                       instace (within the series) is projected through the
%                       series.
%
%       'pixel'         Returns the current pixel location valuse from all
%                       images in the series.
%
%       'project'       Returns voxel values from the current ROI selection
%                       projected through the imaging series. This will return
%                       an m-by-n array of m voxels values at the n series
%                       locations
%
%       'projectvol'    Returns voxel values from the current volume selection
%                       projected through the imaging series. This will return
%                       an m-by-n array of m voxels values at the n series
%                       locations. 
%
%       'label'         Returns voxel values from the current ROI selection at
%                       each of the series locations, returning an m-by-n cell
%                       array. IMPORTANT: this requires that the ROI selection
%                       exist at each series location
%
%   [...] = getroivals(...,FCN) calculates the ROI values as specified above,
%   performing the operations specified by the function handle (or cell array of
%   function handles) FCN. If FCN is a cell, A will be an n-by-1 cell array.
%
%   [...] = getroivals(...FCN,RMNAN) removes NaN values from the ROI voxels used
%   in all computations if the RMNAN flag is true. An empty array (i.e. []) can
%   be used for FCN if no computation is desired. RMNAN is ignored when using
%   the 'pixel' option
%
%   [..] = getroivals(...,'PROP1',VAL1,...) calculates the ROI values according
%   to the method and user defined operations, using the ROI specified by the
%   location properties and the associated index. 'PROP' is one of 'slice',
%   'series', 'roi', or 'tag'

    % Validate the number of inputs and the QT_EXAM object size
    narginchk(1,13);
    if (numel(obj)>1)
        error(['qt_exam:' mfilename ':tooManyObjects'],...
               'The "%s" method must be called on a scalar qt_exam object.\n',...
               mfilename);
    end

    % Parse inputs
    [fcns,method,rmNaN,tag,inds] = parse_inputs(varargin{:});

    % Initialize output. An empty cell is stored to ensure that the cellfun
    % calls below work without having to check for an empty data set
    y = {};
    roiMask = false(obj.image.dimSize);
    if ~isfield(obj.rois,tag)
        return
    end

    % Get some necessary info
    mIm  = obj.image.dimSize;
    nIms = size(obj.imgs,2);
    mRoi = size(obj.rois.(tag));
    if (numel(mRoi)<3)
        mRoi(3) = 1;
    end
    %TODO: determine how to get the VOI computation info
    isVol = false;

    % Special case for VOI
    if strcmpi(method,'roi') && isVol
        method = 'voi';
    end

    % Validate that the indices are within the bounds of the ROI stack, and use
    % them to grab the current ROI
    if ~strcmpi(method,'pixel')
        if (any(mRoi<1) || any(mRoi<[inds{:}]))
            warning(['qt_exam:' mfilename],'No ROI exists at this location');
            return
        end
        roi = obj.rois.(tag)(inds{:});
        if ~any(roi.validaterois)
            return
        end
    end

    % Get pixel values
    switch method
        case 'roi'
            % Get data from axes and pixel values. Because applying the
            % user-specified functions make use of the cellfun function the
            % variable "y" must be a cell array (hence the curly brackets).
            %TODO: determine how to switch between quantifying maps/images
            if (numel(roi)==1) && ~isempty(roi.imgVals)
                y = {roi.imgVals};

                % When requested, also supply the mask
                if (nargout>1)
                    roiMask = roi.mask;
                end
            else
                
            end
        case 'voi'
    %         % Get indices
    %         s_ind = get(obj.h_list,'Value');
    %         slIdx = obj.find('regions','position',s_ind);
    % 
    %         % Get masks/pixel values
    %         for i = 1:length(s_ind)
    %             y{i} = [];
    %             for j = 1:length(slIdx)
    %                 % Get mask/pixel values
    %                 mask = obj.get_mask('size',mIm,'index',{s_ind(i) slIdx(j) seIdx});
    %                 if ~isempty(mask)
    %                     y{i} = [y{i}; obj.images(slIdx(j),seIdx,mask)];
    %                 end
    %             end
    %         end
    %         y(cellfun(@isempty,y)) = [];
    %         y = cell2mat( cellfun(@(x) x(:),y,'UniformOutput',false) );

        case 'project'
            % Gets the ROI-averaged value for the current, selected ROI on
            % every point in the series
            roiMask = roi.mask;

            y = arrayfun(@(x) x.value(roiMask),obj.imgs(inds{2},:),...
                                                         'UniformOutput',false);
        case 'pixel'

            % Get the data cursor's position
            pos   = obj.voxelIdx;
            if isempty(pos)
                return
            end
            pos   = pos/obj.image.scale;
    
            % Generate multi-parameter data by looping through each serial image
            % and extracting the voxel values at the specified location
            y     = {arrayfun(@(x) x.value(pos(2),pos(1)),obj.imgs(inds{2},:))};

        case 'label'

            % Gets the ROI-averaged value for each point in the series
%             if ~obj.is_on_all_series(inds{1}(1:2))
%                 errordlg({'This ROI is not present on all points in the series.',...
%                           'Copy and Paste to All before using this option.'});
%                 return
%             end
            y = cell(1,nIms);
            for seIdx = 1:nIms
                roiMask  = obj.rois.(tag)(inds{1},inds{2},seIdx).mask;
                y{seIdx} = obj.imgs(inds{2},seIdx).value(roiMask);
            end
    end

    % Remove NaN values according to the user flag
    if rmNaN
        y = cellfun(@(vals) vals(~isnan(vals)),y,'UniformOutput',false);
    end

    % Apply user-defined functions
    if ~isempty(fcns)
        for fcn = fcns(:)'
            y = cellfun(@(data) fcns{1}(data),y, 'UniformOutput',false);
        end
    end

    % Prepare output
    if iscell(y) && (all( cellfun(@(x) numel(x)==1,y) ) ||...
                     (numel(y)==1 && isnumeric(y{1})))
        y = cell2mat(y);
    end


    %-----------------------------------Input Parser----------------------------
    function varargout = parse_inputs(varargin)

        % Parser setup
        parser               = inputParser;
        parser.KeepUnmatched = true;

        % Set up the parser and parse inputs. Since 'tag' is an optional input
        % and since the default value depends potentially on the value of 'tag',
        % parser all of the inputs except the ROI index first
        parser.addOptional('method',    'roi',@ischar);
        parser.addOptional('functions', [],@checkFcns);
        parser.addOptional('removeNans',false,@islogical);
        parser.addParamValue('tag',     obj.roiTag);
        parser.addParamValue('series',  obj.seriesIdx);
        parser.addParamValue('slice',   obj.sliceIdx);

        % Parse the inputs
        parser.parse(varargin{:});

        % Now that the value of the 'tag' option is known (the default ROI index
        % depends on this), add the new input param/value pair and parse again
        dfltTag = 'roi';
        if isfield(obj.roiIdx,parser.Results.tag)
            dfltTag = obj.roiIdx.(parser.Results.tag);
        end
        parser.addParamValue('roi',dfltTag);
        parser.parse(varargin{:});

        % Grab the parser results so data formats can be modified if necessary
        results = parser.Results;

        % Convert some of the parsed inputs to a different format
        results.index  = {results.roi,results.slice,results.series};
        results.method = validatestring(results.method,...
                                       {'roi','voi','project','pixel','label'});
        results        = rmfield(results,{'roi','slice','series'});
        if ~isempty(results.functions) && ~iscell(results.functions)
            results.functions = {results.functions};
        end

        % The default value for the ROI index uses the "roiTag" property which
        % may or may not represent the default value that should be used if the
        % user has specified the 'tag' input option

        % Deal output
        varargout = struct2cell(results);

    end %parse_inputs

end %getroivals

%-------------------------
function tf = checkFcns(f)

    tf = isempty(f);
    if ~tf && iscell(f)
        tf = all( cellfun(@(x) isa(x,'function_handle'),f) );
    elseif ~tf
        tf = isa(f,'function_handle');
    end

end %checkFcns