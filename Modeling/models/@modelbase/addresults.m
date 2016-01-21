function addresults(obj,varargin)
%addresults  Adds modeling results to a modeling object
%
%   addresults(OBJ,PARAM1,VAL1,PARAM2,VAL2,...) appends (or overwrites) the data
%   in the "results" property using the parameter name specified by the string
%   PARAM with the value specified by VAL.

    [params,vals] = parse_inputs(varargin{:});

    cellfun(@(x,y) value2result(obj,x,y),params,vals);

end %qt_models.addresults


%--------------------------------------
function [p,v] = parse_inputs(varargin)

    p = varargin(1:2:end);
    v = varargin(2:2:end);

end %parse_inputs


%-----------------------------------
function value2result(obj,param,val)

    % Initialize workspace
    units     = ''; %for undefined parameters - for example, 'RSq'
    if isfield(obj.paramUnits,param)
        units = obj.paramUnits.(param);
    end

    % Construct either a unit or qt_image object
    if obj.isSingle
        obj.results(1).(param) = unit(val,units);
    else
        metaData               = struct('ImageType',...
                                        ['PROCESSED\SECONDARY\' upper(param)]);
        obj.results(1).(param) = qt_image(val,...
                                       'metaData',metaData,...
                                       'tag',param,...
                                       'units',units);
    end

end %value2result