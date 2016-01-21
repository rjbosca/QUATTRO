function assign_values(hObj,val)
%assign_values  Updates QUATTRO option GUIs
%
%   assign_values(H,val) updates the HGO (H) to reflect user changes to the
%   various options menus associated with QUATTRO.

% Store field
fld = get(hObj,'Tag');

% Store new data
switch fld
    case fixed_val_flds
        set(hObj, 'Value',val);
    otherwise
        switch fld
            case {'preSteadyState','nProcessors'}
                strFormat = '%d';
                val       = round(val);
            case {'t1Min','t1Max','t2Min','t2Max'}
                strFormat = '%0.0f';
            case {'r2Gd','r2Threshold'}
                strFormat = '%0.1f';
            case {'loadDir','importDir','saveDir'}
                strFormat = '%s';
            otherwise
                strFormat = '%0.3f';
        end
        if ~ischar(val)
            val = sprintf(strFormat, val);
        end
        set(hObj,'String',val);
end