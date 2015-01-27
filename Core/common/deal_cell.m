function varargout = deal_cell(x)
%deal_cell  Deals cell contents without the cell syntax of deal

if (length(x)~=numel(x)) || (numel(x)<nargout)
    error(['QUATTRO:' mfilename ':outputChk'],...
                     'The number of outputs exceeds the number of inputs');
end

[varargout{1:nargout}] = deal(x{1:nargout});