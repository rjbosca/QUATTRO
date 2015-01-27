function header = convert_private_dicom_fields(header,dict)
%convert_private_dicom_fields  Converts "Private" DICOM fields
%
%   HDR = convert_private_dicom_fields(HDR) attempts to convert all "Private"
%   fields of the structure specified by HDR to DICOM dictionary dependent tags
%   using the current dictionary
%
%   HDR = convert_private_dicom_fields(HDR,DICT) perfroms the field conversion
%   as described previously, using the DICOM dictionary DICT.
%
%   **WARNING** 

    % Updates DICOM dictionary
    if nargin > 1
        currentDict = dicomdict('get');
        dicomdict('set',dict);
    end

    % Stores the header field names and find all "Private" tags
    flds = fieldnames(header);
    inds = find( cellfun(@(x) ~isempty(x) && (x==1),strfind(flds,'Private_')) )';

    % Convert header values
    for tagIdx = inds

        % Default length - 'Private_****_****'
        if length(flds{tagIdx}) ~= 17
            continue
        end

        % Look up the new tag name. This does not guarantee that the new field is
        % not a "Private" field
        group             = flds{tagIdx}(9:12);
        element           = flds{tagIdx}(14:17);
        newTag            = dicomlookup(group,element);

        % Store the data from the old field and remove the old field. Only perform
        % this operation if the new tag is different from the old tag
        if ~strcmpi(newTag,flds{tagIdx})
            [header.(newTag)] = header.(flds{tagIdx});
            header            = rmfield(header,flds{tagIdx});
        end

    end

    % Order fields
    header = orderfields(header);

    % Restore old dictionary
    if nargin > 1
        dicomdict('set',currentDict);
    end

end %convert_private_dicom_fields