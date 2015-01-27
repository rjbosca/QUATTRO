function gui_menus(hQt)
%gui_menus  Builds QUATTRO menus
%
%   qui_menus(H) attaches main GUI specific menus to the figure handle for
%   QUATTRO specified by H

    % Verify input
    if isempty(hQt) || ~ishandle(hQt) || ~strcmpi(get(hQt,'Name'),qt_name)
        error(['QUATTRO:' mfilename ':qtHandleChk'],...
                                            'Invalid handle to QUATTRO figure');
    end

    % File menu
    hF  = uimenu('Parent',hQt,...
                 'Label','File',...
                 'Tag','menu_file');
          uimenu('Parent',hF,...
                 'Accelerator','L',...
                 'Callback',@open_file_Callback,...
                 'Label','Open File',...
                 'Tag','menu_open_file');
    hS  = uimenu('Parent',hF,...
                 'Label','Load Only...',...
                 'Tag','menu_load_only');
          uimenu('Parent',hS,...
                 'Callback',@open_file_Callback,...
                 'Label','Images',...
                 'Tag','menu_load_images');
          uimenu('Parent',hS,...
                 'Callback',@open_file_Callback,...
                 'Enable','off',...
                 'Label','Maps',...
                 'Tag','menu_load_maps');
          uimenu('Parent',hS,...
                 'Callback',@open_file_Callback,...
                 'Enable','off',...
                 'Label','ROIs',...
                 'Tag','menu_load_rois');
          uimenu('Parent',hF,...
                 'Accelerator','S',...
                 'Callback',@save_Callback,...
                 'Enable','off',...
                 'Label','Save',...
                 'Tag','menu_save');
          uimenu('Parent',hF,...
                 'Callback',@save_Callback,...
                 'Enable','off',...
                 'Label','Save As...',...
                 'Tag','menu_save_as');
    hS  = uimenu('Parent',hF,...
                 'Enable','off',...
                 'Label','Save Only...',...
                 'Tag','menu_save_only');
          uimenu('Parent',hS,...
                 'Callback',@save_Callback,...
                 'Label','Images',...
                 'Tag','menu_save_images');
          uimenu('Parent',hS,...
                 'Callback',@save_Callback,...
                 'Enable','off',...
                 'Label','Maps',...
                 'Tag','menu_save_maps');
          uimenu('Parent',hS,...
                 'Callback',@save_Callback,...
                 'Enable','off',...
                 'Label','ROIs',...
                 'Tag','menu_save_rois');
          uimenu('Parent',hF,...
                 'Callback',@options_Callback,...
                 'Label','Preferences',...
                 'Separator','on',...
                 'Tag','menu_preferences');
    hS  = uimenu('Parent',hF,...
                 'Label','Import',...
                 'Separator','on',...
                 'Tag','menu_import');
          uimenu('Parent',hS,...
                 'Callback',@import_Callback,...
                 'Label','Images',...
                 'Tag','menu_import_images');
          uimenu('Parent',hS,...
                 'Callback',@import_Callback,...
                 'Enable','off',...
                 'Label','ROIs',...
                 'Tag','menu_import_rois');
          uimenu('Parent',hS,...
                 'Callback',@import_Callback,...
                 'Enable','off',...
                 'Label','Maps',...
                 'Tag','menu_import_maps');
    hS  = uimenu('Parent',hF,...
                 'Enable','off',...
                 'Label','Export',....
                 'Tag','menu_export');
    hSs = uimenu('Parent',hS,...
                 'Enable','off',...
                 'Label','Images/Maps',...
                 'Tag','menu_export_images');
          uimenu('Parent',hSs,...
                 'Callback',@export_images_Callback,...
                 'Label','DICOM',...
                 'Tag','menu_export_images_dicom');
          uimenu('Parent',hSs,...
                 'Callback',@export_images_Callback,...
                 'Label','Raw',...
                 'Tag','menu_export_images_raw');
    hSs = uimenu('Parent',hS,...
                 'Enable','off',...
                 'Label','ROIs',...
                 'Tag','menu_export_rois');
          uimenu('Parent',hSs,...
                 'Callback',@export_rois_Callback,...
                 'Label','CineTool',...
                 'Tag','menu_export_rois_cinetool');
          uimenu('Parent',hSs,...
                 'Callback',@export_rois_Callback,...
                 'Label','Masks',...
                 'Tag','menu_export_rois_masks');
          uimenu('Parent',hSs,...
                 'Callback',@export_rois_Callback,...
                 'Label','Nordic ICE',...
                 'Tag','menu_export_rois_nordic_ice');
          uimenu('Parent',hSs,...
                 'Callback',@export_rois_Callback,...
                 'Label','Pinnacle',...
                 'Tag','menu_export_rois_pinnacle');

    % Exam menu
    hF  = uimenu('Parent',hQt,...
                 'Enable','off',...
                 'Label','Exam',...
                 'Tag','menu_exam');
    hS  = uimenu('Parent',hF,...
                 'Enable','off',...
                 'Label','Exam Type',...
                 'Tag','menu_type');
          uimenu('Parent',hS,...
                 'Callback',@change_exam_type_Callback,...
                 'Checked','on',...
                 'Label','Generic',...
                 'Tag','menu_generic');
          uimenu('Parent',hS,...
                 'Callback',@change_exam_type_Callback,...
                 'Label','DCE',...
                 'Tag','menu_dce');
          uimenu('Parent',hS,...
                 'Callback',@change_exam_type_Callback,...
                 'Label','DSC',...
                 'Tag','menu_dsc');
          uimenu('Parent',hS,...
                 'Callback',@change_exam_type_Callback,...
                 'Label','eDWI',...
                 'Tag','menu_edwi');
          uimenu('Parent',hS,...
                 'Callback',@change_exam_type_Callback,...
                 'Label','DWI',...
                 'Tag','menu_dwi');
          uimenu('Parent',hS,...
                 'Callback',@change_exam_type_Callback,...
                 'Label','DTI',...
                 'Tag','menu_dti');
          uimenu('Parent',hS,...
                 'Callback',@change_exam_type_Callback,...
                 'Label','Multi-Flip Angle',...
                 'Tag','menu_multiflip');
          uimenu('Parent',hS,...
                 'Callback',@change_exam_type_Callback,...
                 'Label','Saturation Recovery',...
                 'Tag','menu_multitr');
          uimenu('Parent',hS,...
                 'Callback',@change_exam_type_Callback,...
                 'Label','Multi-Inversion Time',...
                 'Tag','menu_multiti');
          uimenu('Parent',hS,...
                 'Callback',@change_exam_type_Callback,...
                 'Label','Multi-Echo Time',...
                 'Tag','menu_multite');
          uimenu('Parent',hS,...
                 'Callback',@change_exam_type_Callback,...
                 'Label','Surgery Planning',...
                 'Tag','menu_surgery');
          uimenu('Parent',hF,...
                 'Callback',@add_exam_Callback,...
                 'Label','Add',...
                 'Separator','on',...
                 'Tag','menu_add_exam');
          uimenu('Parent',hF,...
                 'Callback',@remove_exam_Callback,...
                 'Label','Remove',...
                 'Tag','menu_remove_exam');
          uimenu('Parent',hF,...
                 'Callback',@rename_exam_Callback,...
                 'Label','Rename',...
                 'Tag','menu_rename_exam');

    % Image menu
    hF  = uimenu('Parent',hQt,...
                 'Enable','off',...
                 'Label','Image',...
                 'Tag','menu_image');
    hS  = uimenu('Parent',hF,...
                 'Label','Smoothing',...
                 'Tag','menu_smoothing',...
                 'Visible','off');
          uimenu('Parent',hS,...
                 'Callback',@smoothing_Callback,...
                 'Checked','on',...
                 'Label','1x',...
                 'Tag','menu_smoothing_1x');
          uimenu('Parent',hS,...
                 'Callback',@smoothing_Callback,...
                 'Label','2x',...
                 'Tag','menu_smoothing_2x');
          uimenu('Parent',hS,...
                 'Callback',@smoothing_Callback,...
                 'Label','4x',...
                 'Tag','menu_smoothing_4x');
          uimenu('Parent',hS,...
                 'Callback',@smoothing_Callback,...
                 'Label','8x',...
                 'Tag','menu_smoothing_8x');
    hS  = uimenu('Parent',hF,...
                 'Label','WW/WL Controls',...
                 'Tag','menu_ww_wl_controls');
          uimenu('Parent',hS,...
                 'Callback',@lock_ww_wl_Callback,...
                 'Label','Lock WW/WL',...
                 'Tag','menu_lock_ww_wl');
          uimenu('Parent',hS,...
                 'Callback',@set_ww_wl_Callback,...
                 'Label','Set WW/WL',...
                 'Tag','menu_set_ww_wl');
          uimenu('Parent',hF,...
                 'Callback',@registration_Callback,...
                 'Label','Register Images',...
                 'Tag','menu_register_images');
          uimenu('Parent',hF,...
                 'Callback',@histogram_Callback,...
                 'Label','Histogram',...
                 'Tag','menu_histogram');
    hF  = uimenu('Parent',hQt,...
                 'Enable','off',...
                 'Label','Analysis',...
                 'Tag','menu_analysis');
          uimenu('Parent',hF,...
                 'Callback',@options_Callback,...
                 'Label','Map Options',...
                 'Tag','menu_map_options');
          uimenu('Parent',hF,...
                 'Callback',@options_Callback,...
                 'Tag','menu_exam_options');
          uimenu('Parent',hF,...
                 'Callback',@modeling_Callback,...
                 'Label','Modeling',...
                 'Separator','on',...
                 'Tag','menu_modeling');
          uimenu('Parent',hF,...
                 'Callback',@calculate_maps_Callback,...
                 'Label','Calculate Maps',...
                 'Tag','menu_calculate_maps');
    hS  = uimenu('Parent',hF,...
                 'Label','Response Tools',...
                 'Separator','on',...
                 'Tag','menu_calissification_tools',...
                 'Callback',@qt_response_gui);
    % h_ss = uimenu('Parent',h_s, 'Label','Train',...
    %                    'Tag','menu_train');
    %        uimenu('Parent',h_s, 'Callback',@make_predictions_Callback,...
    %                    'Label','Make Predictions',...
    %                    'Tag','menu_make_predictions_Callback');
    %        uimenu('Parent',h_ss,'Callback',@new_training_data_Callback,...
    %                    'Label','New Training Data',...
    %                    'Tag','menu_new_training_data');
    %        uimenu('Parent',h_ss,'Callback',@add_training_data_Callback,...
    %                    'Label','Add Training Data',...
    %                    'Tag','menu_add_training_data');
          uimenu('Parent',hF,...
                 'Callback',@trim_stats_Callback,...
                 'Label','Trim Stats',...
                 'Separator','on',...
                 'Tag','menu_trim_stats');
    hS  = uimenu('Parent',hF,...
                 'Enable','off',...
                 'Label','SNR Calcs',...
                 'Tag','menu_snr_calcs');
          uimenu('Parent',hS,...
                 'Callback',@change_snr_calc_Callback,...
                 'Checked','on',...
                 'Label','Single ROI',...
                 'Tag','menu_single_roi_snr')
          uimenu('Parent',hS,...
                 'Callback',@change_snr_calc_Callback,...
                 'Label','Noise ROI',...
                 'Tag','menu_noise_roi_snr');
    hF  = uimenu('Parent',hQt,...
                 'Enable','off',...
                 'Label','Reports',...
                 'Tag','menu_reports');
    hS  = uimenu('Parent',hF,...
                 'Enable','off',...
                 'Label','ROI',...
                 'Tag','menu_roi_reports');
          uimenu('Parent',hS,...
                 'Callback',@reports_Callback,...
                 'Label','Pixels',...
                 'Tag','menu_report_roi_pixels');
          uimenu('Parent',hS,...
                 'Callback',@reports_Callback,...
                 'Label','Summary',...
                 'Tag','menu_report_roi_summary');
          uimenu('Parent',hS,...
                 'Callback',@reports_Callback,...
                 'Label','Pixel Series',...
                 'Tag','menu_report_roi_pixel_series');
          uimenu('Parent',hF,...
                 'Callback',@reports_Callback,...
                 'Label','VIF',...
                 'Tag','menu_report_vif');
          uimenu('Parent',hQt,...
                 'Callback',@get_windows_Callback,...
                 'Label','Window',...
                 'Tag','menu_window');
    hF  = uimenu('Parent',hQt,...
                 'Label','Scripts',....
                 'Tag','menu_scripts');
          uimenu('Parent',hF,...
                 'Callback',@new_script_Callback,...
                 'Label','New',...
                 'Tag','new_script');
          uimenu('Parent',hF,...
                 'Callback',@edit_script_Callback,...
                 'Label','Edit',...
                 'Tag','edit_script');
          uimenu('Parent',hF,...
                 'Callback',@delete_script_Callback,...
                 'Label','Delete',...
                 'Tag','delete_script');
          uimenu('Parent',hF,...
                 'Callback',@import_script_Callback,...
                 'Label','Import',...
                 'Tag','import_script');
    hF  = uimenu('Parent',hQt,...
                 'Label','Help',...
                 'Tag','menu_help');
          uimenu('Parent',hF,...
                 'Callback',@about_menu_Callback,...
                 'Label','About',...
                 'Tag','menu_about');

    % Update some menus
    update_menu_scripts(hQt);

    % Attach listeners to linked GUI/context menus
    hLink = findobj(hQt,'Tag','menu_lock_ww_wl');
    addlistener(hLink,'Checked','PostSet',@menu_checked_postset);

