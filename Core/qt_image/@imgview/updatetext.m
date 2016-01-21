function updatetext(obj,~,~)
%updatetext  Post-set event for IMGVIEW "isDispText" property
%
%   updatetext(OBJ,SRC,EVENT) updates the imgview object specified by the source
%   object SRC. OBJ an imgview object
%
%   Note: updatetext performs some housekeeping every call. When called, any
%   previous text objects with the tag 'qt_image_text' are deleted. To avoid 
%   conflicts, this tag should not be used by other graphics objects on the 
%   axes.

    if ~obj.isDispText

        % This delete operation handles the the toggle functionality of the
        % "isDispText" flag
        hText = obj.hText;
        if ~isempty(hText)
            hText(~ishandle(hText)) = [];
            delete(hText);
        end

        return
    end

    % Get the fields and the axis
    flds = obj.imgObj.dispFields;
    frmt = obj.imgObj.dispFormat;
    hAx  = obj.hAxes;
    if isempty(flds) || isempty(hAx)
        return
    end

    % Delete any previous text
    delete(findobj(hAx,'Tag','qt_image_text'));

    % Get the axes limits (determines where to put text)
    xlim = get(hAx,'XLim');
    ylim = get(hAx,'YLim');

    % Calculate text position
    x = 0.02*diff(xlim)+xlim(1);
    y = 0.99*diff(ylim)+ylim(1);

    %FIXME: I need to find a way of handling empty cells

    % Create a cell of strings and print to the display string
    %TODO: this try/catch statement is temporary...
    try
        sDisp = cellfun(@(x) obj.imgObj.metaData.(x),flds,'UniformOutput',false);
    catch ME
        if ~strcmpi(ME.identifier,{'MATLAB:mustBeFieldName'})
            rethrow(ME)
        end
        return
    end
    nFrmt = numel(frmt);
    if ~nFrmt
        s = cellfun(@(x,y) [y ': ' cast_text(x,y)],...
                                                 sDisp,flds, 'UniformOutput',false);
    else
        % Initialize the cell and an index for looping through the format
        % strings
        s   = cell(nFrmt,1);
        idx = 0;

        % Determine the number of escape characters for each string
        nEsc  = cellfun(@(x) numel( strfind(x,'%') ),frmt);
        nDisp = numel(sDisp);
        if ( sum(nEsc) ~= nDisp )
            warning(['qt_image:' mfilename ':formatDisplayMismatch'],...
                    ['A mismatch was detected between the number of display ',...
                     'parameters (%u) and the number requested (%u) by the ',...
                     'display format. Suppressing on-image display...\n'],...
                     nDisp,sum(nEsc));
            obj.imgObj.dispFormat = {};
            obj.imgObj.dispFields = {};
            return
        end

        % Loop through each of the format strings, grabbing the appropriate
        % number of display fields and printing the string
        for fIdx = 1:nFrmt
            %TODO: what if one of the cells contains an array that contains more
            %than one element. Find a way to handle this
            nEsc    = numel( strfind(frmt{fIdx},'%') );
            s{fIdx} = sprintf(frmt{fIdx},sDisp{(1:nEsc)+idx});
            idx     = idx+nEsc;
        end
    end
    s = sprintf('%s\n',s{:}); s(end) = []; %removes last end line

    % Show the text
    obj.hText = text(x,y,s,'Color',obj.textColor,...
                           'Clipping','off',...
                           'HitTest','off',...TODO: add context menus
                           'Interpreter','none',...
                           'Parent',hAx,...
                           'Tag','qt_image_text',...
                           'VerticalAlignment','bottom');

end %imgview.updatetext

% Default text formatter
function str = cast_text(str,fld)

    switch fld
        case 'FlipAngle'
            str = sprintf('%3.1f%s',str,186);
        case 'RepetitionTime'
            str = sprintf('%5.3f (ms)',str);
        case 'SliceLocation'
            str = sprintf('%3.3f',str);
    end

end %cast_text