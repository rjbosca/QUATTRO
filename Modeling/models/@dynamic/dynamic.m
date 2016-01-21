classdef dynamic < dynamicopts & modelbase

    properties (SetAccess='protected',SetObservable)

        % Initial area under the curve parameter names
        %
        %   "iaucParams" is a cell array containing the names of all intial area
        %   under the curve (IAUC) parameters estimated by this modeling object
        iaucParams = {'IAUC60','IAUC120','IAUC180'};

    end

    properties (Constant)

        % Class definition independent variable units
        %
        %   "xUnits" is a string specifying the units of the indpendent variable
        %   property "x"
        xUnits = 'seconds';

    end

    properties (Hidden,Dependent)

        % Pre-contrast time vector indices
        %
        %   "preInds" is a bitmask the same size as "xProc" that defines the
        %   pre-contrast measurements locations in "x" and "y"
        preInds

        % First pass time vector indices
        %
        %   "firstPassInds" is a bitmask the same size as "xProc" that defines
        %   the temporal window between the "injectionTime" and the "recircTime"
        firstPassInds

    end

    properties (Hidden,SetAccess='protected')

        % Pre-contrast time vector indices
        %
        %   "preIndsCache" is a bitmask the same size as "xProc" that defines
        %   the pre-contrast measurements and is used to store the processed
        %   index to save computation time. This vector is set by the "preInds"
        %   property "get" method
        preIndsCache

        % First pass time vector indices
        %
        %   "firstPassIndsCache" is a bitmask the same size as "xProc" that
        %   defines the temporal window between the "injectionTime" and the
        %   "recircTime" and is used to store the processed index to save
        %   computation time. This vector is set by the "preInds" property "get"
        %   method
        firstPassIndsCache
        
    end

    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = dynamic

            % Add PostSet listeners to update the display/fitting routines when
            % changes to dce specific properties occur
            addlistener(obj,'injectionTime','PostSet',@obj.injectionTime_postset);
            addlistener(obj,'recircTime',   'PostSet',@obj.recircTime_postset);
            addlistener(obj,'tIntegral',    'PostSet',@obj.tIntegral_postset);
            addlistener(obj,'x',            'PostSet',@obj.x_postset);

            % Add the event listeners
            addlistener(obj,'checkCalcReady',@obj.checkCalcReady_event);
            addlistener(obj,'showModel',     @obj.showModel_event);

            % Since this a top level DCE class, initialize the parameter units
            % structure. The units IAUC will be updated by tIntegral_postset if
            % changes are made to the "tIntegral" property, but these updates
            % will not occur when using the default values; define those units
            % here
            obj.paramUnits = struct('IAUC60','',...
                                    'IAUC120','',...
                                    'IAUC180','');

            % Initialize the "isReady" field
            obj.isReady.(mfilename) = false;

        end %dynamic.dynamic

    end %class constructor


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.preInds(obj)

            val = obj.preIndsCache; %get the cache

            % Compute the actual values if the cache is invalid
            if ~isempty(val) && ~any(val) && ~isempty(obj.injectionTime)

                %FIXME: the "subset" property is not included in this
                %computation...

                %TODO: this does not account for degenerate measurements at the
                %same time
                delT      = abs(obj.xProc-obj.injectionTime);
                [~,tLast] = min(delT);

                % Only consider frames pre-contrast if those frames occur before
                % the "injectionTime". This means that if the user sets that
                % value to be on a frame, that frame should be ignored with
                % regard to the pre-contrast data
                if obj.x(tLast)==obj.injectionTime
                    tLast = tLast-1;
                end

                % Notify the user that an error occured
                if (tLast<1)
                    obj.injectionTime = obj.x(2);
                    error([mfilename ':injectionTime:invalidTime'],...
                          ['An injection time of %.1fs results in 0 ',...
                           'pre-contrast frames. "injectionTime" has been ',...
                           'reset to %.1fs.'],obj.injectionTime,obj.x(2));
                end
                val(1:tLast) = true;

            end

        end %dynamic.get.preInds

        function val = get.firstPassInds(obj)

            val = obj.firstPassIndsCache; % get the cache

            % Compute the actual values if the cache is invalid
            if ~isempty(val) && ~any(val) && ~isempty(obj.firstPassIndsCache)

                %TODO: this does not account for degenerate measurements at the
                %same time
                delT      = abs(obj.xProc-obj.recircTime);
                [~,tLast] = min(delT);

                % Only consider frames occuring at times less than or equal to
                % the "recircTime"
                if (obj.x(tLast)>obj.recircTime)
                    tLast = tLast-1;
                end
                val(1:tLast) = true;

            end

        end %dynamic.get.firstPassIndsCache

    end


    %--------------------------- Processing Methods ----------------------------
    methods (Hidden)

        function val = processMapSubset(obj)
        %processMapSubset  Creates a mask of enhancing voxels
        %
        %   MASK = processMapSubset(OBJ) creates a mask of voxels that enhance
        %   at least as much as the threshold defined by the "enhanceThresh"
        %   property of the dce object OBJ. These computations are only used
        %   when working with maps.

            % Define the pre-contrast and contrast recirculation window masks
            tPost = obj.subset & obj.firstPassInds & ~obj.preInds;

            % Calculate the pre-contrast signal intensity. Always average along
            % the temporal dimension (DIM 1) to ensure that single data are not
            % averaged along the series
            preSi = mean(obj.y(obj.subset & obj.preInds,:),1);

            % Determine the maximum signal intensity in the first-pass window
            maxSi = double( max(obj.y(tPost,:),[],1) );

            % Define and reshape the mask: (SImax-SIpre)/SIpre>50%
            val = (maxSi./preSi>=1+obj.enhanceThresh);

            % For a given voxel location, assume that if the voxel achieves a
            % value of zero anywhere in the series that those data can safely be
            % ignored
            val = val & all( obj.y(:,:)>0 );

            % Also, assume that for a given voxel, the maximum post-contrast
            % slope must be greater than zero
            val = val & ( max(diff(obj.y(tPost,:))./...
                                      repmat(diff(obj.x(tPost)),size(val)))>0 );
            
        end %dce.processMapSubset

    end

end %dynamic