function fitplot(obj)
%fitplot  Performs single data fitting operation for qt_models sub-classes
%
%   fitplot(OBJ) performs fitting operations for a single data (usually serial
%   voxel data) stored in the "y" property of the qt_models sub-class OBJ.

    % Non-linear computations (all others are performed in the sub-class
    % specific method "processFit")
    processVals = [];
    if numel( obj.nlinParams{obj.modelVal} )

        % Get some data to fit and initialize fit parameters
        x  = obj.xProc;
        y  = obj.yProc;
        x0 = obj.guess;

        % Perform the fit
        x0 = obj.fitFcn(x0,y);

        % Cache the function handle for plotting the fitted data
        pFcn        = obj.plotFcn;
        yFit        = pFcn(x0,x);
        results.Fcn = @(xdata) pFcn(x0,xdata);

        % Compute some fitting criteria
        results.Res    = ( y-yFit );
        results.MSE    = mean_sq_err(x,y,yFit);
        results.StdRes = std_res(x,y,yFit);

        % Store the results
        obj.results = results;

        % Store the fitted data and R^2 to send to processFit
        processVals = [x0;r_squared(x,y,yFit)];

    end

    % Deals the results and performs any additional exam specific processing
    obj.processFit(processVals);

end %qt_models.fitplot