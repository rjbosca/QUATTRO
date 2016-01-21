function addfilter(obj,varargin)
%addfilter  Adds a qt_image pipeline filter
%
%   addfilter(OBJ,F) appends the filter specified by the function handle F to
%   the qt_image object OBJ to the "pipeline". OBJ can be a single object or
%   array of qt_image objects. Before appending to the filter to the image
%   pipeline, the filter F is tested for errors.
%
%   A note on usage: Because the filter is validated during each call to
%   "addfilter" the validation becomes computationally expensive for large
%   arrays of image objects (especially when utilizing the memory saver mode).
%   For that reason, passing an array of objects is the preferred method when
%   calling "addfilter" because the filter is only tested on the first image in
%   the array as all other images are assumed to be the same size

    % Catch multiple fliter inputs and re-evaluate the "addfilter" method using
    % cellfun (so it looks like there is only a single input)
    if nargin>2
        cellfun(@obj.addfilter,varargin{:});
    else
        fcn = varargin{1};
    end

    % Validate proper operation of the filter
    try
        imTest = zeros(obj(1).dimSize);
        imTest = fcn(imTest);
    catch ME
        rethrow(ME)
    end
    if any( size(imTest)~=obj(1).dimSize )
        error(['qt_image:' mfilename ':invalidFilter'],...
               'Image filters should not alter the image dimensions.');
    end

    % After passing validation successfully, append the new filter to the
    % processing pipeline
    for imIdx = 1:numel(obj)
        obj(imIdx).pipeline{end+1} = fcn;
    end

    % Determine if any of the images are being displayed currently. In that
    % case, update the display to ensure proper display of the filtered image
    isDisp = arrayfun(@(x) ~isempty(x.imgViewObj),obj);
    if any(isDisp(:))
        arrayfun(@(x) x.show,obj(isDisp));
    end

end %qt_image.addfilter