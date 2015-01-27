function h = show(obj,varargin)
%show  Displays a user specified data visualization
%
%   show(s) displays the data visualization specified by the string or cell
%   array of strings s. Valid strings are:
%
%       String          Description
%       ---------------------------
%       'histogram'     Subplots of histograms from all explanatory variables
%
%       'scatter'       Scatter plots of all predictors as a function of
%                       explanatory variables
%
%       'latentres'     Constructs a normal probability plot for the latent
%                       residuals
%
%       'latenttrait'   Constructs a latent trait plot for a single input vector

if ~obj.calcsReady
    return
end

% Parse the inputs
valid_strs = {'boxplot',...
              'density',...
              'devcont',...
              'histogram',...
              'latentres',...
              'latenttrait',...
              'predhist',...
              'scatter'};
s = cellfun(@(x) validatestring(x,valid_strs),varargin,'UniformOutput',false);

% Show the data
if nargout
    h = cellfun(@(x) eval(['obj.show_' x]),s,'UniformOutput',false);
    if numel(h)==1
        h = h{:};
    end
else
    cellfun(@(x) eval(['obj.show_' x]),s,'UniformOutput',false);
end