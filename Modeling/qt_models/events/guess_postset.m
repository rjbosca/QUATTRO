function guess_postset(src,eventdata)
%guess_postset  PostSet event for qt_models "guess" property
%
%   guess_postset(SRC,EVENT) handles PostSet events for the qt_models property
%   "guess", where SRC is the event source data and EVENT is the event object. 
%
%   When manual changes to the guess property are made, this PostSet event
%   disables the automatic calculation of the starting guess, and fits the data
%   if "autoFit" is true.
%
%   Changes to the "autoGuess" property only fire the fitting algorithms (if
%   "autoFit" is true).

    % Grab the modeling object
    obj = eventdata.AffectedObject;

    % Validate the input. The guess should be within the bounds. Note that the
    % bounds are validated in the set method (see qt_models set.bounds)
    guess  = obj.guess;
    mGuess = size(obj.guess);
    lims   = obj.bounds;
    if ~isempty(guess) && ~isempty(lims)
        exceedLower = (guess<repmat(lims(:,1),[1 mGuess(2:end)]));
        exceedUpper = (guess>repmat(lims(:,2),[1 mGuess(2:end)]));
        if any( exceedLower ) %exceeds lower bounds
            guess(exceedLower) = lims(exceedLower,1);
        end
        if any( exceedUpper )
            guess(exceedUpper) = lims(exceedUpper,2);
        end

        % Update if necessary
        if any( [exceedLower(:);exceedUpper(:)] )
            obj.guess = guess;
        end
    end

    % When the auto guess feature is enabled, setting the guess data manually
    % will disable this feature
    obj.autoGuess = false;

    % Fit the data again using the new guess
    if obj.autoFit
        obj.fit;
    end

end %qt_models.guess_postset