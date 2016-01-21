function modelbase_dataMode_postset(obj,~,eventdata)
%modelbase_dataMode_postset  Post-set event for MODELBASE "dataMode" property
%
%   modelbase_dataMode_postset(OBJ,SRC,EVENTDATA)

    % Using the modeling object (i.e., "AffectedObject"), update some of the GUI
    % properties if the "Current Pixel" mode has been enabled
    if strcmpi(eventdata.AffectedObject.dataMode,'pixel') &&...
                                        ~isempty(obj.hFig) && ishandle(obj.hFig)
        hCur = findall(obj.hFig,'Tag','uitoggletool_data_cursor');
        if strcmpi( get(hCur,'State'), 'off' )
            set(hCur,'State','on'); %initialize the state, which fires
                                    %the "state" PostSet event
        end
    end

    % Notify the "newModelData" event to ensure that the model is updated
    % appropriately
    dMode = eventdata.AffectedObject.dataMode;
    dMode = strrep( strrep(dMode,'project','roi'), 'label', 'roi' );
    notify(obj,'newModelData',newModelData_eventdata(dMode,'manual'));

end %qt_exam.modelbase_dataMode_postset