function ydata = fspgr_full(varargin)
%fspgr_full  Theoretical FSPGR signal intensity model
%
%   Y = fspgr_full(S0,T1,FA,TR) calculates the signal intensity Y from the
%   flip angles (in degrees) specified by FA, repetition time (TR in ms),
%   intrinsic signal intensity S0, and T1 in milliseconds. This function was
%   parameterized for simulating signal intnesities using arrays of imaging and
%   system parameters.
%
%   Any (or all) of the parameters can be specified as an array or a scalar. If
%   multiple parameters are specified as arrays, the arrays must be the same
%   size. "fspgr_vfa" is a faster, but more limited implementation designed for
%   non-linear least squares parameter estimation
%
%   This fast spoiled gradient echo model assumes perfect spoiling and that T2*
%   effects are negligible (i.e. TE<<T2* and TE=const.)
%
%   See also multi_flip

%# AUTHOR    : Ryan Bosca
%# $DATE     : 16-May-2013 23:07:54 $
%# $Revision : 1.02 $
%# DEVELOPED : 7.13.0.564 (R2011b)
%# FILENAME  : multi_flip.m

    [s0,t1,fa,tr] = parse_inputs(varargin{:});

    % Exponential relaxation term
    E1 = exp(-tr./t1);

    % Fast, spoiled gradient echo model
    ydata = s0.*(sind(fa).*(1-E1))./(1-cosd(fa).*E1);

end %fspgr_full


%------------------------------------------
function varargout = parse_inputs(varargin)

    narginchk(4,4);
    varargout = varargin;

    % Calculate some data properties
    nEl      = cellfun(@numel,varargin);
    mIn      = cellfun(@size,varargin,'UniformOutput',false);
    isScalar = (nEl==1);

    % Determine if any of the inputs are non-scalar, 
    mReshape = [1 1];
    if ~all( isScalar )
        mReshape = mIn{ nEl==max(nEl) };
    end

    % Validate that all non-scalar inputs are the same size
    varsIn   = {'S0','T1','FA','TR'};
    validFcn = @(x,y) validateattributes(x,{'numeric'},...
                                            {'2d','size',mReshape},mfilename,y);
    cellfun(@(x,y) validFcn(x,y),varargin(~isScalar),varsIn(~isScalar));

    % Reshape the scalars
    if any(isScalar)
        varargout(isScalar) = cellfun(@(x) repmat(x,mReshape),...
                                      varargin(isScalar),'UniformOutput',false);
    end

end %parse_inputs