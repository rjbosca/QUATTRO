function calcbniauc(obj)
%calcbniauc  Calculates the blood-normalized area under the curve
%
%   calcbniauc(OBJ) calculates the initial area under the curve (IAUC)
%   normalized to the IAUC of the vascular input function using the current data
%   stored in the dynamic (or sub-classed) object, OBJ. The computations will be
%   stored in the "results" property.
%
%   IAUC maps are computed if previous computations are not stored in the
%   "results" property. Otherwise, the previous results are used to avoid
%   additional computations.

    if obj.isReady.dynamic && obj.isReady.pk
        return
    end

    % Initialize common variables
    x = obj.xProc;
    y = obj.vifProc;

    % Calculate the time vector using the longest possible integration time
    % (this will save computing smaller/intermediate vectors)
    tNew  = (0:obj.tIntStep:max(obj.tIntegral))+obj.tIntStart;
    nTInt = arrayfun(@(x) numel(0:obj.tIntStep:x),obj.tIntegral);
    nInt  = numel(nTInt);

    % Before continuing, ensure that all of the IAUC results are present in the
    % "results" property. Otherwise, compute those now since they will be needed
    % for the blood-normalized computation
    if any( ~isfield(obj.results,obj.iaucParams) )
        obj.calciauc;
    end

    % Intialize the results cell. Using a cell saves on the need for contiguous
    % memory addresses when performing the integration
    val = cellfun(@(x) obj.results.(x).value,obj.iaucParams,...
                                                         'UniformOutput',false);

    % Perform the integration(s) by looping through each voxel (and integration
    % time if more than one)
    for intIdx = 1:nInt
        yData       = interp1(x,y,tNew(1:nTInt(intIdx)));
        val{intIdx} = val{intIdx}/trapz(tNew(1:nTInt(intIdx)),yData);
    end %integration

    % Update the results
    cellfun(@(x,y) obj.addresults(x,y),obj.bniaucParams,val);

end %pk.calcbniauc