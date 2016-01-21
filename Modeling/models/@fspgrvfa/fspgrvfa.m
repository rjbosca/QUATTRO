classdef fspgrvfa < t1relaxometry

    properties (Dependent)

        % Function used for plotting the model
        %
        %   "plotFcn" same as "modelFcn" for the FSPGRVFA class
        plotFcn

        % Processed y values
        %
        %   "yProc" is a dependent property that performs any pre-processing and
        %   applies the property "subset"
        yProc

    end

    properties (Constant)

        % Class definition independent variable units
        %
        %   "xUnits" is a string specifying the units of the indpendent variable
        %   property "x"
        xUnits = 'degrees';

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = fspgrvfa

            % Initialize the "isReady" field
            obj.isReady.(mfilename) = false;

            % Create listeners before modifying the object's properties
            addlistener(obj,'checkCalcReady',@obj.checkCalcReady_event);

        end %fspgrvfa.fspgrvfa

    end


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.plotFcn(obj)

            % Determine if all necessary parameters exist, creating the plotting
            % function using the estimated model parameters
            val = [];
            if all( isfield(obj.results,obj.nlinParams) )
                tr  = obj.tr;
                x0  = [obj.results.S0.value,...
                       obj.results.T1.convert('milliseconds').value];
                val = @(xData) fspgr_vfa(x0,xData,tr);
            end
            
        end %fspgrvfa.get.plotFcn

        function val = get.yProc(obj)
            val = obj.y;
            if ~isempty(val)
                val = val(obj.subset,:);
            end
        end %fspgrvfa.get.yProc

    end


    %------------------------------ Other Methods ------------------------------
    methods (Hidden)

        function val = processMapSubset(obj)
        %processMapSubset  Creates a mask of voxels to be processed
        %
        %   MASK = processMapSubset(OBJ) creates a logical array, MASK, of
        %   voxels to be processed. These computations are only used when
        %   working with maps.

            % For a given voxel location, assume that if the voxel achieves a
            % value of zero anywhere in the series that those data can safely be
            % ignored
            val = all( obj.y(obj.subset,:)>0 );
            
        end %fspgrvfa.processMapSubset

    end %methods (Hidden)


end %fspgrvfa