function varargout = qt_examples(str)

%TODO: this function should allow the user to load appropriate data into the
%workspace based on the string input by the user
switch lower(str)
    case 'vfa'
        % Send directory of VFA images to the user
        varargout{1} = fullfile( fileparts(mfilename('fullpath')), 'VFA' );
end