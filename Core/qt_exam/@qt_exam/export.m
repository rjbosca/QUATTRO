function export(obj,varargin)
%export  Exports QUATTRO exam data
%
%   export(OBJ,TYPE,DIR) exports all qt_exam object (OBJ) data specified by the
%   string TYPE (see the description below) to the directory specified by DIR.
%   A unique direcotry is created before storing the data sets in various
%   sub-directories. Valid export types:
%
%       TYPE        Description
%       -----------------------
%       'images'    Exports all images as DICOMs. Any filters stored in the
%                   qt_image object pipeline are applied before writing data
%
%       'maps'      Exports all loaded maps as DICOMs. Any filters stored in the
%                   qt_image object pipeline are applied before writing data.
%
%       'rois'      Exports all loaded ROIs
%
%
%   export(...,FORMAT) exports the specified qt_exam object data using the
%   output FORMAT, which must be a supported format of the specified data type
%   (i.e. qt_image or qt_roi).

    % Validate and parse the inputs
    [dataType,outDir] = parse_inputs(varargin{:});

    % Create a unique directory name within the user-specified directory
    outDir = tempname(outDir);
    mkdir(outDir);

    % Write the data
    switch lower(dataType)
        case 'images'
        case 'maps'

            % Loop through each slice and each map, exporting the data
            seInc = 0; %series incrementer
            for mapName = fieldnames(obj.maps)'

                % Create a new directory for writing out the map data
                seDir = num2str(10000*obj.image.metaData.SeriesNumber+seInc);
                mkdir( fullfile(outDir,seDir) );

                % Write out all map data for the volume
                for slIdx = 1:numel(obj.maps)

                    % Grab the current map qt_image object
                    mapObj = obj.maps(slIdx).(mapName{1});
                    if isempty(mapObj)
                        continue
                    end

                    % Create a file name and export the data as DICOM
                    fileName = fullfile(outDir,seDir,...
                                                     sprintf('%06d.dcm',slIdx));
                    mapObj.export(fileName);

                end

                % Increment the series counter to ensure unique series numbers
                % for each map
                seInc = seInc + 1;

            end

        case 'rois'
    end

end %qt_exam.export


%----------------------------------------------
function varargout = parse_inputs(varargin)

    % Validate the number of inputs
    try
        narginchk(2,3);
    catch ME
        throwAsCaller(ME);
    end

    % Set up the parser
    parser = inputParser;
    parser.KeepUnmatched = true;
    parser.addRequired('dataType',@ischar);
    parser.addRequired('outDir',@(x) (exist(x,'dir')==7));
    %TODO: set up the parser to accept the FORMAT input

    % Parse the inputs
    parser.parse(varargin{:});
    results = parser.Results;

    % Perform some additional validation
    results.dataType = validatestring(results.dataType,{'images','maps','rois'});

    % Deal the outpus
    varargout = struct2cell(results);

end %parse_inputs