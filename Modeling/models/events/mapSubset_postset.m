function mapSubset_postset(src,eventdata)
%mapSubset_postset  PostSet event for qt_models "mapSubset" property
%
%   mapSubset_postset(SRC,EVENT)

    % Grab the modeling object
    obj = eventdata.AffectedObject;

    % Validate that maps are being used
    if obj.isSingle
        warning(['qt_models:' src.Name ':unusedProperty'],...
                 '"%s" is unused when not performing map computations.',...
                 src.Name);
    end

    % Validate that the new map subset has the appropriate size
    mY   = size(obj.y);
    mSub = size(obj.mapSubset);
    if numel(mY(2:end))~=numel(mSub) || any(mY(2:end)~=mSub)
        warning(['qt_models:' src.Name ':incommensurateYandMapsub'],...
                ['"%s" must have N-1 dimensions, where N is NDIM(Y) and each ',...
                 'dimension must have the same size as the 2nd through the ',...
                 'Nth Y dimension.\nResetting "%s".'],src.Name,src.Name);
    end

    % Notify the model updaters (if any)
    notify(obj,'updateModel');
    
end %qt_models.mapSubset_postset