end %gui_menus


%-----------------------Callback/Ancillary Functions----------------------------

function about_menu_Callback(hObj,eventdata)
end %about_menu_Callback

function add_exam_Callback(hObj,eventdata) %#ok<*INUSD>

    % Call GUI
    [method,eName,eType] = add_exam_window;
    if isempty(method)
        return
    end

    % Add the new exam
    %TODO: does the full workspace need to be used? It's much faster, especially
    %for large data sets to only grab the current qt_exam object
    obj = getappdata(gcbf,'qtWorkspace');
    obj = obj.addexam(method,eName,eType);

    % Modify the pop-up menu to reflect the changes
    hPop = findobj(gcbf,'Tag','popupmenu_exams');
    set(hPop,'String',{obj.name},'Value',numel(obj));

    % Update the qt_exam objects' "examIdx"
    obj(obj(1).examIdx).examIdx = numel(obj); %#ok - no need to store...

end %add_exam_Callback

function add_training_data_Callback(hObj,eventdata)

    % Load training data
    obj         = getappdata(guifigure(hObj),'qtExamObject');
    [fName, ok] = cine_dlgs('classification_load',mfilepath);
    if ~ok
        return
    end
    load(fullfile(mfilepath,fName));
    if ~exist('b','var') && strcmpi(class(b),'TreeBagger')
        errordlg('Invalid training file');
        return
    end

    % Check for background label
    if ~any( strcmpi('background',obj.regions('names')) )
        errordlg('Please draw a ''background'' ROI.');
        return
    end

    % Loop through all ROIs
    roi    = obj.regions;
    m      = size(obj.images(1,1));
    data   = cell(1,obj.size('headers',2));
    labels = {};
    for i = 1:length(roi)
        for j = 1:obj.size('headers',1)
            for k = 1:obj.size('headers',2);
                % Get mask
                mask = obj.get_mask('size',m','index',{i,j,1});
                if isempty(mask)
                    continue
                end

                % Get pixel values
                im = obj.images(j,k); pix = double(im(mask));
                data{k} = [data{k}; pix];
                if k==1
                    [labels{end+1:end+length(pix)}] = deal(obj.regions(i,j,k,'names'));
                end
            end
        end
    end

    % Special case for DCE
    if strcmpi(getappdata(hQt,'examtype'),'dce')
        data = cell2mat(data);

        % Determine new vector size
        t = mInfo.xvals; n = round( t(2)*(obj.size('headers',2)-1) );
        dataNew = zeros(size(data,1),n);
        for i = 1:size(data,1)
            dataNew(i,:) = interpft(data(i,:),n);
        end

        % Remove data immediately before contrast arrival
        t0 = floor( t(obj.opts.preEnhance) );
        dataNew(:,1:t0-1) = [];
        data = dataNew;

        % Ensure data is the same size
        if size(b.X,2) > size(data,2)
            data(:,end+1:size(b.X,2)) = NaN;
        elseif size(b.X,2) < size(data,2)
            data = data(:,1:size(b.X,2));
        end

    else
        data = cell2mat(data);
    end

    % Combine training data
    data = [b.X; data]; labels = [b.Y; labels'];
    bNew = TreeBagger(50,data,labels,'oobvarimp','on',...
                                              'oobpred','on','NPrint',true);

    % Save training data
    save(fullfile(mfilepath,[fName '.mat']),'b');

end %add_training_data_Callback

function calculate_maps_Callback(hObj,eventdata)

    % Grab the necessary handles/objects
    hQt = guifigure(hObj);
    obj = getappdata(hQt,'qtExamObject');
%TODO: Create code to perform image transformations from loaded
%registration results prior to calculating maps
    obj.calculatemaps;

    % Update the GUI
    if obj.exists.maps.any
        h = findobj(hQt,'Tag','uipanel_maps');
        set(h,'Visible','on');
    end
    update_map_popupmenu(hQt,obj);
    update_controls(hQt,'enable');

end %calculate_maps_Callback

function change_exam_type_Callback(hObj,eventdata)

    % Grab the figure handle, exam type sub-menus, and qt_exam object
    hFig = guifigure(hObj);
    obj  = getappdata(hFig,'qtExamObject');

    % Determine if any change has actually occured. Changing the exam type can
    % be computationally intensive....
    if strcmpi( get(hObj,'Checked'), 'on' )
        return
    end

    % Note that the menu property "Checked" will be updated in the listener of
    % the qt_exam property "type"

    % Set the new exam type
    obj.type = strrep( get(hObj,'Tag'), 'menu_', '' );

end %change_exam_type_Callback

function change_snr_calc_Callback(hObj,eventdata)

    % Get handles and exams object
    hs  = guihandles(hObj);
    obj = getappdata(hs.figure_main,'qtExamObject');

    % Changes checks
    if strcmpi( get(hObj,'Checked'), 'on' )
        return
    end

    % Update the menus
    set(hObj,'Checked','on');
    if (hObj==hs.menu_noise_roi_snr)
        set(hs.menu_single_roi_snr,'Checked','off');
    else
        set(hs.menu_noise_roi_snr,'Checked','off');
    end

    % Manually call "update_roi_stats" to fire the changes
    update_roi_stats([],struct('AffectedObject',obj.roi),hs.figure_main);

end %change_snr_calc_type_Callback

function delete_script_Callback(hObj,eventdata)

    % Find the menu handles
    hQt   = guifigure(hObj);
    hMenu = findobj(hQt,'Tag','menu_scripts');
    hKids = get(hMenu,'Children');

    % Ignore the static menus
    hKids(end-3:end) = [];

    % Let the user select the script to edit
    [sel,ok] = listdlg('ListString',get(hKids,'Label'),...
                       'Name','Script',...
                       'PromptString','Select Script:');
    if ~ok || isempty(sel)
        return
    end

    % Are you sure you want to delete?
    ok = questdlg('Delete these scripts?','Delete?','Yes','No','No');
    if isempty(ok) || strcmpi(ok,'no')
        return
    end

    % Get the exams object (need the options structure)
    obj = getappdata(hQt,'qtExamObject');

    % Delete the files and menu items
    for idx = 1:length(sel)
        fName = getappdata(hKids(idx),'fileName');
        fName = [fullfile(obj.opts.scptDir,fName) '.m'];
        delete(hKids(idx));
        if ~exist(fName,'file')
            continue
        end
        delete(fName);
    end

    % Update the menus
    update_menu_scripts(obj.hFig)

end %delete_script_Callback

function edit_script_Callback(hObj,eventdata)

    % Find the menu handles
    hMenu = findobj( guifigure(hObj),'Tag','menu_scripts');
    hKids = get(hMenu,'Children');

    % Ignore the static menus
    hKids(end-3:end) = [];

    % Let the user select the script to edit
    [sel,ok] = listdlg('ListString',get(hKids,'Label'),...
                       'Name','Script',...
                       'PromptString','Select Script:',...
                       'SelectionMode','single');
    if ~ok || isempty(sel)
        return
    end

    % Get the file name and load the script in the editor
    fName = strrep( get(hKids(sel),'Tag'),'script_','');
    edit([fName '.m']);

end %edit_script_Callback

function export_images_Callback(hObj,eventdata)

    % Get handles and exams object
    hFig  = gcbf;
    obj   = getappdata(hFig,'qtExamObject');
    eType = obj.type;

    % Determines options for writing. These options should include any
    % calculated maps, modified images (i.e. images with a non-empty pipeline),
    % and, for surgery planning exams, the pixel burn-in
    %TODO: prepare code that determines if any images have non-empty pipelines
    %and update the exportOptions accordingly
%     exportOptions = [obj.mapNames;{'Burn-in'}];
%     if ~strcmpi(eType,'surgery') %remove surgery only options
%         exportOptions(end) = [];
%     end
%     [selection,ok] = listdlg('PromptString','Select Data to Export',...
%                              'ListString',exportOptions);
%     if ~ok
%         return
%     end

    % Determine where to export the data
    [sDir,ok] = qt_uigetdir(obj.opts.exportDir,'Select Export Directory:');
    if ~ok
        return
    end

    % Disable user controls, perform the export operation, and re-enable the
    % user controls
    update_controls(hFig,'disable');
    obj.export('maps',sDir);
    update_controls(hFig,'enable');

end %export_images_Callback

function export_rois_Callback(hObj,eventdata)

    if ~logical(hObj)
        return
    end

    % Deteremine export type
    exType = regexp(get(hObj,'Tag'),'rois_(\w*)','tokens');
    exType = strrep(exType{1}{1},'_','');

    % Get directory and ROIs from user
    hQt       = guifigure(hObj);
    obj       = getappdata(hQt,'qtExamObject');
    [sDir,ok] = cine_dlgs('export_directory');
    if ~ok
        return
    end
    [sel,ok] = cine_dlgs('export_roi_list',obj.regions('names'));
    if ~ok || isempty(sel)
        return
    end

    % Export ROIs
    obj.export(exType,sDir,sel);

end %export_rois_Callback

function get_windows_Callback(hObj,eventdata)

    %TODO: this can likely be handled much more easily using the qt_exams
    %object...

    % Get handles and delete previous children
    hs = guidata(hObj); delete( get(hObj,'Children') );

    % Find all figures and prep the sub-menus
    hFigs                        = findall(0,'Tag','figure_main');
    hFigs(hFigs==hs.figure_main) = [];
    f = @(x) uimenu('Parent',hObj,...
                    'Callback',@(h,ed) figure(x),...
                    'Label',get(x,'Name'),...
                    'Tag','menu_go2figure');

    % Build sub-menus
    uimenu('Parent',hObj,...
           'Label',get(hs.figure_main,'Name'),...
           'Tag','menu_go2figure')
    for winIdx = 1:length(hFigs)
        if (getappdata( hFigs(winIdx), 'linkedfigure' )==hs.figure_main)
            f(hFigs(winIdx));
        end
    end

    % Set separator
    set( findobj(hObj,'Position',2), 'Separator','on' );

end %get_windows_Callback

function histogram_Callback(hObj,eventdata)

    % Get handles and exams object
    hQt = guifigure(hObj);
    obj = getappdata(hQt,'qtExamObject');

    % Register with exams object
    hFig = hist_viewer(hQt);
    obj.register(hFig);
    setappdata(hFig,'updatefcn',@() show_hist(hFig));

end %histogram_Callback

function import_script_Callback(hObj,eventdata)

    % Get the qt_exam object
    obj = getappdata( guifigure(hObj), 'qtExamObject' );

    % Let user select file
    [fName,ok] = qt_uigetfile({'*.m','M-Files'},'Select Script to Import',pwd);
    if ~ok
        return
    end

    % Determine if the file already exists and request user's desired action.
    isCopy = true; %initialzie the "copy" flag
    if (exist(fName,'file')==2)
        btn = questdlg('The file already exists. What would you like to do?',...
                             'File Action','Overwrite','Keep Both','Keep Both');
        if isempty(btn)
            return
        end
        isCopy = strcmpi(btn,'overwrite');
    end

    % Perform the file action
    if isCopy
        copyfile(fName,obj.opts.scptDir);
    else
        newName = fName;
        while (exist(newName,'file')==2)

            % Attempt to find a previous copy
            [~,str,ext]  = fileparts(newName);
            %TODO: fix this. can't seem to search for '*.'
            copyNumStart = regexp(str,'[_]\d+');

            % Generate a new file "copy" number
            if isempty(copyNumStart)
                newName = [str '_1' ext];
            else
                newNum  = str2double(str(copyNumStart+1:end))+1;
                newName = [str(1:copyNumStart) num2str(newNum) ext];
            end
        end

        % Copy the file and updat "fName" to reflect the change
        copyfile( fName, fullfile(obj.opts.scptDir,newName) );
    end

    %TODO: build a test to ensure that another file in MATLAB's path will not
    %conflict with this script when called using eval.

    % Attempt to run the script. If this attempt fails, delete the file from the
    % scripts directory
    [~,fName] = fileparts(fName); %strip the file path and extension
    try
        eval([fName ';']);
    catch ME
        if strcmpi(ME.identifier,'MATLAB:minrhs')
            warning('QUATTRO:scripts:nameChk',...
                     ['Invalid script syntax. See README.txt',...
                     '\n%s not loaded.\n'],fName);
            delete(fName);
        else
            rethrow(ME);
        end

        % Return before updating the menus
        return
    end

    % Update the script menu to reflect the addition of the new script
    update_menu_scripts(obj.hFig);

end %import_script_Callback

function make_predictions_Callback(hObj,eventdata)

    % Load training data
    [fName,ok] = cine_dlgs('classification_load',mfilepath);
    if ~ok
        return
    end
    load(fullfile(mfilepath,fName));
    if ~exist('b','var') && strcmpi(class(b),'TreeBagger') %#ok
        errordlg('Invalid training file');
        return
    end

    % Loop through the slices
    hs  = guidata(hObj);
    obj = getappdata(hs.figure_main,'qtExamObject');
    ims = obj.images;
    imM = size(ims{1,1});
    sl  = get(hs.slider_slice,'Value');
    % for i = 1:obj.size('headers',1)
        % Generate data to train
        x    = cell2mat(ims(sl,:));
        x    = squeeze( reshape(x,imM(1),imM(2),[]) );
        xCol = zeros(numel(x(:,:,1)),size(x,3)); n = 1;
        for j = 1:size(x,2)
            for k = 1:size(x,1)
                xCol(n,:) = x(k,j,:);
                n = n+1;
            end
        end
        clear x

        % Special case for DCE
        if strcmpi( getappdata(hs.figure_main,'examtype'),'dce')
            % Calculate t0 and temporal vector
            t     = mInfo.xvals;
            tr    = mInfo.params.tf;
            fa    = mInfo.params.fa;
            [t0,t10,r] = deal_cell(get(obj.opts,{'preEnhance','bloodT10',...
                                                             'r1Gd'}));

            % Remove pre-contrast
            if obj.opts.t1Correction
                for i = 1:size(xCol,1)
                    xCol(i,:) = si_ratio2gd(t0,xCol(i,:),fa,tr,t10,r,true);
                end
            else
                xCol = xCol - repmat( mean(xCol(:,1:t0),2), [1 size(xCol,2)]);
            end
            xCol(:,1:t0) = [];
            tNew         = t(t0+1:end)-t(t0+1);


            % Get prediction data and re-predict
    %         if i==1
                x = b.X;
                y = b.Y;
                tEnd = ceil(tNew(end));
                if tEnd<size(x,2)
                    x = x(:,1:tEnd);
                end
                if tEnd>size(x,2)-1 %remove 
                    xCol(:,tNew>size(x,2)-1) = [];
                    tNew(tNew>size(x,2)-1) = [];
                end
                x = interp1(0:size(x,2)-1,x',tNew,'spline')';

                % Normalize to maximum
                x = x/max(x(:)); xCol = xCol/max(xCol(:));
                b = TreeBagger(50,x,y,'oobvarimp','on','oobpred','on','NPrint',true);
    %         end
        end

        % Train data
        [y,score] = b.predict(xCol);
    tic;
        maskRgb = zeros([imM 3]);

        % Generate mask
        imM            = size(ims{sl});
        maskRgb(:,:,:) = 0;
        m              = reshape(cellfun(@(x) strcmpi(x,'arterial'),y),imM);
        maskRgb(:,:,1) = m;
    %     m = reshape(cellfun(@(x) strcmpi(x,'venous'),y),im_m); mask_rgb(:,:,2) = m;

        % Show image with mask
        hFig(1) = figure; subplot(1,2,1); title('Raw Prediction');
        imshow(ims{sl,get(obj.h_sl(2),'Value')},[]); hold on; h = imshow(maskRgb);
        set(h,'AlphaData',0.75*any(maskRgb,3));

        % Show scores for each class
        scoreA = reshape(score(:,1),imM);
    %     scoreV = reshape(score(:,2),im_m);
        scoreT = reshape(score(:,2),imM);
        hFig(2) = figure;
        subplot(1,2,1); imagesc(scoreA,[0 1]); title('Prediction Score (Arterial)');
    %     subplot(1,3,2); imagesc(scoreV,[0 1]); title('Prediction Score (Venous)');
        subplot(1,2,2); imagesc(scoreT,[0 1]); title('Prediction Score (Background)');

        % Try to refine guesses and make predictions
        aMask = scoreA > 0.5;
    %     n = 1000; tf = true;
    %     while tf || n < 0
    %         aMaskNew = bwareaopen(a_mask,n);
    %         tf = ~any(aMaskNew(:));
    %         n = n-1;
    %     end

        % Let user choose which is better
    %     h_quest = figure; subplot(1,2,1); imshow(a_mask); title('initial')
    %     subplot(1,2,2); imshow(aMaskNew); title('refined');
    %     b = questdlg('Which mask?','Mask...','Initial','Refined','Refined');
    %     if strcmpi(b,'refined')
    %         aMask = aMaskNew;
    %     end
    %     delete(hQuest);

        % Show image with mask for class>thresh
        maskRgb(:,:,:) = 0;
        maskRgb(:,:,1) = aMask;
    %     mask_rgb(:,:,2) = scoreV > thresh;

        % Clean up artery/vein masks
        aMask          = logical(squeeze(maskRgb(:,:,1))); 
        aMask          = bwmorph(aMask,'clean',50);
        aMask          = bwmorph(aMask,'open');
        aMask          = bwmorph(aMask,'majority');
        maskRgb(:,:,1) = aMask;
    %     v_mask = logical(squeeze(mask_rgb(:,:,2)));
    %     v_mask = bwmorph(v_mask,'open',15); mask_rgb(:,:,2) = v_mask;

        figure(hFig(1)); subplot(1,2,2); title('Refined Prediction');
        imshow(ims{sl,get(obj.h_sl(2),'Value')},[]); hold on; h = imshow(maskRgb);
        set(h,'AlphaData',0.75*any(maskRgb,3));

    %     % Generate mask
    %     m = reshape(cellfun(@(x) strcmpi(x,'10%'),y),im_m)'; mask_rgb(:,:,1) = m;
    %     m = reshape(cellfun(@(x) strcmpi(x,'20%'),y),im_m)'; mask_rgb(:,:,2) = m;
    %     m = reshape(cellfun(@(x) strcmpi(x,'25%'),y),im_m)'; mask_rgb(:,:,3) = m;
    %     m = reshape(cellfun(@(x) strcmpi(x,'30%'),y),im_m)';
    %     for j = 1:3
    %         mask_rgb(:,:,j) = double(logical(m) | logical(squeeze(mask_rgb(:,:,j))));
    %     end
    %     m = reshape(cellfun(@(x) strcmpi(x,'35%'),y),im_m)';
    %     for j = 1:2
    %         mask_rgb(:,:,j) = double(logical(m) | logical(squeeze(mask_rgb(:,:,j))));
    %     end
    %     m = reshape(cellfun(@(x) strcmpi(x,'40%'),y),im_m)';
    %     for j = [1 3]
    %         mask_rgb(:,:,j) = double(logical(m) | logical(squeeze(mask_rgb(:,:,j))));
    %     end
    %     m = reshape(cellfun(@(x) strcmpi(x,'45%'),y),im_m)';
    %     for j = 2:3
    %         mask_rgb(:,:,j) = double(logical(m) | logical(squeeze(mask_rgb(:,:,j))));
    %     end
    % 
    % 
    %     % Show image with mask
    %     h_fig(1) = figure; imshow(ims{i,1},[]); hold on; h = imshow(mask_rgb);
    %     set(h,'AlphaData',0.75*any(mask_rgb,3)); title('Raw prediction');
    % 
    %     % Show scores for each class
    %     score10 = reshape(score(:,1),im_m)';
    %     score20 = reshape(score(:,2),im_m)';
    %     score25 = reshape(score(:,3),im_m)';
    %     score30 = reshape(score(:,4),im_m)';
    %     score35 = reshape(score(:,5),im_m)';
    %     score40 = reshape(score(:,6),im_m)';
    %     score45 = reshape(score(:,7),im_m)';
    %     h_fig(2) = figure;
    %     subplot(4,2,1); imagesc(score10,[0 1]); title('Prediction Score (10%)');
    %     subplot(4,2,2); imagesc(score20,[0 1]); title('Prediction Score (20%)');
    %     subplot(4,2,3); imagesc(score25,[0 1]); title('Prediction Score (25%)');
    %     subplot(4,2,4); imagesc(score30,[0 1]); title('Prediction Score (30%)');
    %     subplot(4,2,5); imagesc(score35,[0 1]); title('Prediction Score (35%)');
    %     subplot(4,2,6); imagesc(score40,[0 1]); title('Prediction Score (40%)');
    %     subplot(4,2,7); imagesc(score45,[0 1]); title('Prediction Score (45%)');
    % 
    %     % Show image with mask for class>thresh
    %     mask_rgb(:,:,:) = 0; thresh = 0.6;
    %     mask_rgb(:,:,1) = score10 > thresh;
    %     mask_rgb(:,:,2) = score20 > thresh;
    %     mask_rgb(:,:,3) = score25 > thresh;
    %     for j = 1:3
    %         mask_rgb(:,:,j) = double(score30>thresh | logical(squeeze(mask_rgb(:,:,j))));
    %     end
    %     for j = 1:2
    %         mask_rgb(:,:,j) = double(score35>thresh | logical(squeeze(mask_rgb(:,:,j))));
    %     end
    %     for j = [1 3]
    %         mask_rgb(:,:,j) = double(score40>thresh | logical(squeeze(mask_rgb(:,:,j))));
    %     end
    %     for j = 2:3
    %         mask_rgb(:,:,j) = double(score45>thresh | logical(squeeze(mask_rgb(:,:,j))));
    %     end
    % 
    %     h_fig(3) = figure; imshow(ims{i,1},[]); hold on; h = imshow(mask_rgb);
    %     set(h,'AlphaData',0.75*any(mask_rgb,3));

        for ii = 1:length(hFig)
            if ishandle(hFig(ii))
                delete(hFig(ii))
            end
        end
        toc
    % end

end %make_predictions_Callback

function new_training_data_Callback(hObj,eventdata)

    % Get name for new training set
    [fName,ok] = cine_dlgs('classification_name');
    if ~ok
        return
    end

    % Check for background label
    hQt = guifigure(hObj);
    obj = getappdata(hQt,'qtExamObject');
    if ~any( strcmpi('background',obj.regions('names')) )
        errordlg('Please draw a ''background'' ROI.');
        return
    end

    % Loop through all ROIs
    roi = obj.regions; m = size(obj.images(1,1));
    data = cell(1,obj.size('headers',2));
    labels = {};
    for i = 1:length(roi)
        for j = 1:obj.size('headers',1)
            for k = 1:obj.size('headers',2);
                % Get mask
                mask = obj.get_mask('size',m','index',{i,j,1});
                if isempty(mask)
                    continue
                end

                % Get pixel values
                im = obj.images(j,k); pix = double(im(mask));
                data{k} = [data{k}; pix];
                if k==1
                    [labels{end+1:end+length(pix)}] = deal(obj.regions(i,j,k,'names'));
                end
            end
        end
    end

    % Special case for DCE
    if strcmpi(getappdata(hQt,'examtype'),'dce')
        [data,labels] = train_vif(data,labels,true,obj);
    else
        data = cell2mat(data);
    end

    % Perform training
    b = TreeBagger(50,data,labels,'oobvarimp','on',...
                                              'oobpred','on','NPrint',true);

    % Save training data
    save(fullfile(mfilepath,[fName '.mat']),'b');

end %new_training_data_Callback

function new_script_Callback(hObj,eventdata)

    % Get/validate the script name
    nm = inputdlg('Enter script name:','New Script',1);
    if isempty(nm)
        return
    end
    nm = nm{1};

    % Ensure that the name can be used as a file/function name
    nmF = strrep(nm,' ','_');
    nmF = rep_special_file_chars(nmF);

    % Define the string to write
    %TODO: update this to reflect my new style...
    s = {'function varargout = %s(hObj,eventdata)', nmF;...
         '%%%s  Executes a custom QUATTRO script', nmF;...
         '%%', '';...
         '%%\t%s returns the name of the script as shown under the "Scripts" menu', nmF;...
         '%%\tof the QUATTRO application', nmF;...
         '%%', '';...
         '%%\t%s(h,eventdata) is the syntax used to call the script from QUATTRO,', nmF;...
         '%%\twhere h is a handle to the menu automatically created by QUATTRO, and', '';...
         '%%\teventdata is unused (this may change in a future release). This syntax is', '';...
         '%%\tautomatic and is otherwise not used by the user.','';...
         '','';...
         '\t%% Define the script name as shown in the QUATTRO "Scripts" menu','';...
         '\tif nargin==0','';...
         '\t\tvarargout{1} = ''%s'';',nm;...
         '\t\treturn','';...
         '\tend','';...
         '','';...
         '\t%% Get the QUATTRO objects','';...
         '\t[examObject,modelObject,optionObject] = qt_objects(hObj);\n\n','';...
         'end %%%s',nmF};
    s = cellfun(@(x,y) sprintf(x,y),s(:,1),s(:,2),'UniformOutput',false);

    % Get the exams object (need the options structure)
    obj = getappdata(gcbf,'qtExamObject');

    % Write the new file
    fName = fullfile(obj.opts.scptDir,[nmF '.m']);
    fid   = fopen(fName,'w');
    if (fid==-1)
        warning(['QUATTRO:' mfilename ':writeError'],...
                 'Unable to write new script: %s\n',nm);
        return
    end
    cellfun(@(x) fprintf(fid,'%s\n',x),s);
    fclose(fid);

    % Update the script menu to reflect the addition of the new script
    update_menu_scripts(obj.hFig);

    % Open the new script for editing
    edit(fName);

end %new_script_Callback

function remove_exam_Callback(hObj,eventdata)

    % Get exams object and pop-up menu handle
    hQt = guifigure(hObj);
    obj = getappdata(hQt,'qtExamObject');

    % Remove the exam and update the pop-up menu
    obj.remove('exam');
    set(obj.h_exam,'String',obj.names,'Value',obj.exam_index);

    % Show the new images, maps, and ROIs
    obj.show('image','maps','rois');

end %remove_exam_Callback

function rename_exam_Callback(hObj,eventdata)

    % Get exams object and request the new name
    obj    = getappdata(gcbf,'qtExamObject');
    nm     = inputdlg('New exam name:','Exam Name?',1,{obj.name},...
                                                 struct('WindowStyle','modal'));
    if ~isempty(nm) && ~isempty(nm{1})
        obj.name = nm{1};
    end

end %rename_exam_Callback

function reports_Callback(hObj,eventdata)

    % Get the tag of the menu that was selected by the user
    vararg    = regexp(get(hObj,'Tag'),'report_(\w*)','Tokens');
    vararg{1} = strrep(vararg{1}{1},'roi_','');

    % Get the exams object
    hQt = guifigure(hObj);
    obj = getappdata(hQt,'qtExamObject');

    % Determine the number of ROIs. If more than one, the user gets to
    % decide which ones to report
    roiNms = obj.roiNames;
    if numel(roiNms)>1
        [vararg{4},ok] = cine_dlgs('export_roi_list',roiNms);
        if ~ok
            return
        end
        vararg{3} = 'Index';
    end

    % Determine the dialog box title (this is useful for users to know what
    % they selected from the "Report" menu)
    switch vararg{1}
        case 'pixels'
            dlgName = 'Create pixel report.';
        case 'summary'
            dlgName = 'Create ROI summary report.';
        case 'pixel_series'
            dlgName = 'Create pixel series report.';
        case 'vif'
            dlgName = 'Create VIF report.';
        otherwise
            warning(['QUATTRO:' mfilename ':invalidReportCallback'],...
                    'An invalid call was made to the reports_Callback.');
            return
    end

    % Get the file information
    [vararg{2},ok] = qt_uiputfile('*.txt',dlgName,obj.opts.reportDir);
    if ~ok
        errordlg('No report was created. Please specify a valid file.');
        return
    end
    obj.report(vararg{:});

    % Update the export director
    obj.opts.reportDir = fileparts(vararg{2});

end %reports_Callback

function smoothing_Callback(hObj,eventdata)

    % Some necessary data/checks
    hs     = guidata(hObj);
    obj    = getappdata(hs.figure_main,'qtExamObject');
    hAxes  = hs.axes_main;
    hImage = findobj(hAxes,'Tag','DICOM');
    if ~isNewSelection(hs.smoothing,hObj) || isempty(hImage)
        return
    end

    % Determines which option is selected/gets exams object
    hSmooth = getCheckedMenu(hs.smoothing);
    mag     = get(hSmooth,'Label');
    mag     = str2double(mag(1));

    % Stores new and old scales
    oldScale = obj.opts.scale;
    set(obj.opts,'scale',mag);

    % Deletes all children of AXES_MAIN
    deleteChildren(hs.axes_main,'Text');
    obj.delete_go('regions');

    % Get x/y limits and x/y data for the current axes/image
    lims   = get(hAxes,{'XLim','YLim'});
    imData = get(hImage,{'XData','YData'});

    % Ratio for image calculations
    r = mag/oldScale;

    % Update zoom limits
    newZoomX = [0 imData{1}(2)*r]+0.5; new_zoom_y = [0 imData{2}(2)*r]+0.5;
    set(hAxes,'XLim',newZoomX,'YLim',new_zoom_y);
    zoom reset

    % Changes axes limits for new scale
    newXLim = r*lims{1}; 
    newYLim = r*lims{2};
    set(hAxes,'XLim',newXLim,'YLim',newYLim);

    % Update GUI displays
    obj.show('image','maps','rois','text');
    obj.calc_stats;

end %smoothing_Callback

function trim_stats_Callback(hObj,eventdata)

    % Determine the percentage of stats to trim
    [pct,ok] = cine_dlgs('trim_stats');
    if ~ok
        return
    end

    % Sets trimmed stats field and calculate new stats
    hs  = guidata(hObj);
    obj = getappdata(hs.figure_main,'qtExamObject');
    obj.opts.trimPct = pct;
    obj.calc_stats;

    % Updates uipanel display
    if pct~=0
        set(hs.uipanel_roi_stats, 'Title',...
                                    ['ROI Trimmed Stats (' num2str(pct) '%)']);
    else
        set(hs.uipanel_roi_stats, 'Title', 'ROI Stats');
    end

end %trim_stats_Callback