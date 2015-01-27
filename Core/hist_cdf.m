function y = hist_cdf(im)

    imMin = min(im(:));
    imMax = max(im(:));

    % Calculate the cumulative density function (CDF)
    y = zeros(numel( unique(im(:)) ),1);
    for idx = imMin:imMax

        y(idx+imMin+1) = sum( im(:)<idx );

    end

    % Calculate the PDF from the CDF
    y = gradient(y);

end %hist_cdf