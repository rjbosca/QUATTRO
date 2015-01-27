function import_trafo(obj,varargin)
%import_trafo  Loads registration transformation

% undocumented transformation import utility for QUATTRO. Allows the user
% to select a *.mat or *.dfile containing a transformation

if nargin>1 && exist(varargin{1},'file')
    [pName,fName,ext] = fileparts(varargin{1});
    flt = find( strcmpi(ext,{'.dfile','.mat','.txt'}) );
    if flt==3
%         btn = questdlg('Log or Iteration file?','ITK File Selection',...
%                                                            'Log','Iter','Iter');
%         if strcmpi(btn,'iter')
            flt = 4;
%         end
    end
    fName = [fName ext];
elseif nargin==1
    [fName,pName,flt] = uigetfile({'*.dfile','AFNI dfile (*.dfile)';...
                                   '*.mat','MAT-files (*.mat)';...
                                   '*.txt','ITK-log file (*.txt)';...
                                   '*.txt','ITK-iter file (*.txt)'},...
                                   'Load transformation');
end
switch flt
    case 2
        uiopen('*.mat');
        if ~exist('wc','var')
            return
        end
    case 1
        wc = {read_dfile(fullfile(pName,fName))};
    case 3
        wc = itklogread(fullfile(pName,fName));
    case 4
        wc = itkiterread(fullfile(pName,fName));
        wc = {wc{1}(end,:)};
end

if exist('wc','var') && ~isempty(wc)
    obj.wc = wc;
end