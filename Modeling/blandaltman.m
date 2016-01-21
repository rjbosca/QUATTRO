function [x,y,ad,loa] = blandaltman(y1,y2,useMed)
%blandaltman  Calculates Bland-Altman summary statistics
%
%   [X,Y,AD,LOA] = blandaltman(Y1,Y2) performs a Bland-Altman analysis on the
%   vectors of measurements Y1 and Y2, where LENGTH(Y1)==LENGTH(Y2). Where the
%   outputs are:
%
%       Outputs:
%       -------------------
%       X - average of paired measurements
%
%       Y - differnece (Y1-Y2) of paired measurements
%
%       AD - average of differences (i.e. <Y>)
%
%       LOA - limits of agreement
%
%
%   [...] = blandaltman(Y1,Y2,TRUE) calculates the limits of agreement, using
%   the median in lieu of the mean and the 2.5th and 97.5th percentiles. This is
%   often useful when the underlying distribution is known to be non-normal.
%   blandaltman(Y1,Y2,FALSE) is the same as the first syntax.

    % Validate optional third input
    if (nargin==2)
        useMed = false;
    else
        useMed = logical(useMed);
    end

    % Calculate the differences, average difference, and limits of agreement
    if ~useMed
        x   = mean([y1(:)';y2(:)']);
        y   = (y1(:)-y2(:));
        ad  = mean(y);
        loa = [ad-1.96*std(y),ad+1.96*std(y)];
    else
        x   = median([y1(:)';y2(:)']);
        y   = (y1(:)-y2(:));
        ad  = median(y);
        loa = [ad+prctile(y,2.5),ad+prctile(y,97.5)];
    end

end %blandaltman