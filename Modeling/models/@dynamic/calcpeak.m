function calcpeak(obj)
%calcpeak  Calculates the peak information
%
%   calcpeak(OBJ) calculates the signal enhancement ratio (SER) and time-to-peak
%   (TTP) using the current properties of the the dynamic (or sub-classed)
%   object, OBJ. The computations are stored in the "results" property.

    if ~obj.isReady.dynamic
        return
    end

    % Initialize common variables
    y  = obj.y;
    mY = size(y);

    % Deteremine the post-contrast/pre-recirculation indices that must be
    % searched to find the peak signal
    tPost = ~obj.preInds & obj.firstPassInds;
    x     = obj.x(tPost);

    % Determine the value of Y at the peak, only searching within the
    % specified temporal window, and the index of the peak
    [yPeak,ttpInds] = max( y(tPost,:), [], 1 );
    ttpInds         = reshape(ttpInds,[mY(2:end) 1]); %add the trailing 1 to
                                                    %ensure that single data
                                                    %fits don't error

    % Convert the time-to-peak index to the actual time and add the results
    ttp = nan( size(ttpInds) );
    for ttpIdx = unique(ttpInds(:))'
        ttp(ttpInds==ttpIdx) = x(ttpIdx);
    end
    obj.addresults('TTP',ttp);

    % Calculate the signal enhancement ratio and add the results
    ser = squeeze( yPeak./ mean(y(obj.preInds & obj.subset,:),1) );
    ser = reshape(ser,[mY(2:end) 1]);
    obj.addresults('SER',ser);

end %dynamic.calcpeak