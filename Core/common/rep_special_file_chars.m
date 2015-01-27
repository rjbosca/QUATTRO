function s = rep_special_file_chars(s)
%rep_special_file_chars  Replaces system reserved characters.
%
%   s = rep_special_file_chars(s) replaces all system reserved characters
%   in the string or cell array of strings, s, with an empty string.

% Input compatability
is_convert_out = ~iscell(s) && ischar(s);
if is_convert_out
    s = {s};
end

% Remove special characters
s = cellfun(@rep_chars,s,'UniformOutput',false);

% Output compatability
if is_convert_out
    s = s{1};
end


function s = rep_chars(s)

% Special characters
s = strrep(s,'<','');
s = strrep(s,'>','');
s = strrep(s,':','');
s = strrep(s,'"','');
s = strrep(s,'/','');
s = strrep(s,'\','');
s = strrep(s,'|','');
s = strrep(s,'?','');
s = strrep(s,'*','');

% Reserved names (Windows)
is_invalid = any( strcmpi(s,{'CON','PRN','AUX','NUL','COM1','COM2',...
                             'COM3','COM4','COM5','COM6','COM7','COM8',...
                             'COM9','LPT1','LPT2','LPT3','LPT4','LPT5',...
                             'LPT6','LPT7','LPT8','LPT9'}) );
if is_invalid
    error([mfilename ':strChk'],'Invalid string: windows reserved device name.');
end