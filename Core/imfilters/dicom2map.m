function im = dicom2map(im,slp,b,useNan)
%dicom2map  Converts a DICOM image (uint16) to a floating-point image
%
%   dicom2map(I,M,B) converts the DICOM image I to a floating-point image using
%   the 'RescaleSlope' (M) and 'RescaleIntercept' (B) tags
%
%   dicom2map(...ISNAN) performs the conversion as described previously,
%   converting all image values of 0 to a NaN

    % Type cast and add the NaN values
    im = double(im);
    if useNan
        im(im==0) = NaN;
    end

    % Rescale the image values
    im = im*slp + b;

end %dicom2map