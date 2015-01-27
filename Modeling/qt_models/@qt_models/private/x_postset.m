function x_postset(obj,src,eventdata)
%x_postset  PostSet event handler for qt_model property "x"
%
%   x_postset(OBJ,SRC,EVEVT) performs various validation steps on the property
%   "x". The "index" property is also initialized if necessary. Finally, when
%   setting new data for the "y" property the results structure is reset. In
%   both cases, fitting of the new data is performed 

    % Gather some information about the properties of the current qt_model object
    nIndex = numel(obj.subset);
    nX     = numel(obj.x);

    % Validate/update the "index" property according to the new "x" data
    if ~any(nIndex) || (nX~=nIndex)
        obj.subset = [obj.subset true(1,nX-nIndex)];
    end

    % Changes in any of the data properties results in new fits when auto
    % fitting is enabled and showing of the new data. Otherwise, only the show
    % operation is performed
    obj.update;

end %qt_models.x_postset