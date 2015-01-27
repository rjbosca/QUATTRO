function headers = synth_headers(headers)
%synth_headers  Synthesizes missing DICOM fields
%
%   h = synth_headers(h) synthesizes missing DICOM fields in the header
%   structure, h. Fields include:
%
%       WindowLevel
%       WindowWidth


flds = {'WindowCenter','WindowWidth'};

for i = 1:length(headers)
    for j = 1:length(flds)
        if ~isfield(headers(i),flds{j}) || isempty(headers(i).(flds{j}))

            % Determine what to do
            switch flds{j}
                case {'WindowLevel','WindowWidth'}
                    im_min = headers(i).SmallestImagePixelValue;
                    im_max = headers(i).LargestImagePixelValue;
                    headers(i).WindowCenter = round( (im_max-im_min)/2 );
                    headers(i).WindowWidth = round( im_max-im_min );
            end
        end
    end
end