function varargout = qt_uiputfile(varargin)
%qt_uiputfile  QUATTRO wrapper for uiputfile
%
%   [FILE,OK] = qt_uiputfile(FILTERSPEC,TITLE,DFILE) presents the user with an
%   interactive file dialog box using the file filter specification FILTERSPEC,
%   dialog box TITLE, and default file name DFILE. The full file name, FILE, is
%   returned in addition to a logical value, OK, is true if the user provided a
%   usable file name.
%
%   [...,FILTERINDEX] = qt_uiputfile(...) performs the above described operation
%   in addition to returning the index of the filter specification selected by
%   the user.
%
%   See also uiputfile

    % Send the inputs through uiputfile
    [fName,fPath,fIdx] = uiputfile(varargin{:});

    % Validate the selected file, dealing an empty string to both if none was
    % selected, concatenating whatever resulted and storing in the output
    varargout{2} = true;
    if isnumeric(fName) || isnumeric(fPath)
        [fName,fPath] = deal('');
        varargout{2}  = false;
    end
    varargout{1} = fullfile(fPath,fName);

    % Pass the filter specification index if requested
    if nargout>2
        varargout{3} = fIdx;
    end

end %qt_uiputfile