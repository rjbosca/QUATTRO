classdef newModelData_eventdata < event.EventData

    properties

        % Data mode type
        %
        %   "dataMode" is a string specifying the required mode of the modeling
        %   object(s) that must be updated during the "newModelData" event
        dataMode = 'manual';

        % Event mode type
        %
        %   "eventMode" is a string specifying the "newModelData" mode and is
        %   one of 'otf' or 'manual'. When on-the-fly (i.e. 'otf') is specified,
        %   data locations are expected to align between the QT_EXAM object and
        %   modeling object
        eventMode = 'manual';

    end

    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = newModelData_eventdata(dMode,eMode)

            % Validate the "dataMode" input and store
            validatestring(dMode,{'manual','pixel','roi','project','label'});
            obj.dataMode = strrep(strrep(dMode,'project','roi'),'label','roi');

            % Validate the "eventMode" input and store
            validatestring(eMode,{'manual','otf'});
            obj.eventMode = eMode;

        end %newModelData_eventdata.newModelData_eventdata

    end

end %newModelData_eventdata