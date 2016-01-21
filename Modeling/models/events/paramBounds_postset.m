function paramBounds_postset(~,eventdata)
%paramBounds_postset  PostSet event for qt_models property "paramBounds"
%
%   paramBounds_postset(SRC,EVENT) handles PostSet events for the qt_models
%   property "paramBounds", where SRC is the event source data and EVENT is the
%   event object.

    % Grab the modeling object
    obj = eventdata.AffectedObject;

    % Validate the new value of "paramBounds" against "paramGuess". The values
    % of "paramGuess" should be within the non-linear parameter bounds. Note
    % that the bounds are validated in the set method of the "paramBounds"
    % property
    g = obj.paramGuess;
    l = obj.paramBounds;
    if ~isempty(g) && ~isempty(l)

        for param = obj.nlinParams

            % Ensure that all fiels are non-empty before testing further
            if ~isfield(g,param{1}) || isempty(g.(param{1})) ||...
                                   ~isfield(l,param{1}) || isempty(l.(param{1}))
                continue
            end

            % Validate the new value
            if (g.(param{1})<l.(param{1})(1))
                warning(['qt_models:' mfilename ':guessTooLow'],...
                        ['The guess for "%s" exceeds the lower bound and has ',...
                         'been reset to %f.'],param{1},l.(param{1})(1));
                obj.paramGuess.(param{1}) = l.(param{1})(1);
            elseif (g.(param{1})>l.(param{1})(2))
                warning(['qt_models:' mfilename ':guessTooHigh'],...
                        ['The guess for "%s" exceeds the upper bound and has ',...
                         'been reset to %f.'],param{1},l.(param{1})(2));
                obj.paramGuess.(param{1}) = l.(param{1})(2);
            end

        end

    end

    % Notify the model updaters (if any)
    notify(obj,'updateModel');

end %qt_models.paramBounds_postset