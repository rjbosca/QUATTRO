classdef generalopts < handle
%general class option definitions
%
%   generalopts defines the user adjustable options that are common to a number
%   of QUATTRO classes

    properties (AbortSet,SetObservable)

        % Flag controlling the use of graphical notifications
        %
        %   "guiDialogs" is a logical flag that, when TRUE, enables or disables
        %   (FALSE - default) the use of graphical error, warning, and other
        %   notification messages when working with the sub-classed QUATTRO
        %   object. Command prompt messages are still issued
        guiDialogs = false;

    end

    properties (AbortSet,SetObservable,Hidden)

        % Event listeners
        %
        %   "eventListeners" stores an array of event listeners that is deleted
        %   during object destruction. The deletion ensures that additional
        %   error checking and/or numerous out-dated calls to the listeners are
        %   prevented.
        %
        %   This property acts as a stack, appending each new event to the array
        %   of event.proplisteners and returning only valid property listeners
        eventListeners = event.listener.empty(1,0);

        % Property set/get event listeners
        %
        %   "propListeners" stores an array of property set/get event listeners
        %   that is deleted during object destruction. The deletion ensures that
        %   additional error checking and/or numerous out-dated calls to the
        %   listeners are prevented.
        %
        %   This property acts as a stack, appending each new event to the array
        %   of event.proplisteners and returning only valid property listeners
        propListeners = event.proplistener.empty(1,0);

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = generalopts
        end %generalopts.generalopts

    end


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.eventListeners(obj)
            val = obj.eventListeners;
            if ~isempty(val)
                val = val( val.isvalid );
            end
        end %generalopts.get.eventListeners

        function val = get.propListeners(obj)
            val = obj.propListeners;
            if ~isempty(val)
                val = val( val.isvalid );
            end
        end %generalopts.get.propListeners

    end


    %------------------------------- Set Methods -------------------------------
    methods

        function set.eventListeners(obj,val)
            validateattributes(val,{'event.listener'},{'nonempty'});
            obj.eventListeners(end+1) = val;
        end %generalopts.set.eventListeners

        function set.guiDialogs(obj,val)
            validateattributes(val,{'logical'},{'scalar','nonempty'});
            obj.guiDialogs = val;
        end %generalopts.set.guiDialogs

        function set.propListeners(obj,val)
            validateattributes(val,{'event.proplistener'},{'nonempty'});
            obj.propListeners(end+1) = val;
        end %generalopts.set.propListeners

    end


    %---------------------------- Overloaded Methods ---------------------------
    methods

        function delete(obj)

            % Delete the listeners
            delete(obj.propListeners);
            delete(obj.eventListeners);

        end %generalopts.delete

    end

end %generalopts