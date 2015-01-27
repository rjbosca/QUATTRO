function change_view_Callback(hObj,eventdata) %#ok
%change_view_Callback  Callback for view plane change requests

    % Get exams object
    hs = guihandles(hObj); obj = getappdata(hs.figure_main,'qtExamObject');

    % Check for current support and selection change
    if ~strcmpi(getappdata(hs.figure_main,'examtype'),'surgery') ||...
                              getappdata(hObj,'currentvalue')==get(hObj,'Value')
        return
    end

    % Delete any graphics objects
    obj.delete_go('regions'); obj.delete_go('text');

    % Get reformat images and limits
    obj.reformat(get(hObj,'Value'));
    m = size(obj.images(1,1)); scale = obj.opts.scale; m = m*scale+0.5;
    set(hs.axes_main,'XLim',[0.5 m(2)],'YLim',[0.5 m(1)]);

    % Reformat/show images and text; store app data
    obj.show('image','rois','text');
    setappdata(hObj,'currentvalue',get(hObj,'Value'));

end %change_view_Callback