function qim_update_results(src,~)
%qim_update_results  Modeling GUI PostSet event handler for "results"
%
%   qim_update_results(SRC,EVENT)

    % Determine if the figure exists
    if isempty(src.hFig) || ~ishandle(src.hFig) || isempty(src.results)
        return
    end

    % Grab the model parameters. RSq should always be report after the
    % non-linear parameters, so remove it and append it to the "dat" cell
    mParams = fieldnames(src.results);
    mParams = mParams(~strcmpi(mParams,'rsq') & ~strcmpi(mParams,'mse'));

    % Initialize the table data with the parameter names
    n = numel(mParams)+1;
    [dat{1:n,1}] = deal(mParams{:},'RSq');
%         ,'MSE','Sum Res.','Sum Std. Res.');

    % Generate a cell array from the results structure
    dat(:,2) = cellfun(@(x) src.results.(x),...
                                [mParams(:);{'RSq'}],'UniformOutput',false);
%         'MSE';'Res';'StdRes'}],...

    % Calculate the sum for the residuals and standardized residuals
    isVec        = cellfun(@(x) (numel(x)>1),dat(:,2));
    dat(isVec,2) = cellfun(@sum,dat(isVec,2),'UniformOutput',false);

    % Convert the values of class "unit" to numeric for those data that
    % actually have units defined. The value is returned for everything else
    isUnit        = cellfun(@(x) strcmpi(class(x), 'unit'),dat(:,2));
    hasUnits      = cellfun(@(x) isfield(src.paramUnits,x),dat(:,1));
    convertUnits  = (hasUnits & isUnit);
    dat(convertUnits,2) = cellfun(@(x,y) y.convert( src.paramUnits.(x) ),...
                                                     dat(convertUnits,1),...
                                                     dat(convertUnits,2),...
                                                     'UniformOutput',false);
    dat(isUnit,2) = cellfun(@(x) x.value,dat(isUnit,2),...
                                                     'UniformOutput',false);

    % Grab the units
    dat(:,3) = [cellfun(@(x) src.paramUnits.(x),mParams,...
                                               'UniformOutput',false);{''}];

    % Set the new table data
    set(findobj(src.hFig,'Tag','table_results'),'Data',dat);

end %qim_update_results