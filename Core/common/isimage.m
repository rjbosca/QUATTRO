function tf = isimage(fName)
%isimage  Determines if an image is stored in a specific file
%
%   TF = isimage(FILE) attempts to determine if the file specified by the file
%   name FILE is likely an image

    if (exist(fName,'file')~=2)
        error(['QUATTRO:' mfilename ':invalidFile'],...
              '"%s" could not be found or is not a valid file.',fName);
    end

    tf = false; %initialize

    % See if the file extension can be used to determine the file format
    [~,~,fExt] = fileparts(fName);
    if ~isempty(fExt)
        s  = imformats(fExt);
        tf = ~isempty(s);
    end

    % When the file extension doesn't work, test for a DICOM image
    if ~tf
        tf = isdicom(fName);
    end

end %isimage