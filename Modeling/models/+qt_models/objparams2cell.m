function val = objparams2cell(obj)
%objparams2cell  Converts modeling object guesses and bounds to a cell
%
%   C = objparams2cell(OBJ) converts the properties of the modeling object OBJ
%   ("paramGuess" and "paramBounds") to a cell array C. For a model with N
%   non-linear model parameters, C will be an N-by-3 cell array.
%
%   This function is used primarily in conjunction with QIMTOOL to update the
%   "Parameter Options" UI table

    % Determine the number of non-linear parameters (needed for reshaping the
    % parameter bounds array)
    nParams = numel(obj.nlinParams);

    % Convert "paramGuess" from a structure to a numeric array
    pGuess = cellfun(@(x) obj.paramGuess.(x),obj.nlinParams,...
                                                         'UniformOutput',false);
    pGuess = cell2mat(pGuess);

    % Convert "paramBounds" from a structure to a numeric array
    pBounds = cellfun(@(x) obj.paramBounds.(x),obj.nlinParams,...
                                                         'UniformOutput',false);
    pBounds = reshape(cell2mat(pBounds),[],nParams)';

    % Concatenate and return as a cell array
    val = num2cell([pGuess(:) pBounds]);

end %objparams2cell