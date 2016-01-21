function open_file_Callback(hObj,~)
%open_file_Callback  Callback for handling file opening requests
%
%   open_file_Callback(H,EVENT)

    % Get exams object
    hFig = gcbf;
    obj  = getappdata(hFig,'qtExamObject');

    % Hide/disable GUI controls and displays
    update_controls(hFig,'hide','disable');

    % Create a task specific variable for displaying an error message in the
    % event that data are not loaded
    errMsg = '';

    % When loading full QT save files or only the images from a specified file,
    % this must overwrite all image data (at least until I find a better way to
    % handle combining data sets). Prompt the user for the go-ahead
    objTag = get(hObj,'Tag');
    if ~isempty(obj) && obj.exists.any && any( strcmpi(objTag,...
                 {'menu_open_file','uipushtool_open_file','menu_load_images'}) )
        ovrwrtStr = questdlg('Overwrite all images/ROIs?',...
                                             'Overwrite Data','Yes','No','Yes');
        if (isempty(ovrwrtStr) || strcmpi(ovrwrtStr,'no'))
            % User cancelled or does not want to overwrite, reinstate the UI
            % controls and exit
            update_controls(hFig,'enable');
            return
        end
    end

    % Loads QUATTRO save file
    switch objTag
        case {'menu_open_file','uipushtool_open_file','menu_load_images'}

            % Create a new qt_exam object since the last one was deleted to
            % complete the overwrite operation. When loading a save file that
            % contains multiple exams, only the first exam will be shown (the
            % one on which create_exam_events was called). When changing exams,
            % the listeners will be cleared and recreated for the new exam
            obj = qt_exam(hFig);
            create_exam_events(obj);

            % Default "load" error message
            if ~obj.exists.any
                errMsg  = 'No saved data were loaded.';
            end

            % Create the "dataType" string
            dataType = 'any';
            if strcmpi(objTag,'menu_load_images')
                dataType = 'images';
            end

        case 'menu_load_rois' %load ROIs only from QT save
            dataType = 'rois';
            errMsg   = 'No ROIs were loaded.';

        case 'menu_load_maps' %load parameter maps only from QT save
            dataType = 'maps';
            errMsg   = 'No parameter maps were loaded.';

    end

    % Load the data
    qt_exam.load(obj,'',dataType);

    %FIXME: this is a temporary measure to ensure that ROI tools are updated
    %properly after loading a saved QUATTRO exam
    notify(obj,'roiChanged');

    % Update UI controls
    %FIXME: how to handle the errMsg now that the above switch is used only for
    %determining the load data type...
%     if ~isempty(errMsg)
%         errordlg(errMsg,'Error','modal');
%     else
%         % Updates image and ROIs
%         hSmooth        = getCheckedMenu( findobj(hFig,'Tag','menu_smoothing') );
%         mag            = get(hSmooth,'Label');
%         mag            = str2double(mag(1));
%         obj.opts.scale = mag;
%     end

    % Cache the new qt_exam object in the application data
    setappdata(hFig,'qtExamObject',obj);

    % Show the new image/ROI. Calls to "open_file_Callback" should *always*
    % create a new view when showing images. There is no need to use the
    % qt_image object replacement syntax of the qt_image method "show"
    if ~isempty(obj.image)
        hAx  = findobj(obj.hFig,'Tag', 'axes_main');
        obj(obj.examIdx).image.show(hAx);
    end

    % Update GUI state
    update_controls(hFig,'enable');

end %open_file_Callback