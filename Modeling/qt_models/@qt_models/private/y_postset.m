function y_postset(obj,src,eventdata)
%y_postset  PostSet event for qt_models property "y"
%
%   y_postset(OBJ,SRC,EVEVT) performs various validation steps on the property
%   "y". When setting new data for the "y" property the results structure is
%   reset and, fitting of the new data is performed.

    % Gather some information about the properties of the current qt_model object
    mY = size(obj.y);
    nX = numel(obj.x);

    % Validate the new "y" data
    %TODO: should this actually be here? After all, at this point the damage is
    %done and there is no going back, i.e., "y" can't be changed.
    if (all(mY)>0) && any(nX) && any(mY) && (mY(1)~=nX)
        error('QUATTRO:qt_models:yDataChk','%s\n%s\n',...
              'Y data must be same length as X data',...
              'or satisfy SIZE(Y,1)==LENGTH(X).');
    end

    % Update the "results" and "isShown" properties to reflect the new data
    obj.results = [];
    obj.isShown = false;

    % Update the "isSingle" property only if the value of "y" is non-empty
    if ~isempty(obj.y)
        obj.isSingle = (prod(mY)==nX);
    end

    % Update the "mapSub" property
    if ~obj.isSingle
        obj.mapSubset = true(mY(2:end));
    end

    % Changes in any of the data properties results in new fits when auto
    % fitting is enabled and showing of the new data. Otherwise, only the show
    % operation is performed
    obj.update;

end %qt_models.y_postset