function fit(obj,varargin)
%fit  Fits data to the specified model
%
%   fit(OBJ) performs data fitting based on the current properties of the
%   MODELBASE sub-class object OBJ
%
%   fit(OBJ,'PARAM1',VAL1,...) passes optional parameter value pairs to the
%   fitting routine, where valid parameter options are:
%
%       Option          Description
%       ===========================
%       'WaitBar'       Handle to the wait bar used to display
%                       parameter map computation progress


    % Ensure fitting is prepared
    if ~all( struct2array(obj.isReady) )
        return
    end

    % Always update the modeling object here, just in case...
    obj.update;

    % Only fit non-linear parameters
    if numel(obj.nlinParams)

        if obj.isSingle %optimized for speed - single data fitting
            y        = obj.yProc;
            g        = obj.paramGuess;
            [x0,~,r] = obj.fitFcn(cellfun(@(x) g.(x),obj.nlinParams),y);
            yc       = x0(:);
            r2       = modelmetrics.calcrsquared(y,r);
        else
            %FIXME: the user can cancel the computation by closing the wait bar
            %window, which will result in the "fitmaps" method terminating
            %before returning any outputs. Ultimately, this will cause an error,
            %but it should simply return the user to the previous state (with a
            %warning maybe?)
            [yc,r2] = obj.fitmaps(varargin{:});
        end

        % Assign the R^2 value to the cache property for quick access later...
        obj.RSqCache = r2;

        % Assign the values of the non-linear fitting to the "results" property
        for idx = 1:numel(obj.nlinParams)
            obj.addresults(obj.nlinParams{idx}, squeeze(yc(idx,:,:)) );
        end

    end

    % Finally, notify the "newRestuls" event that update operations should be
    % fired
    notify(obj,'newResults');

end %qt_models.fit