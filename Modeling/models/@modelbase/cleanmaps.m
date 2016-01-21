function [yc,r2] = cleanmaps(obj,varargin)
%cleanmaps  Uses spatial data to recover bad fits
%
%   cleanmaps(OBJ) attempts to recover bad fits within a collection of parameter
%   maps stored in the results structure of the modeling object OBJ (i.e. the
%   maps were already computed).
%
%   cleanmaps(OBJ,Y,YC) attempts to recover bad fits within the maps specified
%   by the ND array YC using the data in Y and the goodness-of-fit criteria
%   stored in the last index of YC.
%
%   cleanmaps(...,'WaitBar',HWAIT) performs the operations described previously,
%   using the waitbar handle, HWAIT, to graphically notify the user of the
%   operation.

    % Parse the inputs and define the waitbar flag
    [r2,hWait,y,yc] = parse_inputs(obj,varargin{:});
    isWait       = ~isempty(hWait);

    % Update the waitbar
    if isWait && ishandle(hWait)
        waitbar(0,hWait,'0% Complete');
        waitDlg = strrep(get(hWait,'Name'),'Calculating','Cleaning');
        set(hWait,'Name',waitDlg);
    end

    % Initialize the workspace
    f         = obj.fitFcn;
    m         = size(yc);     %size of map data
    w         = floor(log2(max(m)));
    mW        = m(3)+w;
    r2Thresh  = obj.fitThresh;
    validErrs = {'MATLAB:eig:matrixWithNaNInf',...
                              'optimlib:snls:UsrObjUndefAtX0'};

    % Prepare a "filled" version of the maps that allows the edges to be reached
    % by the following 'for' loops
    filledYc = fill_mat(yc,w);
    filledR2 = fill_mat(r2,w);

    % Loop through each voxel
    for xIdx = m(3)+w:-1:w+1
        for yIdx = m(2)+w:-1:w+1

            % Only consider bad fits (i.e., those with R^2 less than the
            % specified threshold)
            if (r2(yIdx-w,xIdx-w)>r2Thresh)
                continue
            end

            % Grab the R^2 values from the filled array. Test to ensure that all
            % R^2 values in the specified neighborhood are greater than the
            % voxel to be re-fitted - otherwise, what's the point...
            r2Vals = filledR2(yIdx-w:yIdx+w,xIdx-w:xIdx+w);
            if all(r2Vals<=filledR2(yIdx,xIdx))
                continue
            end
            mapVals = filledYc(:,yIdx-w:yIdx+w,xIdx-w:xIdx+w);

            % Removes bad fits and NaN values
            mapVals( repmat(r2Vals,[1 1 m(1)]) < r2Thresh) = [];
            mapVals                  = reshape(mapVals,[],m(1));
            nanInd                   = repmat(any(isnan(mapVals),2),[1 m(1)]);
            mapVals(nanInd)          = [];
            mapVals                  = reshape(mapVals,[],m(1));
            if isempty(mapVals)
                continue
            end

            % Initial guess and y data
            init = median(mapVals,1);
            if ~any(init)
                continue
            end
            ydata = double( squeeze(y(:,yIdx-w,xIdx-w)) );

            % Fit/store data
            try
                [x0,~,r] = f(init,ydata);
            catch ME
                if any( strcmpi(ME.identifier,validErrs) )
                    continue
                else
                    rethrow(ME);
                end
            end

            r2Test = modelmetrics.calcrsquared(ydata,r);
            if (r2Test>r2(yIdx-w,xIdx-w))
                filledYc(:,yIdx,xIdx) = x0;
                filledR2(yIdx,xIdx)   = r2Test;
            end

        end

        % Update waitbar...
        if isWait
            if ishandle(hWait)
                waitbar((mW-xIdx+w+1)/mW,hWait,...
                                  [num2str((mW-xIdx+w+1)/mW*100) '% Complete']);
            else
                return %user cancelled
            end
        end

    end

    % Get the new maps from the filled maps
    yc = filledYc(:,w+1:m(2)+w,w+1:m(3)+w);
    r2 = filledR2(w+1:m(2)+w,w+1:m(3)+w);

    % Prepare a "filled" version of the maps that allows the edges to be reached
    % by the following 'for' loops
    filledYc = fill_mat(yc,w);
    filledR2 = fill_mat(r2,w);

    % Reset waitbar and perform computations running in the vertical direction
    if isWait
        waitbar(1,hWait,'100% Remaining');
    end
    mW = m(2)+w;
    for yIdx = w+1:m(2)+w
        for xIdx = w+1:m(3)+w

            % Only consider bad fits (i.e., those with R^2 less than the
            % specified threshold)
            if (r2(yIdx-w,xIdx-w)>r2Thresh)
                continue
            end

            % Grab the R^2 values from the filled array. Test to ensure that all
            % R^2 values in the specified neighborhood are greater than the
            % voxel to be re-fitted - otherwise, what's the point...
            r2Vals = filledR2(yIdx-w:yIdx+w,xIdx-w:xIdx+w);
            if all(r2Vals<=filledR2(yIdx,xIdx))
                continue
            end
            mapVals = filledYc(:,yIdx-w:yIdx+w,xIdx-w:xIdx+w);

            % Removes bad fits and NaN values
            mapVals( repmat(r2Vals,[1 1 m(1)]) < r2Thresh) = [];
            mapVals                  = reshape(mapVals,[],m(1));
            nanInd                   = repmat(any(isnan(mapVals),2),[1 m(1)]);
            mapVals(nanInd)          = [];
            mapVals                  = reshape(mapVals,[],m(1));
            if isempty(mapVals)
                continue
            end

            % Initial guess and y data
            init = median(mapVals,1);
            if ~any(init)
                continue
            end
            ydata = double( squeeze(y(:,yIdx-w,xIdx-w)) );

            % Fit/store data
            try
                [x0,~,r] = f(init,ydata);
            catch ME
                if any( strcmpi(ME.identifier,validErrs) )
                    continue
                else
                    rethrow(ME);
                end
            end

            r2Test = modelmetrics.calcrsquared(ydata,r);
            if (r2Test>r2(yIdx-w,xIdx-w))
                filledYc(:,yIdx,xIdx) = x0;
                filledR2(yIdx,xIdx)   = r2Test;
            end

        end

        % Update waitbar...
        if isWait
            if ishandle(hWait)
                waitbar((mW-yIdx+w+1)/mW,hWait,...
                                  [num2str((mW-yIdx+w+1)/mW*100) '% Remaining']);
            else
                return %user cancelled
            end
        end

    end

    % Get the new maps from the filled maps
    yc = filledYc(:,w+1:m(2)+w,w+1:m(3)+w);
    r2 = filledR2(w+1:m(2)+w,w+1:m(3)+w);

