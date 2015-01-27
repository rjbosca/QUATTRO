function varargout = read_pinnacle(varargin)
%read_pinnacle  Reads a Pinnacle *.roi file
%
%   roi = read_pinnacle(s) parses a Pinnacle ROI file.
%

% Initialize output
[varargout{1:nargout}] = deal([]);

% Deal input
fName  = varargin{1};
if nargin>1
    sData = varargin{2};
else
    fid   = fopen(fName,'r');
    sData = textscan(fid,'%s','Delimiter','\n');
    fclose(fid);
end

% Finds the start/end indices for each ROI and curve details
indS = find( strcmpi('points={',sData) );
indE = find( ~cellfun(@isempty,strfind(sData,'};  // End of points') ) );
iNm = find( ~cellfun(@isempty,strfind(sData,'//  Beginning')) );
iNum = find( ~cellfun(@isempty,strfind(sData,'num_curve')) );
iClr = find( ~cellfun(@isempty,strfind(sData,'color:')) );
if (length(iNm)~=length(iNum)) || (length(iClr )~=length(iNum)) ||...
                                             (length(indS)~=length(indE))
    error([mfilename ':chkROIinfo'],...
                           'An invalid Pinnacle ROI format was detected.');
end

% Waitbar initialization
hProg = waitbar(0, '0% Complete', 'Name', 'Loading Contours');

nNm                      = length(iNm);
errorFlag                = false;
[name,color,numC,roiPts] = deal(cell(nNm,1)); 
for i = 1:nNm

    % Find the name, number of contours, and color
    [sNm,sNum,sClr] = deal(sData{iNm(i)},sData{iNum(i)},sData{iClr(i)});
    name{i}         = strtrim( sNm(regexp(sNm,':')+1:end) );
    numC{i}         = str2double( strtrim(sNum(regexp(sNum,'=')+1:end-1)) );
    color{i}        = colorlookup( strtrim(sClr(regexp(sClr,':')+1:end)) );

    % Finds lines containing the contour names; these lines precede ROI
    % coordinates definitions
    indC = find(strcmpi(['//  ROI: ' name{i}],sData));
    
    % Ensures that the number of indices in indexContour correctly matches the
    % number of expected contours.
    if ~isequal( numC{i},length(indC) )
        errorFlag = true;
        continue
    end

    % Convert the ROI coordinates to numeric values
    roiPts{i} = cell(numC{1},1);
    for j = 1:numC{i}

        % Store string of coordinates for processing
        roi = sData(indS(j) + 1:indE(j) - 1);
        
        % Remove single point contours
        if length( roi ) == 1
            errorFlag = true;
            continue
        end
        
        % Ensure closed curves (i.e. start and end point are equal)
        if ~strcmp( roi{1}, roi{end} )
            roi{end+1} = roi{1}; %#ok<AGROW>
        end
        
        % Converts strings into numeric coordinates
        roi = cell2mat( cellfun(@(x) sscanf(x,'%f %f %f'),roi,...
                                                  'UniformOutput',false) );
        roi = permute(reshape(roi,3,[]), [2 1]);

        % Store converted ROI
        roiPts{i}{j} = roi;

        % Removes duplicate coordinates
        roi = [unique(roi(1:end-1,:),'rows'); roi(end,:)];
        if size(roi,1)==1
            errorFlag = true;
            continue
        end
        
    end

    % Remove empty cells
    roiPts{i}(cellfun(@isempty,roiPts{i})) = [];

    % Updates the waitbar
    waitbar(i/nNm, hProg,...
                             [num2str( round(i/nNm*100) ) '% complete'] );
end

% Deletes the waitbar
delete( hProg );

% Find ROI file
header = find_header(fName);
if isempty(header)
    [hdrFName,ok] = cine_dlgs('use_pinnacle_header');
    if ok
        header = find_header(hdrFName);
    end        
end

% Informs the user if some data was not loaded
if errorFlag
    hMsg = msgbox( {'Some contours were not imported,',...
                     'the result of improper formatting.'});
    uiwait( hMsg );
end

% Process output
roiInfo = process_roi_raw(roiPts,name,color);

% Process Pinnacle ROI coordinates
if ~isempty(header)
    roiInfo = convert_pinnacle_coordinates(roiInfo,header);
