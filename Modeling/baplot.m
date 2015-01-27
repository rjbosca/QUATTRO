function h = baplot(y1,y2,varargin)
%baplot  Creates a Bland-Altman plot
%
%   baplot(Y1,Y2) performs a Bland-Altman analysis and creates the corresponding
%   plot on the data contained in the vectors Y1 and Y2. LENGTH(Y1)==LENGTH(Y2)
%
%   baplot(...,'PROP1',VAL1,...) also applies the property/value pairs to the
%   plots

    % Calculate the differences, average difference, and limits of agreement
    x        = mean([y1(:)';y2(:)']);
    y        = (y1(:)-y2(:));
    meanDiff = mean(y);
    loa      = [meanDiff-1.96*std(y),meanDiff+1.96*std(y)];

    % Create the plot of data differences and get the resulting x limits
    h  = plot(x,y,'or');
    set(get(h,'Parent'),varargin{:});
    xl = get(get(h,'Parent'),'XLim');

    % Plot the mean and limits of agreement lines
    hold on;
    h = [h;plot(xl,repmat(meanDiff,[1 2]),'k',...%mean line
                xl,repmat(loa(1),[1 2]),'--k',...%lower limit of agreement line
                xl,repmat(loa(2),[1 2]),'--k')]; %upper limit of agreement line

end %baplot