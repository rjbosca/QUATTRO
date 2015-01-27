function gd = si_ratio2gd(s1,s2,theta,TR,T10,r,flag)
%si_ratio2gd  Converts measured signal intensities to [Gd]
%
%   GD = si_ratio2gd(S1,S2,THETA,TR,T10,R) calculates the concentration of
%   contrast agent using a linear relaxivity model based on the ratio of the
%   pre- and post-contrast signal intensities, S1 and S2, respectively. S2 can
%   be a scalar or a 2D  array, where the first dimension represents the serial
%   acquisitions and the second represents the voxel. The latter requires S1 to
%   satisfy both SIZE(S1,2)==SIZE(S2,2). Values for which [Gd] cannot be
%   calculated (usually the result of noisy data) are returned as NaNs.
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
%       false (default)     uses the first input as baseline signal intensity
%
%       true                calculates S1 from the number of pre-contrast images
%                           specified by the first input argument

%# AUTHOR    : Ryan Bosca
%# $DATE     : 16-Apr-2013 00:00:57 $
%# $Revision : 1.01 $
%# DEVELOPED : 7.13.0.564 (R2011b)
%# FILENAME  : si_ratio2gd.m

    % Calculate pre-contrast signal intensity
    if nargin==7 && flag
        s1 = mean(s2(1:s1));
    end

    % Determine how to reshape the arrays for computation
    m1    = size(s1);
    m2    = size(s2);
    if m1(2)~=m2(2)
        error(['qt_models:' mfilename ':incommensurateVoxelCount'],...
              ['The number of voxels of S1 and S2 should match\n',...
               '(i.e. SIZE(S1,2)==SIZE(S2,2)).\n'])
    end

    % Calculate signal ratio and convert relaxivites from /s/mM to /s/M
    sr = repmat(s1,[m2(1) 1])./s2;
    r  = r/1000;

    % Calculate gamma
    gamma = (1-exp(-TR/T10))/(1-cosd(theta)*exp(-TR/T10));

    % One can easily show that the signal intensity ratio (sr) must always
    % satisfy the condition that sr>gamma. The following line enforces this
    % condition so that the logarithm used below does not produce complex values
    sr(sr<gamma) = NaN;

    % Calculate Gd concentration
    gd = 1/(r*TR)*log( (gamma*cosd(theta)-sr)./(gamma-sr) )-1/(r*T10);

end %si_ratio2gd