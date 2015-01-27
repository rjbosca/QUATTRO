function fit(obj,varargin)
%fit  Fits data to the specified model
%
%   fit(OBJ) performs data fitting based on the current properties of the
%   qt_models sub-class object OBJ
%
%   fit(OBJ,'PARAM1',VAL1,...) passes optional parameter value pairs to the
%   fitting routine, where valid parameter options are:
%
%       Option          Description
%       ===========================
%       'WaitBar'       Handle to the wait bar used to display
 %                      parameter map computation progress


    % Ensure fitting is prepared
    if ~obj.calcsReady && isempty(varargin)
        return
    end

    if numel(obj.y)==numel(obj.x)
        obj.fitplot(varargin{:});
    else
        obj.fitmaps(varargin{:});
    end

end %qt_models.fit