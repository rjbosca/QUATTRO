function varargout = drop_out_dev(obj)
%drop_out_dev  Deviance difference by dropping terms
%
%   devDiff = drop_out_dev computes the change in deviance between fitted
%   models by droping out, sequentially, one of the model terms. This analysis
%   is for ordinal modeling only and requires a trained qt_response object.

% Ensure data have been trained
try
    obj.training;
catch ME %#ok
    warning(['qt_response:' mfilename ':noTraining'],...
                   'No training data detected. Ensure data have been trained.');
    return
end
if sum(obj.covIdx)<2
    warning(['qt_response:' mfilename ':singleCov'],...
                         'Drop out analysis requires at least two covariates.');
    return
end

% Find all covariate indices and initialize the output
cvIdx   = find(obj.covIdx);
devDrop = repmat(obj.training.dev,[sum(obj.covIdx) 1]);

% Grab the original subset, we're going to play a trick. Because the covariate
% index is going to change (see the loop below), we need to ensure that only the
% observations used for the "full" model are used in the individual models. To
% do this, we determine the observation mask that is used during the full
% modeling and store the orignal to be restored later
subOrig = obj.subset;
obj.subset = (~obj.rmIdx & subOrig);

% Loop through each of the covariates, removing one at a time and re-training
for idx = 1:numel(cvIdx)
    obj.covIdx(cvIdx(idx)) = false; %remove the ith covariate
    results         = obj.train;
    devDrop(idx)    = results.dev-devDrop(idx);
    obj.covIdx(cvIdx(idx)) = true; %restore the index before moving on
end

% Reinstate the original observation index
obj.subset = subOrig;

% Account for overdispersion
varargout = {devDrop/(obj.training.dev/obj.dof)};