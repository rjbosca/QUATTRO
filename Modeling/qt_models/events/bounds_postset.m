function bounds_postset(src,eventdata)
%bounds_postset  PostSet event for qt_models property "bounds"
%
%   bounds_postset(SRC,EVENT) handles PostSet events for the qt_models property
%   "bounds", where SRC is the event source data and EVENT is the event object. 

    % Grab the modeling object
    obj = eventdata.AffectedObject;

    % Validate the input. The guess should be within the bounds. Note that the
    % bounds are validated in the set method (see qt_models set.bounds)
    guess = obj.guess;
    lims  = obj.bounds;
    if ~isempty(guess) && ~isempty(lims)
%         exceedLower = (guess<lims(:,1));
%         exceedUpper = (guess>lims(:,2));
%         if any( exceedLower ) %exceeds lower bounds
%             guess(exceedLower) = lims(exceedLower,1);
%         end
%         if any( exceedUpper )
%             guess(exceedUpper) = lims(exceedUpper,2);
%         end
% 
%         % Update if necessary
%         if any( [exceedLower(:);exceedUpper(:)] )
%             obj.guess = guess;
%         end
    end

    % Fit the data again using the new guess
    if obj.autoFit
        obj.fit;
    end

end %qt_models.bounds_postset