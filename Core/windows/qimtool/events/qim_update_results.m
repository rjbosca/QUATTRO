function qim_update_results(src,eventdata)
%qim_update_results  Modeling GUI PostSet event handler for "results"
%
%   qim_update_results(SRC,EVENT)

    % Grab the modeling object
    obj = eventdata.AffectedObject;

    % Determine if the figure exists
    if isempty(obj.hFig) || ~ishandle(obj.hFig) || isempty(obj.results)
        return
    end

    % Update the parameter displays and plot function. The plot function is set 
    % during the call to "fitplot", while the fitting results are set during the
    % "processFit" call. By encapsulating the two operations (showing data and
    % updating the table) in an if/elseif statement, the "show" call is only
    % performed once during it's initialization in the "fitplot" method.
    mParams = obj.modelParams;
    mParams = mParams( cellfun(@(x) isfield(obj.results,x),mParams) );
    if all( isfield(obj.results,mParams) )

        % Initialize the table data with the parameter names
        n = numel(mParams)+4;
        [dat{1:n,1}] = deal(mParams{:},'RSq','MSE','Sum Res.','Sum Std. Res.');

        % Generate a cell array from the results structure
        dat(:,2) = cellfun(@(x) obj.results.(x),...
                           [mParams(:);{'RSq';'MSE';'Res';'StdRes'}],...
                           'UniformOutput',false);

        % Calculate the sum for the residuals and standardized residuals
        isVec        = cellfun(@(x) (numel(x)>1),dat(:,2));
        dat(isVec,2) = cellfun(@sum,dat(isVec,2),'UniformOutput',false);

        % Convert the values of class "unit" to numeric for those data that
        % actually have units defined. The value is returned for everything else
        isUnit        = cellfun(@(x) strcmpi(class(x), 'unit'),dat(:,2));
        hasUnits      = cellfun(@(x) isfield(obj.paramUnits,x),dat(:,1));
        convertUnits  = (hasUnits & isUnit);
        dat(convertUnits,2) = cellfun(@(x,y) y.convert( obj.paramUnits.(x) ),...
                                                         dat(convertUnits,1),...
                                                         dat(convertUnits,2),...
                                                         'UniformOutput',false);
        dat(isUnit,2) = cellfun(@(x) x.value,dat(isUnit,2),...
                                                         'UniformOutput',false);

        % Grab the units
        dat(:,3) = [cellfun(@(x) obj.paramUnits.(x),mParams,...
                                                      'UniformOutput',false);...
                    {'';'';'';''}];

        % Set the new table data
        set(findobj(obj.hFig,'Tag','table_results'),'Data',dat);
    elseif isfield(obj.results,'Fcn')
        obj.show;
    end

end %qim_update_results