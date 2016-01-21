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

        % Newer versions of the Parallel Computing Toolbox no longer support
        % MATLABPOOL. Dichotomize the cases here
        if verLessThan('distcomp','6.6')
            nProcessors = matlabpool('size');
        else
            pool = gcp('nocreate');
            nProcessors = 0; %initialize
            if ~isempty(pool)
                nProcessors = pool.NumWorkers;
            end
        end

        % Determine the output flag
        if ~nProcessors
            parVal = 1;
        elseif (nProcessors==1)
            parVal = 2;
        else
            parVal = 3;
        end

    elseif exist('ppeval','file') && exist('np','file')
        nProcessors = np;
        if ~nProcessors
            parVal = 4;
        elseif (nProcessors==1)
            parVal = 5;
        else
            parVal = 6;
        end
    end

end %is_par