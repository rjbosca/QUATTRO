function varargout = r_link(varargin)
% r_link  Provides linkage to Rscript
%
%   tf = r_link determines if R is installed and all environment variables are
%   properly configured to run Rscript, returning false if r_link is unable to
%   properly run Rscript.
%
%   S = r_link(SCRIPT) runs the R script specified by the file name SCRIPT,
%   returning the captured command prompt output. The specified file must
%   contain the full path or reside on the MATLAB path. Any errors detected in
%   the execution of the R script will subsequently throw an error in MATLAB.

% Initialize the output
[varargout{1:nargout}] = deal([]);

% Parse the inputs
[script] = parse_inputs(varargin{:});

% Validate the R install
str = evalc('!Rscript');
tf  = ~strcmpi(str(1:25),'''Rscript'' is not recognized');
if ~nargin
    varargout{1} = tf;
    return
elseif nargin && ~tf
    error('r_link:missingRscript','%s\n%s\n',...
                                  'Unable to execute Rscript. Please ensure',...
                                  'Rscript on your SYSTEM''s path');
end

% Execute the script
str = evalc(sprintf('!Rscript "%s"',script));
if ~isempty(strfind(str,'Execution halted'))
    errIdx = strfind(str,'Error');
    error('r_link:Rhalted','%s',str(errIdx:end));
end

% Deal the outputs
varargout{1} = str;


%------------------------------------------
function varargout = parse_inputs(varargin)

% Create the parser
parser = inputParser;
parser.addRequired('file',@(x) exist(x,'file'));

% Parse and get the values
parser.parse(varargin{:});
vals = struct2cell(parser.Results);

% R uses the file separator "/" not "\"
vals{1} = strrep(vals{1},'\','/');

% Deal the outputs
[varargout{1:nargout}] = deal(vals{:});