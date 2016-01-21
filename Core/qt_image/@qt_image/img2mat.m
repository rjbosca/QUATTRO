function y = img2mat(obj)
%img2mat  Converts an array of qt_image objects to an array of images
%
%   I = imgobj2mat(OBJ) converts the array of qt_image object OBJ to an N-D
%   array, where the dimensionality is m1-by-m2(-by-m3)-by-n1-by-n2... where m1
%   to m3 represent the size of the individual image objects and the n's are the
%   dimensions of OBJ

    %TODO: perform error checking on IDX
    % Get the requested images
    y = {obj.value};

    % Get the image size and convert the stack to an array
    m = size(y{1});
    y = cell2mat(y);
    y = reshape(y,m(1),m(2),[]);

end %qt_image.img2mat