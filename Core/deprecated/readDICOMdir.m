function f_details = readDICOMdir(s_dir, varargin)
%readDICOMdir  Reads all DICOM headers in a directory
%
%   hdrs = readDICOMdir allows the user to specify a directory containing
%   the DICOM files from a single exam
%
%   hdrs = readDICOMdir(dir) reads in all DICOM headers from the DICOM
%   headers contained in the direcotry specified by dir

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize output
f_details = struct([]);

%ERROR CHECK: (1) no input directory => user gets directory, (2) terminates
%if the user cancels the action, (2) directory must exist
if ~exist( 's_dir', 'var' )
    s_dir = uigetdir;
end
if isnumeric( s_dir )
    return
end
while ~isdir( s_dir )
    getDir = uigetpref( 'Directory', 'getnewdir', 'Directory not found',...
        {'The specified directory could not be found.'
         ''
         'Would you like to choose a different directory?'},...
         {'Yes', 'No'} );
     if strcmpi( getDir, 'yes' )
         s_dir = uigetdir;
     else
         return
     end
     
end

%A test parameter can be defined to ensure that the images being loaded
%contain particular values. For example, specifying StudyID as the
%property and the value as property value forces readDICOMdir to check
%each DICOM header for the specified StudyID.
if exist( 'varargin', 'var' ) && ~isempty( varargin )
    if mod( length( varargin ), 2 ) == 0
        varargin = reshape( varargin, 2, [] );
    else
        errordlg( {'DICOM Property or PropertyValue are imporperly defined.',...
                   'Error checking is now suppressed.'} );
        clear varargin
    end
end

%Generates the list of files in the specified directory.
f_list = dir( s_dir ); f_list(1:2) = [];

%Determines if a multi-directory exam is being loaded
is_multi_dir = all( cell2mat({f_list.isdir}) );
if is_multi_dir
    f_details = loadMultiDir(s_dir);
    noImageError(f_details);
    return
end

% Removes directories and initializes wait bar/loop variables
f_list( cell2mat({f_list.isdir}) ) = [];
imageProg = waitbar(0, '0% Complete', 'Name', 'Loading DICOM headers.');
tag_edwi = dicomlookup('0043','107F'); is_fixed = false;
m = size(f_list,1);

% Attempt to determine manufacturer
for i = m:-1:1
    f_name = [s_dir filesep f_list(i).name ];
    if isdicom( f_name )
        hdr = dicominfo( f_name );
    else
        f_list(i) = [];
    end
end
mfg_tag = dicomlookup('0008','0070');
if strcmpi(hdr.(mfg_tag),'siemens')
    dicomdict('factory');
elseif strcmpi(hdr.(mfg_tag),'ge medical systems')
    dicomdict('set',which('gems-dicom-dict.txt'));
end

