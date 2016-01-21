classdef modelevents < handle

    events

        % Checks for computation readiness
        %
        %   "checkCalcReady" should be notified during property set methods or
        %   post-set events to ensure that the "isReady" property is updated
        %   appropriately following changes to the sub-class property values.
        %   Listeners should be added in the class constructor of the qt_models
        %   sub-class.
        checkCalcReady

        % Updates object with new modeling results
        %
        %   "newResults" should be notified following any changes to the
        %   "results" property. This is set apart as an event, as opposed to a
        %   post-set event for the "results" property, to minimize the number of
        %   calls.
        newResults

        % Creates or updates model visualizations
        %
        %   "showModel" should be notified following any changes to the model
        %   fit or model data when visualizations are supported. This event
        %   should be attached duruing calls to each modeling sub-class
        %   constructor for those classes that add information to the any
        %   visualization. This event was intended to be fired after
        %   "newResults"
        showModel

        % Update the model properties
        %
        %   "updateModel" should be notified during property set methods or
        %   post-set events for those model properties that affect the fitting
        %   or display of the fitted results
        updateModel

    end

    methods

        function obj = modelevents
        end %modelevents.modelevents

    end

end %modelevents