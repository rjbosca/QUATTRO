function file_name = createFileName(header,special,ext)
%CREATEFILENAME  Creates a file name from DICOM information.
%
%   NAME = createFileName(HEADER,S) creates a formatted file name (NAME)
%   from information stored in a DICOM header (HEADER). An additional
%   string, S, can be supplied, which will be used in the file name.
%
%   NAME = createFileName(...,ext) creates a file name as specified
%   previously with the extension specified by the string ext (default:
%   '.mat')

% Initializes 'special' if necessary
if ~exist('special','var')
    special = '';
end
if ~exist('ext','var')
    ext = '.mat';
end

% Gets patient ID
if isfield(header,'PatientID');
    patient_id = header.PatientID;
else
    patient_id = '';
end

% Gets exam date
if isfield(header,'StudyDate')
    study_date = header.StudyDate;
else
    study_date = '';
end

% Gets exam ID
if isfield(header,'StudyID')
    study_id = header.StudyID;
else
    study_id = '';
end

% Creates file name
if ~isempty(special)
    file_name = [patient_id '_' study_date ' (' study_id ', ' special ')' ext];
else
    file_name = [patient_id '_' study_date ' (' study_id ')' ext];
end