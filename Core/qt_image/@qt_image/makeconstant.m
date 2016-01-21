function obj = makeconstant(imSize,val)
%makeconstant  Creates an uniform image
%
%   OBJ = makeconstant(SIZE,VAL) creates a qt_image object for an image of with
%   dimensions specified by SIZE using the value VAL for all voxels.

    % Construct an image object using the "sparse" syntax
    imObj = image2d(imSize,val);

    % Construct a qt_image image object that will house the image data and store
    % the image object
    obj        = qt_image;
    obj.imgObj = imObj;

end