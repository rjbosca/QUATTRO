classdef modelmetrics < handle


    %------------------------------- Properties --------------------------------
    properties (Dependent)

        % Classical R-squared
        %
        %   "RSq" is the standard coefficient of determination
        RSq

        % Mean squared-error
        %
        %   "MSE" is the mean squared error
        MSE

    end

    properties (Abstract)

        % Model fitting results
        %
        %   "results" is a structure containing field names corresponding to
        %   fitted model parameter in addition to fitting criteria. When
        %   computing parameter maps, each field will contain a QT_IMAGE object
        %   encapsulating the results. Otherwise the data will be stored in a
        %   UNIT object
        results

    end

    properties (Hidden,Access='protected',Transient)

        % R-squared computational cache
        %
        %   "RSqCache" is a 
        RSqCache

        % MSE computational cache
        %
        %   "MSECache" is a 
        MSECache

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = modelmetrics
        end %modelmetrics.modelmetrics

    end


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.RSq(obj)
            val = []; %initialize
            if ~isempty(obj.RSqCache)
                val          = obj.RSqCache;
            elseif obj.isFitted
                val          = modelmetrics.calcrsquared(obj);
                obj.RSqCache = val;
            end
        end %modelmetrics.get.RSq

        function val = get.MSE(obj)
            val = []; %initialize
            if ~isempty(obj.MSECache)
                val          = obj.MSECache;
            elseif obj.isFitted
                val          = modelmetrics.calcmse(obj);
                obj.MSECache = val;
            end
        end %modelmetrics.get.MSE

    end


    %--------------------------- Metric Computations ---------------------------
    methods (Static)

        val = calcrsquared(varargin)

        val = calcmse(varargin)

    end

end %modelmetrics