end %qt_models.cleanmaps


%-------------------------
function B = fill_mat(A,w)

    % Determine the size of the input array
    m = size(A);
    if numel(m)==2
        m = [1 m];
    end

    % Create an array such that the input array will sit in the middle and a
    % band of extra values of width "w" will be added to all four sides
    B                        = zeros([m(1) m(2:end)+2*w]);
    B(:,1:m(2),1:m(3))       = A; %fill upper left corner
    B(:,2*w+1:end,1:m(3))    = A; %fill lower left corner
    B(:,2*w+1:end,2*w+1:end) = A; %fill lower right corner
    B(:,1:m(2),2*w+1:end)    = A; %fill lower right corner
    B(:,w+1:end-w,w+1:end-w) = A;

    % Squeeze out singleton dimensions (this is needed for the R^2 array)
    B = squeeze(B);

end %fill_mat

%----------------------------------------------
function varargout = parse_inputs(obj,varargin)

    % When the user calls this method with only the the qt_models sub-class,
    % "obj", these inputs must be parsed manually
    if (nargin<2)
        varargin = [obj.yProc obj.results2array varargin];
    end

    % Create the input parser
    parser = inputParser;
    parser.addRequired('y')
    parser.addRequired('yc');
    parser.addRequired('r2');
    parser.addParamValue('WaitBar',[]);

    % Parse the inputs
    parser.parse(varargin{:});
    results = parser.Results;

    % Get or create the waitbar handle
    if obj.guiDialogs && isempty(results.WaitBar)
        results.WaitBar =...
                  waitbar(0,'0% Complete','Name','Cleaning parametric maps...');
    end

    % Deal the outputs
    varargout = struct2cell(results);

end %parse_inputs