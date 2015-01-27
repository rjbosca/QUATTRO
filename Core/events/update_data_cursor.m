function txt = update_data_cursor(src,eventdata) %#ok
%update_data_cursor  Data cursor update function
%
%   update_data_cursor(SRC,EVENT) determines the text to be displayed with the
%   data cursor object (OBJ).

    % Initialize data/output
    src = eventdata.Target;
    pos = eventdata.Position;
    txt = {['X: ' num2str(pos(1)) ' Y: ' num2str(pos(2))]};

    % Grab the figure handle 
    hs    = guihandles(src);
    hIms  = findobj(hs.axes_main,'Type','image');
    obj   = getappdata(hs.figure_main,'qtExamObject');
    isMap = (numel(hIms)>1);
    if isMap

        % Determine which of the objects is the overlay. When displaying
        % overlays, the underlying image must have a the property of "Tag" set
        % to 'image'
        imgObj = getappdata(hs.figure_main,'qtMapObject');

        % Scale the position of the data cursor and grab the value of the
        % overlay value at that position
        dataSize   = get(src,{'XData','YData'});
        pos        = pos(2:-1:1).*imgObj.imageSize./...
                                                [dataSize{1}(2) dataSize{2}(2)];
        pos        = round(pos);
        txt{end+1} = [imgObj.tag ': ' num2str(imgObj.image(pos(1),pos(2)))];

    else
        txt{end+1} = ['S.I.: ' num2str(obj.image.image(pos(2),pos(1)))];
    end

    % Grab the modeling object(s) and determine if any modeling GUIs are
    % associated with the current object
    if ~isMap
        mObj = getappdata(hs.figure_main,'modelsObject');
        mObj = mObj( mObj.isvalid );
        mObj = mObj( ~isempty([mObj.hFig]) );
        if ~isempty(mObj)
            % Although there exists a qt_exam's method (getroivals), it is much
            % faster to access the image data here and update the y values since
            % it has already been determined that this modeling object can use
            % the data
            mObj.y = obj.getroivals('pixel',[],false,...
                                    'slice',obj.sliceIdx);
        end
    end

end %update_data_cursor