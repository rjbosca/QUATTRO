function s = getPopupMenu(varargin)
%getPopupMenu  Return name of the pop-up menu or listbox selection
%
%   S = getPopupMenu(h) returns the string currently selected by pop-up menu
%   with handle H. H can also be an array of handles in which case S will be a
%   cell array of strings.
%
%   I = getPopupMenu(h,name) returns the index of the string specified in name.
%   Name can also be a cell array of strings, but H must be a scalar.

    % Parse inputs
    [h,n_chk] = parse_inputs(varargin{:});

    % Get names from all specified handles
    [n,ind] = deal(cell(size(h)));
    for i = 1:length(h)
        [n{i},ind{i}] = deal_cell( get(h(i),{'String','Value'}) );
    end

    % Remove empty pop-up menus
    rm_ind      = ~cellfun(@iscell,n);
    n(rm_ind)   = [];
    ind(rm_ind) = [];

    if isempty(n)
        s = [];
    elseif ~isempty(n_chk{1})
        s = cellfun(@(x) strcmpi(x,n{1}),n_chk, 'UniformOutput',false);
        s = find( cell_or(s) );
    else
        s = cellfun(@(x,y) x{y}, n,ind, 'UniformOutput',false);
    end
    if numel(s)==1 && iscell(s)
        s = s{1};
    end

end %getPopupMenu


%------------------------------------------
function varargout = parse_inputs(varargin)

    % Set up parser
    parser = inputParser;
    parser.addRequired('h',@(x) all(ishandle(x)) &&...
                                          all(strcmpi(get(x,'Style'),'Popupmenu')));
    parser.addOptional('names',{''},@(x) ischar(x) ||...
                                            (iscell(x) && all(cellfun(@ischar,x))));

    % Parse/deal inputs
    parser.parse(varargin{:});
    varargout = struct2cell(parser.Results);
    if ~iscell(varargout{2})
        varargout{2} = varargout(2);
    end
    if numel(varargout{1}) > 1 && numel(varargout{2}) > 1
        error(['QUATTRO:' mfilename ':inputChk'],...
                         'Number of handles and check names cannot both exceed 1.');
    end

end %parse_inputs