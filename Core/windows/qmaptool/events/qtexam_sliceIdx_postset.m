function qtexam_sliceIdx_postset(src,eventdata)
%qtexam_sliceIdx_postset  PostSet for qt_exam property "sliceIdx"
%
%   qtexam_sliceIdx_postset(SRC,EVENT)

    % Loop through all of the external figures, updating the old map objects
    for hFig = eventdata.AffectedObject.hExtFig(:)'

        % Is this a qmaptool figure?
        if isempty( strfind( get(hFig,'Name'), 'QUATTRO-Maps' ) )
            continue
        end

        % Find only the map object. The underlying image is updated during the
        % PostSet listener for the qt_exam object
        oldObj = getappdata(hFig,'qtMapObject');

        % Update the current display
        eventdata.AffectedObject.map.show(oldObj);
    end

end %qtexam_sliceIdx_postset