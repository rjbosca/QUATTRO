function gd = si_ratio2gd(s1,s2,theta,TR,T10,r,flag)
%si_ratio2gd  Converts measured signal intensities to [Gd]
%
%   GD = si_ratio2gd(S1,S2,THETA,TR,T10,R) calculates the concentration of
%   contrast agent using a linear relaxivity model based on the ratio of the
%   pre- and post-contrast signal intensities, S1 and S2, respectively. S1 is an
%   1-by-N array, where N is the number of voxels, and S2 is an M-by-N array,
%   where M is the number of time pints in the series. T1 can be a scalar or a
%   vector the same size as S1. Values for which [Gd] cannot be calculated
%   (usually the result of noisy data) are returned as NaNs. The other inputs
%   are:
%
%       Input       Description (units)
%       --------------------------------
%       S1          Pre-contrast signal intensity (a.u.)
%       S2          Post-contrast signal intensity (a.u.)
%       THETA       Flip angle of the excitation pulse (deg.)
%       TR          Repitition time (ms)
%       T10         Pre-contrast T1 (ms)
%       R           Contrast relaxivity (/s/mM)
%
%   GD = si_ratio2gd(BASE,...,FLAG) calculates the concentration of contrast
%   agent using a linear relaxivity model and the signal intensity time course,
%   where base specifies the number of pre-contrast images and flag is one of
%   the following:
%
%       Flag Value          Action
%       ----------------------------
%       FALSE (default)     uses the first input as baseline signal intensity
%
%       TRUE                calculates S1 from the number of pre-contrast images
%                           specified by the first input argument

%# AUTHOR    : Ryan Bosca
%# $DATE     : 16-Apr-2013 00:00:57 $
%# $Revision : 1.01 $
%# DEVELOPED : 7.13.0.564 (R2011b)
%# FILENAME  : si_ratio2gd.m

% 11/18/2015 - added support for T10 arrays and added validation for the inputs
%              S1, S2, and T10


    % Calculate pre-contrast signal intensity
    if (nargin==7) && flag
        s1 = mean(s2(1:s1));
    end

    % Determine how to reshape the arrays for computation of the signal
    % intensity ratio (sr)
    m1  = size(s1);
    m2  = size(s2);
    mT1 = size(T10);
    if (m1(2)~=m2(2))
        error(['QUATTRO:' mfilename ':incommensurateVoxelCount'],...
              ['The number of voxels of S1 and S2 should match ',...
               '(i.e., SIZE(S1,2)==SIZE(S2,2)).'])
    end
    if (m1(2)~=mT1(2))
        error(['QUATTRO:' mfilename ':incommensurateVoxelCount'],...
              ['The number of voxels of S1 and T10 should match ',...
               '(i.e., SIZE(S1,2)==SIZE(T10,2)).']);
    end

    % Convert relaxivites from /s/mM to /s/M
    r = r/1000;

    % Calculate gamma on a point-by-point basis. This loop saves a substantial
    % amount of memory by not generating two variables the full size of s1
    gd = zeros(m2);
    for idx = 1:m2(1)

        sr    = s1./s2(idx,:);
        gamma = (1-exp(-TR./T10))./(1-cosd(theta).*exp(-TR./T10));

        % One can easily show that the signal intensity ratio (sr) must always
        % satisfy the condition that sr>gamma. The following line enforces this
        % condition so that the logarithm used below does not produce complex
        % values.
        sr( (sr<gamma) ) = NaN;

        % Calculate the [Gd]
        gd(idx,:) = 1/(r*TR)*log( (gamma*cosd(theta)-sr)./(gamma-sr) )-1./(r.*T10);

    end

end %si_ratio2gd