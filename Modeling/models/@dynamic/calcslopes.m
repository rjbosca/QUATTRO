function calcslopes(obj)
%calcslopes  Calculates kinetic information using curve slopes
%
%   calcslopes(OBJ)

    if ~obj.isReady.dynamic
        return
    end

    % Initialize common variables
    x  = obj.xProc;
    y  = obj.yProc;
    mY = size(y);

    % Since the time-to-peak is needed in computing the slopes, request results
    % or create them
    if ~isfield(obj.results,'TTP')
        obj.calcpeak;
    end
    ttp = obj.results.TTP.value;

    % Because the uptake slope will depend on the time-to-peak the algorithm is
    % as follows: for each TTP, calculate all uptake and washout slopes on a per
    % voxel (if map computation) basis
    [washSlp,upSlp] = deal( nan(mY(2:end)) );
    for tPeak = unique(ttp(:))'

        % Determine the actual index of the TTP
        peakIdx = find(x==tPeak);

        % Deteremine the post-contrast/pre-recirculation indices that must be
        % searched to find the peak signal
        tPost              = ~obj.preInds & obj.firstPassInds;
        tUp                = tPost;
        tUp(peakIdx+1:end) = false; %remove post-peak frames from bitmask
        tWash              = tPost & (x>=peakIdx);

        % For each of the voxels with this TTP, calculate the uptake and washout
        % slopes
        for idx = find(ttp==tPeak)'
            washSlp(idx) = olsfi(x(tWash)-x(peakIdx),...
                                 y(tWash,idx),y(peakIdx,idx));
            upSlp(idx)   = olsfi(x(tUp)-x(peakIdx),...
                                 y(tUp,idx),y(peakIdx,idx));
        end

    end


    % Convert from the peak time to the time vector index
%     peakIdx = nan( mY(2:end) );
%     for tPeak = unique(ttp(:))'
%         peakIdx(ttp==tPeak) = find(x==tPeak);
%     end

    %------------
    %   Slopes
    %------------

%     [washSlp,upSlp] = deal( nan(mY(2:end)) );
%     for idx = 1:prod( mY(2:end) )
% 
%         % Deteremine the post-contrast/pre-recirculation indices that must be
%         % searched to find the peak signal
%         tPost              = ~obj.preInds & obj.firstPassInds;
%         tUp                     = tPost;
%         tUp(peakIdx(idx)+1:end) = false; %remove post-peak frames from bitmask
%         tWash              = tPost & (x>=peakIdx(idx));
% 
%         % Calculate the washout slope (shift the x values to force the OLS fit
%         % through the maximum signal time point)
%         washSlp(idx) = olsfi(x(tWash)-x(peakIdx(idx)),...
%                              y(tWash,idx),y(peakIdx(idx),idx));
%         upSlp(idx)   = olsfi(x(tUp)-x(peakIdx(idx)),...
%                              y(tUp,idx),  y(peakIdx(idx),idx));
% 
%     end

    % Add the results
    obj.addresults('WashoutSlope',washSlp);
    obj.addresults('UptakeSlope',upSlp);

    % Calculate the kinetic flag for the washout slope. Defined as:
    %
    %   -1 for a 10% (or greater) drop in peak signal
    %    0 for less than a 10% change in peak signal
    %    1 for a 10% (or greater) increase in peak signal
%    washKin = 0;
%    if (kin>0.1)
%        washKin = 1;
%    elseif (kin<0.1)
%        washKin = -1;
%    end

    
end %dynamic.calcslopes