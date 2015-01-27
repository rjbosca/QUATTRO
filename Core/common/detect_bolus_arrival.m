function [frm,ok] = detect_bolus_arrival(ims)
%detect_bolus_arrival  Detect the time point of bolus arrival
%
%   T = detect_bolus_arrival(IMS) attempts to detect the bolus arrival for a DCE
%   exam using the stack of images, IMS, returning the frame number (T).
%
%   [T,OK] = detect_bolus_arrival(IMS) also returns the success flag, i.e., true
%   if the bolus time was detected by the algorithm and false otherwise

    % Get the uptake curves for all slices
    tuc = preprocess_dce_images(ims,'tc');

    % Calculate the moving average for all time points
    [tucMean,tucStd] = deal( zeros(size(tuc)) );
    for tIdx = 1:size(tuc,1)
        tucMean(tIdx) = mean(tuc(1:tIdx));
        tucStd(tIdx)  = std(tuc(1:tIdx));
    end

    % Loop from max to start of the exam
    ind = find(tuc==max(tuc),1,'first');
    for frm = 2:ind
        std_mean = mean(tucStd(1:frm));
        if tucStd(frm) > 2.5*std_mean && std_mean > 10e-6
            break
        end
    end
    frm = frm-1; %subtract 1 to buffer against capturing the initial arterial uptake

    % Infrom user if necessary
    ok = ~(isempty(frm) || frm<1 || (frm+1==ind));
    if ~ok
        frm = 4;
    end

end %detect_boluw_arrival