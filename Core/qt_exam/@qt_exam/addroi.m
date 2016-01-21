function addroi(obj,roi,varargin)
%addroi  Adds a qt_roi object to a qt_exam object
%
%   addroi(OBJ,ROI) appends the QT_ROI object specified by ROI to the QT_EXAM
%   object, OBJ. The ROI is added to the qt_exam property "rois" according to
%   the qt_exam properties "sliceIdx" and "seriesIdx" and the QT_ROI properties
%   "name" and "tag" using the following algorithms:
%
%       Object/property         Storage Algorithm
%       =========================================
%       QT_EXAM/"sliceIdx"      ROI is stored at the slice location
%                               specified by "sliceIdx"
%
%       QT_EXAM/"seriesIdx"     ROI is storead at the series location
%                               specified by "seriesIdx"
%
%       QT_ROI/"name"           ROI is appended to the QT_EXAM ROI
%                               if "name" is unique, but is otherwise
%                               added to the current location of the
%                               ROI object stack with the same "name"
%
%       QT_ROI/"tag"            ROI is appended to the QT_EXAM ROI
%                               stack according to the "tag" property.
%                               The "tag" location is created if 
%                               needed
%
%
%   addroi(...,'PROP1',VAL1,...) specifies the index 'PROP1' property to be used
%   in lieu of the QT_EXAM object properties with the corresponding index value,
%   VAL1. Valid property strings are: 
%
%       String          Description
%       ===========================
%       'roi'           The ROI index is nominally determined by the
%                       QT_ROI "name" property and existing ROIs in 
%                       the QT_EXAM object stack, specifying this 
%                       property will force the input ROI to be placed
%                       at the specified location, unless this location
%                       exceeds the size of the ROI stack.
%
%                       Default: OBJ.roiTag
%
%       'slice'         Slice index at which to add the qt_roi
%                       object. 
%
%                       Default: OBJ.sliceIdx
%
%       'series'        Series index at which to add the qt_roi
%                       object.
%
%                       Default: OBJ.seriesIdx

    % Catch an array of ROIs
    roiType = class(roi);
    if (numel(roi)>1)
        error(['qt_exam:' mfilename ':tooManyRois'],...
                                          'addroi requires scalar ROI inputs.');
    elseif ~strcmpi( roiType, 'qt_roi' )
        error(['qt_exam:' mfilename ':invalidRoi'],...
                                                'ROI must be of class qt_roi.');
    end

    % Parse the inputs
    roiTag = roi.tag;
    rIdx   = parse_inputs(varargin{:});

    % The user can specify the ROI index. To ensure that ROI data is not
    % overwritten, the ROI index is first checked to ensure it is empty (or
    % exceeds the limits of the current ROI array).
    roiStack = qt_roi.empty(1,0);
    if isfield(obj.rois,roiTag) %just in case this is a special tag
        roiStack = obj.rois.(roiTag);
    end
    try %get the ROIs of interest
        roiObjs = roiStack(rIdx{1},:,:);
        name    = unique( {roiObjs(roiObjs.validaterois).name} );
    catch ME
        if ~strcmpi( ME.identifier, 'MATLAB:badsubscript' )
            rethrow(ME)
        end
        name = {};
    end

    % Determine if the input ROI has the same name as the input ROI index. For
    % example, this is the syntax used by the "pasteroi" method to ensure that
    % the copied ROI is added to the correct position within the stack. However,
    % when the "name" property of the qt_roi object does not match the name of
    % the ROI stored in the specified location, the index must be split (i.e.
    % the current and all subsequent ROIs must have their indices incremented by
    % one) to ensure no data is unnecssarily overwritten
    if ~isempty(name) && ~strcmpi(name,roi.name)
        % Expand the current ROI stack
        roiStack((rIdx{1}:size(roiStack,1))+1,:,:) = roiStack(rIdx{1}:end,:,:);

        % Remove the old qt_roi objects where the new ROI is to be stored to
        % ensure no unintentional linking between qt_roi objects occurs by
        % filling that index with empty qt_roi objects
        roiStack(rIdx{1},:,:) = qt_roi;
    end

    % Determine the ROI # at the current index
    %FIXME: this storage method is currently unsupported because of the
    %increased complexity when indexing qt_roi objects. This requires that only
    %one ROI per position (slice/series) for a given ROI index can exist at any
    %given time
%     try
    maxIdx = 1;
%         while ~roiStack(rIdx{:},maxIdx).isempt
%             maxIdx = maxIdx + 1;
%         end
%     catch ME
%         if ~strcmpi( ME.identifier, 'MATLAB:badsubscript' )
%             rethrow(ME)
%         end
%     end
    
    % Now that all error checks have been passed, add the listeners that update
    % the qt_exam object when changes are made to the ROI's "position" or "tag"
    % properties
    addlistener(roi,'position','PostSet',@obj.qtroi_position_postset);
    addlistener(roi,'tag',     'PreSet', @obj.qtroi_tag_preset);
    addlistener(roi,'tag',     'PostSet',@obj.qtroi_tag_postset);

    % Update the index number and add the ROI to the stack
    rIdx{4}           = maxIdx;
    roiStack(rIdx{:}) = roi;

    % Register the ROI with the corresponding image object
    %TODO: this will throw an error if no image exists on this slice/series
    %location or if the location exceeds the dimensions...
    obj.imgs(rIdx{2:3}).addroi(roi);

    % Store the ROI
    obj.rois.(roiTag) = roiStack;

    % After storing the ROI data, ensure that the "state" property is set
    % appropriately
    if all(obj.roiIdx.(roi.tag)~=rIdx{1})
        roi.state = 'off';
    end


    %------------------------------------------
    function varargout = parse_inputs(varargin)

        % Determine the default "roiIdx". For ROI tags other than 'roi', the
        % field might be non-existent. Moreover, since the default ROI index is
        % determined based on the QT_ROI property "name" and the current ROIs in
        % the QT_EXAM object ROI stack, see if the ROI exists and needs to be
        % appended or if a new ROI index is required
        dfltIdx = 1;
        if isfield(obj.roiIdx,roiTag) && (numel(obj.rois.(roiTag))>0)
            dfltIdx = find( strcmpi(roi.name,obj.roiNames.(roiTag)) );
            if isempty(dfltIdx)
                dfltIdx = size(obj.rois.(roiTag),1)+1;
            end
        end

        % Set up the parser
        parser = inputParser;
        parser.addParamValue('roi',dfltIdx,@(x) x>0);
        parser.addParamValue('slice',obj.sliceIdx,...
                                           @(x) (x>0) && (x<=size(obj.imgs,1)));
        parser.addParamValue('series',obj.seriesIdx,...
                                           @(x) (x>0) && (x<=size(obj.imgs,2)));

        % Parse the inputs and deal the outputs
        parser.parse(varargin{:});
        varargout = {{ parser.Results.roi,...
                       parser.Results.slice,...
                       parser.Results.series }};

    end %parse_inputs

end %addroi