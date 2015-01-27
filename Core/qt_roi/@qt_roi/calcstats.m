function varargout = calcstats(varargin)
%calcstats  Calculates ROI statistics
%
%   S = calcstats(VALS) static method syntax calculates the area, mean, standard
%   deviation, median, kurtosis, and NaN ratio computations, using the array of
%   numeric values VALS and returning the structure S
%
%   calcstats(OBJ) performs the computations defined above for the qt_roi object
%   OBJ using any images associated with the object. Results of the computation
%   are stored as a structure in the qt_roi property "roiStats"
%
%   S = calcstats(OBJ) performs the above computations in addition to returning
%   the results as a structure, S.
%
%   S = calcstats(OBJ,IM) calculates the ROI based statistics structure S for
%   the input image IM using the qt_roi object OBJ. The ROI is automatically
%   scaled to fit the image size. "roiStats" is not updated.
%
%   A note on arrays of qt_roi objects: although nominally supported by MATLAB,
%   calling this method with an array of objects results in computation of the
%   results for each individual ROI, not the combined ROI. Instead, use the
%   "mask" method to create a combined mask for each ROI.

    % Parse the inputs
    [im,obj,vals] = parse_inputs(varargin{:});

    %FIXME: update the following code to handle arrays of qt_roi objects
    %FIXME: the following code needs to be updated to use ISEMPTY when the
    %qt_roi method "isempty" is no longer overloaded.
    % Grab the ROI specific image values
    isStatic = (numel(obj)<1);
    if ~isStatic && (nargin==1)
        vals = obj.imgVals;
    elseif ~isStatic
        vals = obj.mask(im);
    end

    % Cast to double
    vals = double(vals(:));

    % Determine the number of NaN values (if any) and remove from the vals array
    nNan  = sum( isnan(vals) );
    vals  = vals( ~isnan(vals) );
    nVals = numel(vals);

    % Calculate the mean, area, 
    s = struct('area', nVals + nNan,...
               'kurtosis',kurtosis(vals),...
               'mean', mean(vals),...
               'median', median(vals),...
               'stdDev', std(vals),...
               'nanRatio', nNan/(nVals + nNan));

    % Either output the data to the user or store it in the qt_roi "roiStats"
    % property. The last condition on the if statement (i.e. ~isempty(vals))
    % determines if the ROI is attached to an image
    if ~isStatic && (nargin==1) && ~isempty(vals)
        hIm   = findobj(obj.roiViewObj.hAxes,'Tag','image');
        imTag = get(hIm,'Tag');
        if isempty(imTag) %this is necessary for stand-alone functionality
            imTag = 'image';
        end
        obj.roiStats.(imTag) = s;
    else
        varargout{1} = s;
    end

end %qt_roi.calcstats


%------------------------------------------
function varargout = parse_inputs(varargin)

    % Validate the number of inputs
    narginchk(1,2);

    % Set up the parser object
    parser = inputParser;

    % Determine if the user is trying to use the static method
    if strcmpi( class(varargin{1}), 'qt_roi' )
        parser.addRequired('obj',@(x) numel(x)>0);
        parser.addOptional('image',[],@isnumeric);
        parser.addOptional('vals',[]); %there will never be a third input. This
                                       %is just a placeholder for the output
    else
        narginchk(1,1); %there should be only one input with the static syntax
        parser.addRequired('vals',@isnumeric);
        parser.addOptional('obj',qt_roi.empty(1,0)); %output placeholder
        parser.addOptional('image',[]);              %output placeholder
    end

    % Parse the input and deal the outputs
    parser.parse(varargin{:});
    varargout = struct2cell(parser.Results);

end %parse_inputs