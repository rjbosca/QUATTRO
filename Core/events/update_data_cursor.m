function txt = update_data_cursor(~,eventdata)
%update_data_cursor  Data cursor update function
%
%   update_data_cursor(SRC,EVENT) determines the text to be displayed with the
%   data cursor object.

    % Initialize data/output
    hFig = guifigure(eventdata.Target);
    pos  = eventdata.Position;
    txt  = {sprintf('X: %d Y: %d',pos)};

    % Get the exam object and some additional information about the image
    obj   = getappdata(hFig,'qtExamObject');
    isMap = ~strcmpi( get(eventdata.Target,'Tag'), 'image' );
    if isMap

        % Determine which of the objects is the overlay. When displaying
        % overlays, the underlying image must have a the property of "Tag" set
        % to 'image'
        imgObj = getappdata(hFig,'qtMapObject');

        % Scale the position of the data cursor and grab the value of the
        % overlay value at that position
        dataSize   = get(eventdata.Target,{'XData','YData'});
        pos        = pos(2:-1:1).*imgObj.dimSize./...
                                                [dataSize{1}(2) dataSize{2}(2)];
        pos        = round(pos);
        txt{end+1} = [imgObj.tag ': ' num2str(imgObj.value(pos(1),pos(2)))];

    else
        txt{end+1} = ['S.I.: ' num2str(obj.image.value(pos(2),pos(1)))];
    end

    % Update the current voxel
    obj.voxelIdx = pos;

    % Grab the modeling object(s) and determine if any modeling GUIs are
    % associated with the current object
%     if ~isMap && ~isempty(obj.hExtFig)
%         mObj = getappdata(hs.figure_main,'modelsObject');
%         mObj = mObj( mObj.isvalid );
%         mObj = mObj( ~isempty([mObj.hFig]) );
%         if ~isempty(mObj)
%             % Although there exists a qt_exam's method (getroivals), it is much
%             % faster to access the image data here and update the y values since
%             % it has already been determined that this modeling object can use
%             % the data
%             mObj.y = obj.getroivals('pixel',[],false,...
%                                     'slice',obj.sliceIdx);
%         end
%     end

end %update_data_cursor