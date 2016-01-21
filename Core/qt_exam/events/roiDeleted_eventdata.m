classdef roiDeleted_eventdata < event.EventData

    properties

        % ROI objects to be deleted
        %
        %   "roiObjs" is an array of QT_ROI objects to be deleted from the stack
        %   of ROIs stored in a QT_EXAM object.
        roiObjs = qt_roi.empty(1,0);

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = roiDeleted_eventdata(rObj)

            % Validate the inputs and store in "roiObjs"
            validateattributes(rObj,{'qt_roi'},{'nonempty'});
            obj.roiObjs = rObj(:)'; %always store a row vector

        end %roiDeleted_eventdata.roiDeleted_eventdata

    end

end %roiDeleted_eventdata