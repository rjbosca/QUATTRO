function varargout = vline(x,varargin)
%vline  Interactive vertical line API
%
%   H = VLINE(X) places an interactive vertical line on the current axis at the
%   position X that spans the y range of the axis. The handle to the HG group is
%   returned. VLINE is a specialization of the IMLINE function provided by
%   MathWorks that forces a vertical line.
%
%   [H,OBJ] = VLINE(...) also returns the IMLINE object OBJ

    % Initialize the output/workspace
    [varargout{1:nargout}] = deal([]);
    hAx                    = gca;
    y                      = get(hAx,'YLim');

    % Before continuing, verify that no other IMLINE objects exist on the
    % current plot.
    hLine = findobj(hAx,'Type','hggroup');
    if ~isempty(hLine)
        error(['QUATTRO:' mfilename ':tooManyLines'],...
              ['VLINE only supports drawing one line on a given axis at a ',...
               'time.']);
    end

    % Create the IMLINE object
    lineObj = imline(hAx,repmat(x,size(y)),y);

    % Constrain the line to the current window
    fcn = makeConstrainToRectFcn('imline',get(gca,'XLim'),y);
    lineObj.setPositionConstraintFcn(fcn);

    % Find all of the IMLINE handle and delete the callback functions for the
    % end points
    %TODO: I also want to disable the cursor from becoming the finger pointer...
    hLine = findobj(hAx,'Type','hggroup');
    hKids = get(hLine,'Children');
    for h = hKids(:)'
        if ~isempty( strfind(get(h,'Tag'),'end point') )
            set(h,'ButtonDownFcn',[]);
        end
    end

    % Create a post-set listener for the y limit
    propList = [addlistener(hAx,'YLim','PostSet',...
                                   @(s,ed) vline_ylim_postset(lineObj,s,ed)),...
                addlistener(hAx,'XLim','PostSet',...
                                   @(s,ed) vline_xlim_postset(lineObj,s,ed))];

    % Store the listeners as application data within the HG group to be deleted
    % when the object is destroyed
    setappdata(hLine,[mfilename '_propertyListeners'],propList);

    % Add the delete function
    iptaddcallback(hLine,'DeleteFcn',@vline_delete_Callback);

    % Deal the ouptuts
    if nargout
        varargout{1} = hLine;
    end
    if (nargout>1)
        varargout{2} = lineObj;
    end

end %vline


%-------------------------------------------
function vline_xlim_postset(obj,~,eventdata)

    % Update the IMLINE constraint function
    fcn = makeConstrainToRectFcn('imline',...
                   eventdata.AffectedObject.XLim,eventdata.AffectedObject.XLim);
    obj.setPositionConstraintFcn(fcn);

end %vline_ylim_postset

%-------------------------------------------
function vline_ylim_postset(obj,~,eventdata)

    % Update the IMLINE position
    pos      = obj.getPosition;
    pos(:,2) = eventdata.AffectedObject.YLim;
    obj.setPosition(pos);

    % Update the IMLINE constraint function
    fcn = makeConstrainToRectFcn('imline',...
                                        eventdata.AffectedObject.XLim,pos(:,2));
    obj.setPositionConstraintFcn(fcn);

end %vline_ylim_postset

%-------------------------------------
function vline_delete_Callback(hObj,~)
	delete( getappdata(hObj,[mfilename '_propertyListeners']) );
end