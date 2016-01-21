classdef examevents < handle

    events

        % Notification of image deletion
        %
        %   "imgDeleted" should be notified any time an image (one or more) is
        %   deleted by calling the "delete" method of the QT_IMAGE object. This
        %   does not apply to removing the image from the "imgs" property
        imgDeleted

        % Notification of changes to exam data/type
        %
        %   "initializeExam" should be notified any time new images/ROIs are
        %   stored or the exam type is changed. This event is notified during
        %   the PostSet events of the QT_EXAM properties "imgs', "rois", and
        %   "type", and is designed to be an interface for external applications
        %   that must perform some operations after all of these properties have
        %   been populated
        initializeExam

        % Notification of changes to the current model
        %
        %   "newModel" should be notified when the QT_EXAM object's property
        %   "mapModel" requires updating, usual resulting from changes to the
        %   exam type or user-selected model
        newModel

        % Notification of changes to model data
        %
        %   "newModelData" should be notified when data properties (such as ROIs
        %   or the current exam position) are modified to ensure that modeling
        %   objects stored in the "models" property are updated
        newModelData

        % Notification of ROI changes
        %
        %   "roiChanged" should be notified when ROIs are created, modified, or
        %   deleted to ensure that the object updates all associated properties
        roiChanged

    end

    events (Hidden,ListenAccess='protected',NotifyAccess='protected')
        

        % Notification of ROI addition
        %
        %   "roiAdded" should be notified any time an ROI (one or more) is added
        %   to the QT_EXAM object using the "addroi" method.
        roiAdded

        % Notification of ROI deletion
        %
        %   "roiDeleted" should be notified any time an ROI (one or more) is
        %   deleted by calling the "delete" method of the qt_roi object. This
        %   does not apply to removing the ROI from the "rois" property
        roiDeleted

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = examevents
        end %examevents.examevents

    end

end %examevents