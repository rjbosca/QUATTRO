function varargout = cine_dlgs(varargin)
%CINE_DLGS  Displays dialogs and returns user input.

% Deals outputs
[varargout{1:nargout}] = deal([]);

switch lower(varargin{1})
    case 'axes_limits'
        varargin(2:end) = cellfun(@num2str,varargin(2:end),...
                                                    'UniformOutput',false);
        prompt = {'Enter x min:','Enter x max:','Enter y min:','Enter y max:'};
        name = 'Axes Limits'; [default_ans{1:4}] = deal(varargin{2:end});
        opts = struct('Resize','off','WindowStyle','modal');
        lims = inputdlg(prompt,name,1,default_ans,opts);

        lims = cellfun(@str2double,lims);
        varargout{3} = ~(isempty(lims) ||...
                         any(isnan(lims)) || any(isinf(lims)) ||...
                        (lims(1)>lims(2)) || (lims(3)>lims(4)));
        if varargout{3}
            [varargout{1:2}] = deal(lims(1:2)',lims(3:4)');
        end

    case 'calc_voi'
        varargout{1} = msgbox('Calculating VOI stats. Please wait...',...
                                                          'Processing','Modal');
        add_logo(varargout{1});

    case 'classification_load'
        f_list = dir(varargin{2}); f_list = {f_list.name};
        f_list(cellfun(@(x) isempty(strfind(x,'.mat')),f_list) ) = [];
        f_list(cellfun(@(x) strcmpi(x,'cine_viewer_options.mat'),f_list)) = [];
        f_list = cellfun(@(x) strrep(x,'.mat',''),f_list,'UniformOutput',false);
        [sel,ok] = listdlg('ListString',f_list,'SelectionMode','single');
        varargout{2} = ok && ~isempty(sel);
        if varargout{2}
            varargout{1} = f_list{sel};
        end

    case 'classification_name'
        str = inputdlg('Please enter the training data description',...
                       'Classification name?');
        varargout{2} = ~(isempty(str) || isempty(str{1}));
        if varargout{2}
            varargout{1} = str{1};
        end

    case 'contour_name'
        str = inputdlg('Please enter the name for the new ROIs',...
                       'Contour name?');
        varargout{2} = ~(isempty(str) || isempty(str{1}));
        if varargout{2}
            varargout{1} = str{1};
        end

    case 'copy_exam_rois'
        str = questdlg('Copy ROIs to this exam?','Copy ROIs','Yes',...
                       'No','Yes');
        varargout{1} = ~(strcmpi(str,'no') || isempty(str));

    case 'delete_roi_label'
        if ~iscell(varargin{2})
            varargin{2} = varargin(2);
        end
        switch length(varargin{2})
            case 1
                cName = varargin{2}{1};
            case 2
                cName = [varargin{2}{1} ' and ', varargin{2}{2}];
            otherwise
                cName = '';
                for i = 1:length(varargin{2})-1
                    cName = [cName varargin{2}{i} ', '];
                end
                cName = [cName 'and ' varargin{2}{end}];
        end
        str = questdlg({'Delete all data from ', [cName '?']},...
                       'Delete Contour', 'Yes', 'No', 'Yes');
        varargout{1} = ~(strcmpi(str,'no') || isempty(str));

    case 'export_maps'
        [varargout{1:2}] = listdlg('PromptString', 'Select maps to export',...
                                   'ListString',varargin{2});

    case 'export_map_names'
        m_name = inputdlg('Enter map names','Export maps',1);
        varargout{2} =  ~isempty(m_name);
        if varargout{2}
            varargout{1} = m_name{1};
        end

    case 'export_roi_list'
        [varargout{1:2}] = listdlg('PromptString', 'Select ROIs.',...
                                   'ListString', varargin{2},...
                                   'Name','ROI Export');

    case 'import_dicom'
        varargout{1} = uigetdir(varargin{2},...
                         'Select the folder containing all DICOM images.');
        varargout{2} = ~isnumeric( varargout{1} ) && isdir( varargout{1} );

    case 'map_type'
        valid_types = {'ADC','Frac. Aniso.','Min Eigen','Med Eigen','Max Eigen'};
        map_names = {'adc','fa','mineig','medeig','maxeig'};
        [slct,ok] = listdlg('ListString',valid_types,'SelectionMode','single');
        varargout{2} = ok;
        if varargout{2}
            varargout{1} = map_names{slct};
        end
    case 'multi_param_select'
        prompt = ['Select ' varargin{2} ' to use:'];
        name = [varargin{2} ' selection'];

        % Converts vals from row to column vector
        if ~(size(varargin{3},2)==1 && size(varargin{3},1)~=1)
            varargin{3} = varargin{3}';
        end
        varargin{3} = num2str(varargin{3});

        % Prompts user
        [selected,ok] = listdlg('PromptString',prompt,...
                                'SelectionMode','multiple',...
                                'ListString',varargin{3}, 'Name',name);
        varargout{2} = ok && ~isempty(selected) && length(selected) > 1;
        if varargout{2}
            varargout{1} = false(1,size(varargin{3},1));
            varargout{1}(selected) = true;
        end

    case 'new_guess'
        g = inputdlg(varargin{2},'New Guess',1,varargin(3));
        varargout{2} = ~isempty(g) && ~isnan(str2double(g));
        if varargout{2}
            varargout{1} = str2double(g);
        end

    case 'overwrite_rois'
        str = questdlg('Overwirte all ROIs?','Overwrite ROIs','Yes',...
                       'No','No');
        varargout{1} = ~(strcmpi(str,'no') || isempty(str));

    case 'overwrite_maps'
        str = questdlg('Overwrite old maps?','Overwrite?','Yes','No','Yes');
        varargout{1} = ~(strcmpi(str,'no') || isempty(str));

    case 'prepare_msg'
        varargout{1} = msgbox('Preparing QUATTRO exam','Preparing...',...
                                                                  'Modal');
        add_logo(varargout{1});

    case 'roi_label'
        str = inputdlg('Enter new contour label:', 'New Label',...
                       1, varargin(2));
        varargout{2} = ~(isempty(str) || isempty(str{1}));
        if varargout{2}
            varargout{1} = str{1};
        end

    case 'select_dicom_export'
        [varargout{1} ok] = listdlg('PromptString','Select image data',...
                                   'ListString',varargin{2});
        varargout{2} = ~(isempty(ok) || (ok==0) || isempty(varargout{1}));

    case 'select_slice'
        opts = struct('WindowStyle','Modal');
        val = inputdlg('Enter slice number',...
                                    'Slice',1,{'1'},opts);
        varargout{2} = ~isempty(val) && ~isnan(str2double(val{1}));
        if varargout{2}
            varargout{1} = str2double(val{1});
        end

    case 'summarize_data'
        list = {'Pixel Value' varargin{2}{:}};
        [selection ok] = listdlg('PromptString','Select data.',...
                                  'ListString',list,...
                                  'InitialValue',varargin{3});
        varargout{2} = ~(isempty(ok) || (ok==0) || isempty(selection));
        varargout{1} = list(selection);

    case 'trim_stats'
        opts = struct('WindowStyle','Modal');
        val = inputdlg('Trim what percentage of stats (e.g. 10)?',...
                       'Trim Stats', 1, {'10'},opts);
        varargout{2} = ~isempty(val) && ~isnan(str2double(val{1}));
        if varargout{2}
            varargout{1} = str2double(val{1});
            if varargout{1} > 100 || varargout < 0
                errordlg({'Invalid trim percentage.','Trim reset to 0%.'})
                varargout{1} = 0;
            end
        end

    case 'use_pinnacle_header'
        ok = questdlg({'Using the Pinnacle header factilitates ROI import.',...
                   'Would you like to locate the header for this ROI file?'},...
                   'Import header?','Yes','No','Yes');
        if strcmpi(ok,'yes')
            [fName fPath] = uigetfile({'*.header','Header file (*.header)'},...
                                           'Select header file .',...
                                           'MultiSelect','off');
            varargout{2} = ~isnumeric(fName) && ~isnumeric(fPath);
            if ~isempty(fName) && ~isnumeric(fName)
                varargout{1} = fullfile(fPath,fName);
            end
        else
            varargout{2} = false;
        end

    otherwise
end