end

% Deal output
[varargout{1:2}] = deal(roiInfo,header);


% --- Attempts to find a Pinnacle header file
function [hdr,fName] = find_header(f)

% Deal output
[hdr,fName] = deal([]);

% Get directory information
hdrInd = strfind(f,'.header');
if isempty(hdrInd)
    path       = fileparts(f);
    fList      = dir(path);
    fList(1:2) = [];
    fNames     = {fList.name};

    % Find *.header files
    hdrInd = strfind(fNames,'.header');
    hdrInd = find(~cellfun(@isempty,hdrInd));
    if isempty(hdrInd)
        return
    elseif length(hdrInd)>1
        fNames = fNames(hdrInd);
        fNames = cellfun(@(x) x(1:end-6),fNames,'UniformOutput',false);
        [hdrInd,ok] = listdlg('ListString',fNames,...
                              'Name','.header Selection',...
                              'SelectionMode','Singe',...
                              'PromptString','Select *.header');
        if ~ok
            return
        end
    end

    f = fullfile(path,fList(hdrInd).name);
end



% Load header
hdr = read_pinnacle_header(f); fName = f;


% --- Reads Pinnacle header
function hdr = read_pinnacle_header(f)

% Initialize output
hdr = [];

% Open file, scan each line, and close
fid = fopen(f,'r');
if fid == -1
    return
end
s = textscan(fid,'%s','Delimiter','\n'); s = s{1};
fclose(fid);

% Append 'hdr.' to each cell for evaluation
s = cellfun(@(x) ['hdr.' x], s, 'UniformOutput', false);

% Process lines with a ':'
s = cellfun(@process_header_string,s,'UniformOutput',false);

% Evaluate all cells of A
cellfun(@eval, s);
hdr.Filename = f;


% --- Special function for adapting header lines
function s = process_header_string(s)

% Process lines with a colon
ind = strfind(s,':');
if ~isempty(ind)
    [t r] = strtok(s,':');
    if length(r)==1
        r = '';
    else
        r = strtrim(r(2:end));
    end
    s = sprintf('%s= ''%s'';',t,r);
end

% Remove double quotes
s = strrep(s,'"','''');


% --- Process raw cells
function s = process_roi_raw(c,nm,clr)

% Generate ROI structure
s = struct('color','','coordinates',[],'name','','slice',[],'type','');
s = repmat(s,[sum(cellfun(@length,c)),1]); pos = 1;
for i = 1:length(c)
    num_c = length(c{i});
    [s(pos:num_c+(pos-1)).color] = deal(clr{i});
    [s(pos:num_c+(pos-1)).coordinates] = deal(c{i}{:});
    [s(pos:num_c+(pos-1)).name] = deal(nm{i});
    [s(pos:num_c+(pos-1)).slice] = deal(1);
    [s(pos:num_c+(pos-1)).type] = deal('impoly');
    pos = pos + num_c;
end


% --- Converts Pinnacle ROIs into DICOM image space
function r = convert_pinnacle_coordinates(r,hdr)

% Alias variables
xDim    = hdr.x_dim;
yDim    = hdr.y_dim;
zDim    = hdr.z_dim;
xStart  = hdr.x_start;
yStart  = hdr.y_start;
zStart  = hdr.z_start;
xPixdim = hdr.x_pixdim;
yPixdim = hdr.y_pixdim;
zPixdim = hdr.z_pixdim;

% Convert pixel coordinates
rCoor = {r.coordinates};

% Convert z-axis
slice = cellfun(@(x) unique(zDim-round((x(:,3)-zStart)/zPixdim)+1),...
                                                   rCoor,'UniformOutput',false);

% Convert in-plane coordinates
rCoor = cellfun(@(x) [round((x(:,1)-x_start)/xPixdim)+1 x(:,2)],...
                                                   rCoor,'UniformOutput',false);
rCoor = cellfun(@(x) [x(:,2) yDim-round((x(:,2)-yStart)/yPixdim)+1],...
                                                   rCoor,'UniformOutput',false);

% Deal to structure
[r.coordinates] = deal(rCoor{:});
[r.slice]       = deal(slice{:});

% Removes out-of-bounds data
outInd = cellfun(@(x) x<=0,slice);
r(outInd) = [];