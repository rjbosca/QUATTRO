function [bValues,vectors] = calc_diffusion(headers)
%CALC_DIFFUSION_TENSORS Calculate b-values and gradient directions.
%   [BVALS,VEC] = CALC_DIFFUSION_TENSORS(HEADERS) attempts to calculate the
%   b-values (B_VALS) and associated gradient directions (VEC) for a set of
%   diffusion exam data stored in the full dicom headers of all images
%   (HEADERS).
%
%   Note: if a diffusion weighted exam was performed, the number of vectors
%   will be less than six.

% I have notcied that for our data (i.e. DICOMs from GE scanners) the tag
% 0043x1039 seems to represent the maximum b-value for the DW and DTI images.
% This could change at any time. CARE SHOULD BE EXERCISED!

    % Store b-value tags
    tagBVals = dicomlookup('0043','1039');
    tagEdwi  = dicomlookup('0043','107F');
    tagGx    = dicomlookup('0019','10BB');
    tagGy    = dicomlookup('0019','10BC');
    tagGz    = dicomlookup('0019','10BD');

    % Initialize the outpus and ensure that all necessary fields exist
    [bValues,vectors] = deal([]);
    if any( ~isfield(headers,{tagBVals,tagEdwi,tagGx,tagGy,tagGz}) )
        return
    end

    % Calculates diffusion data
    bMags   = cell2mat( arrayfun(@get_b_mag,headers,'UniformOutput',false) );
    vectors = cell2mat( cellfun(@get_b_vec,headers,'UniformOutput',false) );

        % Get magnitude of the b-value
        function bVal = get_b_mag(hdr)

            % Determine the b-values
            bVal = hdr.(tagBVals);
            bVal = bVal(:)';

            % Determines if a conversion is necessary
            is_str = ~isfield(hdr,tagEdwi) && all(bVal<65536) &&...
                                             ~isempty( strfind( char(bVal), '\' ) );
            if is_str
                bVal = str2double(strtok( char(hdr.(tagBVals) )', '\'));
            else
                bVal = double(hdr.(tagBVals)(1));
            end

        end %get_b_mag

        function vec = get_b_vec(hdr)

            % Determines diffusion gradient field vector
            [Gx Gy Gz] = deal(hdr.(tagGx),...
                              hdr.(tagGy),...
                              hdr.(tagGz));
            if ~isinteger(Gx)
                vec = double([Gx Gy Gz]);
            else
                vec = [str2double(char(Gx)),...
                       str2double(char(Gy)),...
                       str2double(char(Gz))];
            end

        end %get_b_vec

    % Calculates/stores the b-values and vector
    if ~any(vectors(:))
        bValues = bMags;
    else
        bValues = sum(sqrt(vectors.*vectors),2) .* bMags';
    end

end %calc_diffusion