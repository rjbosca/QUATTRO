function [parVal,nProcessors] = is_par
%is_par  Check if parallel computation is supported.
%
%   FLAG = is_par determines the parallel capabilities of the host machine,
%   returning the current state in FLAG. FLAG is a numeric value with one of the
%   following meanings:
%
%     0 if parallel computation is not supported
%     1 if parallel computation through Parallel Computing Toolbox is
%          supported
%     2 if parallel computation is activated through Parallel Computing
%          Toolbox for a single processor
%     3 if parallel computatoin is activated through Parallel Computing
%          Toolbox for multiple processors
%     4 if parallel computation through Star-P is supported
%     5 if parallel computation is activated through Parallel Computing
%          Toolbox for a single processor
%     6 if parallel computation is activated through Parallel Computing
%          Toolbox for a single processor
%
%   [FLAG,NP] = is_par returns the machine state flag and the number of
%   processors currently employed

% Initialize
[parVal,nProcessors] = deal(0);

% Test parallel support
if ~isempty(ver('distcomp'))
    nProcessors = matlabpool('size');
    if nProcessors==0
        parVal = 1;
    elseif nProcessors==1
        parVal = 2;
    else
        parVal = 3;
    end
elseif exist('ppeval','file') && exist('np','file')
    nProcessors = np;
    if nProcessors==0
        parVal = 4;
    elseif nProcessors==1
        parVal = 5;
    else
        parVal = 6;
    end
end