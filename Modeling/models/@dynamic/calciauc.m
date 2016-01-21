function calciauc(obj)
%calciauc  Calculates the initial area under the curve
%
%   calciauc(OBJ) calculates the initial area under the curve (IAUC) using the
%   current data stored in the dynamic (or sub-classed) object, OBJ. The
%   computations are stored in the "results" property.
%
%   When performing map computations, the IAUC is masked by the property
%   "mapSubset". The IAUC is calculated only for those voxels at which that
%   property is TRUE.

    if ~obj.isReady.dynamic
        return
    end

    % Initialize common variables
    x = obj.xProc;
    y = obj.yProc;

    % Calculate the time vector using the longest possible integration
    % time (this will save computing smaller/intermediate vectors)
    tNew  = (0:obj.tIntStep:max(obj.tIntegral))+obj.tIntStart;
    nTInt = arrayfun(@(x) numel(0:obj.tIntStep:x),obj.tIntegral);
    nInt  = numel(nTInt);

    % Grab the mask for map computations
    mask = true;
    m    = [1 1];
    if (numel(y)~=length(y))
        mask = obj.mapSubset;
        m    = size(mask);
        if (prod(m)~=numel(y)/size(y,1))
            error(['qt_models:' mfilename ':incommensurateMask'],...
                   'The mapSubset size is incommensurate with y.');
        end
    end

    % Intialize the results cell. Using a cell saves on the need for
    % contiguous memory addresses when performing the integration
    [val{1:numel(obj.iaucParams)}] = deal( nan(m) );

    % Perform the integration(s) by looping through each voxel (and
    % integration time if more than one).
    for voxIdx = 1:prod(m)
        if mask(voxIdx)

            for intIdx = 1:nInt
                yData               = interp1(x,squeeze(y(:,voxIdx)),...
                                                         tNew(1:nTInt(intIdx)));
                val{intIdx}(voxIdx) = trapz(tNew(1:nTInt(intIdx)),yData);
            end %integration

        end
    end %voxel

    % Update the results
    cellfun(@(x,y) obj.addresults(x,y),obj.iaucParams,val);

end %dynamic.calciauc