function vector = get_edwi_g(hdr)
%get_edwi_g  Estimates the gradient directions from eDWI exam images
%   vec = get_edwi_g(hdr) determines the direction of the diffusion
%   encoding gradient from the image header (hdr).

% Store the tag that appears to denote the diffusion direction
tag_diff_dir = dicomlookup('0021','105a');

% Store the image direction
im_dir = get_dicom_orientation(hdr);

% Determine the vector
switch hdr.(tag_diff_dir)
    case 1
        vector = [0 0 1];
    case 2
        vector = [1 0 0];
    case 3

    case 4
        vector = [0 1 0];
    case 7
        vector = [0 1 0];
    case 64
        if (im_dir==2)
            vector = [0 0 1];
        else
            vector = [1 1 1];
        end
    case 128
        vector = [1 1 1];
end