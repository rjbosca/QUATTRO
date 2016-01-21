function update(obj)
%update  Updates the modeling objects current state
%
%   update(OBJ) updates the modeling object, OBJ, to ensure that any dependent
%   properties (including those that implicitly dependent) represent the current
%   state of the object's properties

    % Always calculate the starting guess first. As of 11/6/2015, there is a
    % sequence dependent computation within the variable TI modeling class that
    % requires the "paramGuessCache" property to be populated before computing
    % "yProc"
    obj.paramGuess;

end %modelbase.update