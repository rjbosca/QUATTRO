function import_Callback(hObj,~)
%import_Callback  QUATTRO callback for handling import menu requests
%
%   import_Callback(H,EVENT) callback for all import menus, where H is the menu
%   handle and EVENT is an event data object (currently unused).

    % Get handles and exams object
    hFig = gcbf;
    obj  = getappdata(hFig,'qtExamObject');

    % Disable all controls
    update_controls(hFig,'disable');

    switch get(hObj,'Tag')
        case 'menu_import_images'

            % If data exists, do you really want to overwrite all data???
            if ~isempty(obj) && obj.exists.any
                ovrwrtStr = questdlg('Overwrite all images/ROIs?',...
                                             'Overwrite Data','Yes','No','Yes');
                if (isempty(ovrwrtStr) || strcmpi(ovrwrtStr,'no'))
                    % User cancelled or does not want to overwrite, reinstate
                    % the UI controls and exit
                    update_controls(hFig,'enable');
                    return
                end
            end

            % Call a sub-routine to overwrite all data stroed currently in
            % QUATTRO
            %FIXME: with the new way that QUATTRO is notified of changes to the
            %"rois" property, none of the following code removes any of the ROI
            %tools from the GUI when importing new data...
            overwrite_gui_data(hFig);

            % Hides all user controls and displays
            update_controls(hFig,'hide');

            % Create a new QT_EXAM object and load all image data from a user-
            % specified directory
            obj = qt_exam(hFig);
            create_exam_events(obj);
            obj = obj.addexam('import','NewExam','auto');
            if obj(1).exists.images.any
                % Show the image and image text, the import was successful
                hAx = findobj(obj(1).hFig,'Tag','axes_main');
                obj(1).image.show(hAx);
            end

            % Store the new object (this is necessary because when adding
            % new exams, a new qt_exam object is added to the stack)
            setappdata(hFig,'qtExamObject',obj(1));
            setappdata(hFig,'qtWorkspace',obj);

        case 'menu_import_rois'

            % Reads in an ROI and other associated Pinnacle files
            rois = roiimporttool(obj);
            if isempty( rois )
                % Enables previous functionality
                update_controls(hFig,'enable');
                return
            end

            % Deal ROI information
            colors = cellfun(@colorlookup,{rois.colors},'UniformOutput',false);
            [rois.colors] = deal(colors{:});

            % Store data
            for i = 1:length(rois)
                names = obj.regions('names');
                nInd = strcmp(rois(i).names,names);
                if any(nInd)
                    cInd = find(nInd);
                else
                    cInd = length(names)+1;
                end
                obj.regions(cInd,rois(i).slice,1,rois(i));
            end

        case 'menu_import_maps'

            % This script currently only supports data with fewer than 100
            % slices.

            % All files saved from CineTool are in a *.raw format and contain no
            % information such as  time point, patient, exam, etc. for which
            % these maps were calculated. The user must ensure that these data
            % are loaded appropriately.

            % If the field already exists, determine what to do with new map
%                 if obj.exist('overlays') && cine_dlgs('overwrite_maps')
%                     error('Program this!');
%                 elseif obj.exist('overlays')
%                     return
%                 end

            % User selects map type to load
            [mType,ok] = cine_dlgs('map_type');
            if ~ok
                update_controls(hFig,'enable');
                return
            end

            % User selects map files to load
            fltrSpec = {'*.dcm','DICOM Images (*.dcm)';...
                        '*.raw','RAW Format (*.raw)';...
                        '*.*',  'All Files (*.*)'};
            [fNames,ok,fltrIdx] = qt_uigetfile(fltrSpec,'Load overlays.',...
                                               obj.opts.mapDir,'on');
            if ok
                update_controls(hFig,'enable');
                return
            end

            % Determine the file format from the filter specification index
            if (fltrIdx==3) && isdicom(fNames{1})
                frmt = 'dcm';
            else
                frmt = 'raw';
            end

            % Add the maps
            obj.add_maps(mType,fNames,frmt);

            % Makes the overlay uipanel visible
            obj.show('maps');

    end

    % Restore appropriate control operation
    update_controls(hFig,'enable');

end %import_Callback