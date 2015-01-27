function [wc,d] = parse_itk_cmd(T)
%parse_itk  Parses the command line output from itkReg

% Write to a cell of strings
A = textscan(T,'%s','Delimiter','\n'); A = A{1};

% Parse the multi-resolution output
inds = strfind(A,'MultiResolution Level');
inds = find(~cellfun(@isempty,inds));

% Store only the last level
[d,wc] = deal( cell(1,length(inds)) );
for idx = 1:length(inds)
    n      = length(A{inds(idx)});
    strInd = strfind(T,A{inds(idx)});
    [~,d{idx},wc{idx}] = deal_cell( textscan(T(n+strInd+2:end),...
                                               '%d%f%s','Delimiter','\n') );
end

% Parse the transform
for idx = 1:length(wc)
    wc{idx} = cell2mat( cellfun(@(x) eval(x),wc{idx}, 'UniformOutput',false) );
end