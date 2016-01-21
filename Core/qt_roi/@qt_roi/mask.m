function vals = mask(obj,varargin)
%mask  Create or apply mask to an image
%
%   I = mask(OBJ) creates a binary mask, I, of the qt_roi object specified by
%   OBJ.
%
%	A = mask(OBJ,I) uses a qt_roi object, OBJ, to mask an image specified by I,
%	returning the image values, A. The image can be a 2D array or qt_image
%	object. ROIs are scaled to fit the image regardless of the current value of
%	the "scale" property
%
%   A = mask(OBJ,H) performs the same computation as the previous syntax using
%   the handle to an image obejct, H.

    vals = []; %initalize output

    % Parse the inputs
    I = parse_inputs(varargin{:});

    % Get the ROI scale
    if isempty(I)
        mIm = obj.scale;
    else
        mIm = size(I);
    end

    %TODO: what happens if the input ROI isn't registered with the qt_image object?
    % For image objects, simply get the image values
    if strcmpi( class(I), 'qt_image')
        vals = I.imageValues;
        return
    end

    % Grab the current ROI scale and 
    mRoi = obj.scale;

    % There are two cases to handle at this point
    if ~isempty(mRoi) && ~isempty(obj.scaledPosition)

        % Modify the new mask scale to ensure it is commensurate with the image
        % scale.
        if (numel(mIm)~=numel(mRoi)) || any(mIm~=mRoi)
            mRoi = mIm;
        end

        % Update the scale and get the mask
        vals = rois2mask(obj.scaledPosition,['im' obj.type],mRoi);

        % Grab image values if requested
        if ~isempty(I)
            vals = I(vals);
        end

    elseif isempty(mRoi)
        warning(['QUATTRO:' mfilename ':missingRoiScale'],...
                ['The QT_ROI property "scale" must be non-empty before a ',...
                 'mask can be created.']);
    end

end %qt_roi.mask


%----------------------------------
function I = parse_inputs(varargin)

    % Determine the input syntax
    if ~nargin
        I   = [];
    elseif ishandle(varargin{1})
        hIm = findobj(varargin{1},'Type','image');
        if isempty(hIm)
            error('qt_roi:mask:invalidImHandle','%s\n%s\n',...
                               'Handle inputs must be of type "image" or',...
                               'have at least one descendent of type "image".');
        end
        I   = get(hIm,'CData');
    elseif strcmpi( class(varargin{1}), 'qt_image' ) || isnumeric(varargin{1})
        I   = varargin{1};
    else
        error('qt_roi:mask:invalidInputs',...
                 'Invalid input syntax. See qt_roi.mask for more information.');
    end

end %parse_inputs