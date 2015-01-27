function im = mask2nan(im,mask)
%mask2nan  Applies NaN values to an image
%
%   I = mask2nan(I,M) stores NaN in I where the logical array M is true. This
%   filter is particularly use for modifying map overlays

    im(mask) = NaN;

end %mas2nan