function show(obj,varargin)
%show  Allows visualization of images and registration results
%
%   show displays a figure with 4 subplots containing the target, moving,
%   registered, and difference images.
%
%   show(TYPE) displays a figure as described previously except the difference
%   image is instead replaced by an image specified by the string TYPE. Current
%   options: 'difference' and 'mosaic'

% Parse inputs
opts = parse_inputs(varargin{:});

% Get the images
im1 = obj.imTarget;
im2 = obj.imMoving;
im3 = obj.transform;

% Values for normalizing
max1 = max(im1(:));
max3 = max(im3(:));

% Get the checkerboard
if strcmpi(opts,'mosaic')
    imChk = logical( checkerboard(32,obj.mTarget(1)/64,obj.mTarget(2)/64) );
    imInd = false(obj.mMoving);
end

if obj.n==2
    figure;
    subplot(2,2,1); imshow(im1,[]); title('Target');
    subplot(2,2,2); imshow(im2,[]); title('Moving');
    subplot(2,2,3); imshow(im3,[]); title('Registered')
    if strcmpi(opts,'difference')
        subplot(2,2,4); imshow(im1-im3); title('Difference')
    else
    end
else

    for sl = 1:obj.mTarget(3)
    figure;
%     sl = 10;
    subplot(2,2,1); imshow(im1(:,:,sl),[]); title('Target');
    subplot(2,2,2); imshow(im2(:,:,sl),[]); title('Moving');
    subplot(2,2,3); imshow(im3(:,:,sl),[]); title('Registered');
    if strcmpi(opts,'difference')
        subplot(2,2,4); imshow(im1(:,:,sl)-im3(:,:,sl),[]); title('Difference');
    else
        im_mosaic      = (im3(:,:,sl)-800) * (max1/max3);
        imInd(:,:,sl) = imChk;
        im_mosaic(imChk) = im1(imInd);
        subplot(2,2,4); imshow(im_mosaic,[0 500]); title('Mosiac');
        imInd(:) = false; %reset index for next slice
    end
    end
end



function varargout = parse_inputs(varargin)

% Validate display type
valid_disp = {'difference','mosaic'};
if nargin>1
    varargin{1} = validatestring(varargin{1},valid_disp);
end

% Parser set up
parser = inputParser;
parser.addOptional('dispType','difference',@ischar);

% Parse inputs and deal
parser.parse(varargin{:});
[varargout{1:nargout}] = deal_cell( struct2cell(parser.Results) );