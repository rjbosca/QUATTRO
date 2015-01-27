function im = addmrinoise(im,sig)
%addmrinoise  Adds uniform noise to an image
%
%   I = addmrinoise(I,SIG) adds zero-mean Gaussian noise with standard deviation
%   SIG to the image I. Two random variables are generated for each "channel"
%   and added in quadrature

    % Determine the image size and create a function handle for generating a
    % random variable
    m  = size(im);
    rn = @(s) s*randn(m);

    % Add the random noise in quadrature
    im = sqrt( (double(im)+rn(sig)).^2 + rn(sig).^2 );

end %addmrinoise