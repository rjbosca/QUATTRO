classdef t1relaxometry < modelbase


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = t1relaxometry

            % Initialize the parameter units that are common to all T1
            % relaxometry sub-classes
            obj.paramUnits(1).S0 = '';
            obj.paramUnits(1).T1 = 'milliseconds';
            obj.paramUnits(1).R1 = '1/seconds';

            % Initialize the parameter bounds that are common to all T1
            % relaxometry sub-classes
            obj.paramBounds(1).S0 = [0    inf];
            obj.paramBounds(1).T1 = [0    20000];
            obj.paramBounds(1).R1 = [0.05 inf];

            % Initialize the parameter guesses that are common to all T1
            % relaxometry sub-classes. The "paramGuessCache" property is called
            % instead of the dependent "paramGuess" property becuase validation
            % does not need to be performed here...
            obj.userParamGuessCache = struct('S0',1000,...
                                             'T1',1000,...units: ms
                                             'R1',1);    %units: 1/s

        end %t1relaxometry.t1relaxometry

    end

end %t1relaxometry