try
    for i = 1:m

        waitbar( i/m , imageProg, [num2str( round(i/m*100) ) '% complete'] );

        f_name = [s_dir filesep f_list(i).name ];
        if isdicom( f_name )
            hdr = dicominfo( f_name );

            % This is a pain in the ass! EDWI requires the following code.
            if ~is_fixed && isfield(hdr,tag_edwi) && i~=1
                [f_details.(tag_edwi)] = deal(0);
                is_fixed = true;
                % Reoder fields
                f_details = orderfields(f_details,hdr);
            elseif is_fixed && ~isfield(hdr,tag_edwi)
                hdr.(tag_edwi) = 0;
                hdr = orderfields(hdr,f_details);
            end

            % Stores the temporary header
            try
                f_details(i) = hdr;
            catch ME
                valid_errs = {'MATLAB:heterogeneousStrucAssignment',...
                              'MATLAB:heterogenousStrucAssignment'};
                if any( strcmpi(ME.identifier,valid_errs) )
                    if isempty(f_details)
                        f_details = hdr;
                    elseif any(~isfield(f_details,fieldnames(hdr)))
                        fld_names = fieldnames(hdr);
                        f_ind = ~isfield(f_details,fld_names);
                        fld_names = fld_names(f_ind);
                        for j = 1:length(fld_names)
                            for k = 1:length(f_details)
                                f_details(k).(fld_names{j}) = hdr.(fld_names{j});
                            end
                        end
                    elseif any(~isfield(hdr,fieldnames(f_details)))
                        fld_names = fieldnames(f_details);
                        f_ind = ~isfield(hdr,fld_names);
                        fld_names = fld_names(f_ind);
                        for j = 1:length(fld_names)
                            hdr.(fld_names{j}) = f_details(1).(fld_names{j});
                        end
                    end

                    % Combines the headers
                    hdr = orderfields(hdr,f_details);
                    f_details(i) = hdr;

                else
                    throw(ME)
                end
            end

            %Checks each image against the test condition if specified.
            if exist( 'varargin', 'var' ) && ~isempty(varargin)
                for j = 1:size( varargin, 2 )

                    %This if statement ensures that the classes of each object 
                    %match so they can be compared.
                    if ~strcmp( class( f_details(i).(varargin{1,j}) ), class( varargin{2,j} ) )
                        if isa( varargin{2,j}, 'char' )
                            varargin{2,j} = str2double( varargin{2,j} );
                        elseif isa( varargin{2,j}, 'numeric' )
                            varargin{2,j} = num2str( varargin{2,j} );
                        else
                            contAns = questdlg( [varargin{1,j} ' cannot be checked.' 'Continue?'], 'Error', 'Yes', 'No', 'Yes' );
                            switch contAns
                                case 'Yes'
                                    continue
                                otherwise
                                    f_details = [];
                                    close( imageProg )
                                    return
                            end
                        end
                    end

                    %Compares the file values against the test condition. At
                    %this point, varargin{2,j} must be either a character or
                    %number.
                    if isa( varargin{2,j}, 'char' )
                        if ~strcmp( f_details(i).(varargin{1,j}), varargin{2,j} )
                            contAns = questdlg( [varargin{1,j} ' does not match the DICOM image. Choose a different directory? '], 'Different DICOM Image', 'Yes', 'No', 'Yes');
                        else
                            continue
                        end
                    elseif isa( varargin{2,j}, 'numeric' )
                        if f_details(i).(varargin{1,j}) ~= varargin{2,j}
                            contAns = questdlg( [varargin{1,j} ' does not match the DICOM image. Choose a different directory?'], 'Different DICOM Image', 'Yes', 'No', 'Yes' );
                        else
                            continue
                        end
                    else
                        continue
                    end
                    switch contAns
                        case 'Yes'
                            delete( imageProg );
                            f_details = readDICOMdir( [], varargin );
                            return
                        otherwise
                            f_details = [];
                            delete( imageProg )
                            return
                    end

                end

            end

        end
    end
catch ME
    valid_errs = {'MATLAB:waitbar:InvalidSecondInput'};
    if ~any( strcmpi(ME.identifier,valid_errs) )
        throw(ME)
    end
end

% Deletes the waitbar/checks for loaded images
delete( imageProg )
noImageError(f_details);


%-----------------------------------------
function headers = loadMultiDir(s_dir)

% Stores all sub-directories
d_info = dir(s_dir); d_info(1:2) = [];
d_info( ~cell2mat({d_info.isdir}) ) = [];

% Loads all data from all directories
headers = cell(length(d_info),1);
for i = 1:length(d_info)
    new_path = [s_dir filesep d_info(i).name filesep];
    headers{i} = readDICOMdir(new_path);
end

% Convert to a single structure
try
    headers = cell2mat(headers); headers = headers(:);
catch ME
    headers = [];
    switch ME.identifier
        case 'MATLAB:cell2mat:InconsistentFieldNames'
        case 'MATLAB:catenate:dimensionsMismatch'
    end
end


%-----------------------------------
function tf = noImageError(test_var)

% Initialize
tf = false;

%ERROR CHECK: (1) Empty test_var => no DICOM images
if isempty( test_var )
    errordlg( 'No DICOM images were found.' );
    tf = true;
end