function header = convert_private_dicom_fields(varargin)
%convert_private_dicom_fields  Converts "Private" DICOM fields
%
%   HDR = convert_private_dicom_fields(HDR) attempts to convert all "Private"
%   fields of the structure specified by HDR to DICOM dictionary dependent tags
%   using the current dictionary
%
%   HDR = convert_private_dicom_fields(HDR,DICT) perfroms the field conversion
%   as described previously, using the DICOM dictionary DICT in leiu of the
%   current dictionary

    % Parse the inputs
    [refDict,header] = parse_inputs(varargin{:});

    % Cache the current DICOM dictionary, which must be restored in case any
    % changes are made to reference dictionary. Update the dictionary
    curDict = dicomdict('get');
              dicomdict('set',refDict);

    % Stores the header fields that are "Private" tags
    flds = fieldnames(header);
    flds = flds(cellfun(@(x) ~isempty(x) && (x==1),strfind(flds,'Private_')) );

    % Convert header values
    for fld = flds'

        % Look up the new tag name. This does not guarantee that the new field
        % is not a "Private" field
        group             = fld{1}(9:12);
        element           = fld{1}(14:17);
        try
            newTag        = dicomlookup(group,element);
        catch ME
            if ~strcmpi(ME.identifier,'images:dicomlookup:badHex')
                rethrow(ME);
            end
            continue
        end

        % Store the data from the old field and remove the old field
        [header.(newTag)] = header.(fld{1});
        header            = rmfield(header,fld{1});

    end

    % Order fields
    header = orderfields(header);

    % Restore old dictionary
    dicomdict('set',curDict);

end %convert_private_dicom_fields


%------------------------------------------
function varargout = parse_inputs(varargin)

    % Grab the current DICOM dictionary
    curDict = dicomdict('get');

    % Create the parser
    parser = inputParser;
    parser.addRequired('header',@isstruct);
    parser.addOptional('dictRef',curDict,@(x) (exist(x,'file')==2));

    % Parse the inputs and deal the outputs
    parser.parse(varargin{:});
    varargout = struct2cell(parser.Results);

end %parse_inputs