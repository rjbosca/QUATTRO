function update_menu_exam_type(hMenu)
%update_menu_exam_type  Updates the QUATTRO "Exam Type" menu
%
%   update_menu_exam_type(H) initializes the menu specified by the handle H with
%   sub-menus containing selections for differnt exam types

    % Remove any children of the "Exam Type" menu
    if strcmpi( get(hMenu,'Tag'), 'menu_exam_type' )
        delete( get(hMenu,'Children') )
    end

    % Create menus from all of the different acquisition classes and associated
    % models
    menuInfo = qt_models.model_info;
    sMenus   = fieldnames(menuInfo)';
    for fld = sMenus

        % Check to see if the model type menu has been created
        modelTypeTag  = menuInfo.(fld{1}).ModelInfo.ContainingPackage;
        modelTypeName = menuInfo.(fld{1}).ModelInfo.Name;
        hModel        = findobj(hMenu,'Tag',['menu_' modelTypeTag]);
        if isempty(hModel)
            hModel = uimenu('Parent',hMenu,...
                            'Label',modelTypeName,...
                            'Tag',['menu_' modelTypeTag]);
        end

        % Model type sub-menu construction
        h = uimenu('Parent',hModel,...
                   'Callback',@change_exam_type_Callback,...
                   'Label',menuInfo.(fld{1}).Name,...
                   'Tag',['menu_' menuInfo.(fld{1}).ContainingPackage]);
        addlistener(h,'Checked','PostSet',@exam_type_PostSet);

    end

    % Always place the "Other" menu option at the bottom
    hOther = findobj(hMenu,'Tag','menu_other');
    hKids  = get(hMenu,'Children');
    hKids  = hKids(hKids~=hOther);
    set(hMenu,'Children',[hOther;hKids]);

    % Set the "Generic" menu to checked
    set(findobj(hMenu,'Tag','menu_generic'),'Checked','on');

end %update_menu_exam_type


function change_exam_type_Callback(hObj,~)

    % Grab the figure handle, exam type sub-menus, and qt_exam object
    hFig = guifigure(hObj);
    obj  = getappdata(hFig,'qtExamObject');

    % Determine if any change has actually occured. Changing the exam type can
    % be computationally intensive....
    if strcmpi( get(hObj,'Checked'), 'on' )
        return
    end

    % Note that the menu property "Checked" will be updated in the listener of
    % the QT_EXAM property "type"

    % Set the new exam type
    obj.type = strrep( get(hObj,'Tag'), 'menu_', '' );

    %FIXME: although the QT_EXAM object is updated following the change in the
    %property "type", the image should always be updated here as well to ensure
    %that any changes to the image stack are displayed appropriately

end %change_exam_type_Callback

function exam_type_PostSet(src,eventdata)

    % This post-set listener will also get called when the 'Checked' property is
    % set to 'off'. No changes need to occur in that case
    %FIXME: this used to say "strcmpi(eventdata.NewValue,'off')". Starting with
    %MATLAB 8.5.0, "NewValue" is no longer a property of the event data.
    if strcmpi(eventdata.AffectedObject.Checked,'off')
        return
    end

    % Grab the "Exam Type" menu from the model's grandparent and find all menus
    % that have the "Checked" property set to 'on'
    hMenu  = get( get(eventdata.AffectedObject.Parent,'Parent'), 'Parent' );
    hCheck = findobj(hMenu,src.Name,'on');

    % Remove the current handle from the list and set all other menus "Checked"
    % property to 'off'
    hCheck = hCheck( hCheck~=double(eventdata.AffectedObject) );
    if ~isempty(hCheck)
        set(hCheck,'Checked','off');
    end

end %exam_type_PostSet