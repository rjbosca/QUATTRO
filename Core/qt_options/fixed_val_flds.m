function flds = fixed_val_flds
%fixed_val_flds  Returns all fixed value fields for various GUIs.
%
%   F = fixed_val_flds returns QUATTRO options for which the values are logicals
%   or integers (e.g. popupmenu or checkbox values)

flds = {'multiteModel','multitrModel',...%model options
        'multitiModel','dwModel','edwiModel',...%model options
        'dscModel',...%model options
        'multiSlice',...%multi slice option
        's0Map','r1Map','t1Map','r2Map','t2Map',...%relaxometry maps
        'flipAngleMap','usePolarityCorrection',...%relaxometry maps
        'meanAdcMap','adcMap',...%diffusion maps
        'dceUnits','t1Correction',...%dce options
        'auc90Map','ktransMap','kepMap','veMap','vpMap',...%dce maps
        'mttMap','rcbvMap',...%dsc maps
        'rSquaredMap',...%general maps
        'parallel','linkAxes'};