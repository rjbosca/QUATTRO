function str = mfile2package(file)
%mfile2package  Determines an M-file's containing package
%
%   PKG = mfile2package(FILE) determines the package name PKG, if any, in which
%   the file specified by the file name FILE is contained. Only the lowest level
%   package in a hierarchy of nested packages is returned

    % Initialize the output by determining the full file name if possible and
    % checking for a package directory
    file = which(file);
    str  = '';
    if ~isempty( strfind(file,'+') )

        % Grab the path components and the last instance of a package directory
        p   = textscan( fileparts(file),'%s','Delimiter',repmat(filesep,[1 2]) );
        str = p{1}{ find( ~cellfun(@isempty,strfind(p{1},'+')), 1, 'last' ) };
        str = strrep(str,'+','');

    end

end %mfile2package