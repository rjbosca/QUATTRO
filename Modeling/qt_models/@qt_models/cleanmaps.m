function yc = cleanmaps(obj,varargin)
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
    [hWait,y,yc] = parse_inputs(obj,varargin{:});
    isWait       = ~isempty(hWait);

    % Update the waitbar
    if isWait && ishandle(hWait)
        waitbar(0,hWait,'0% Complete');
        waitDlg = strrep(get(hWait,'Name'),'Calculating','Cleaning');
        set(hWait,'Name',waitDlg);
    end

    % Initialize map info
    f         = obj.fitFcn;
    m         = size(yc);     %size of map data
    n         = size(yc,1)-1; %number of maps
    w         = floor(log2(max(m)));
    mW        = m(2)+w;
    r2Thresh  = obj.fitThresh;
    validErrs = {'MATLAB:eig:matrixWithNaNInf',...
                              'optimlib:snls:UsrObjUndefAtX0'};

    % Prepare a "filled" version of the maps that allows the edges to be reached
    % by the following 'for' loops
    filledYc                        = zeros([m(1) m(2:end)+2*w]);
    filledYc(:,1:m(2),1:m(3))       = yc; %fill upper left corner
    filledYc(:,2*w+1:end,1:m(3))    = yc; %fill lower left corner
    filledYc(:,2*w+1:end,2*w+1:end) = yc; %fill lower right corner
    filledYc(:,1:m(2),2*w+1:end)    = yc; %fill lower right corner
    filledYc(:,w+1:end-w,w+1:end-w) = yc;


    for xIdx = m(3)+w:-1:w+1
        for yIdx = m(2)+w:-1:w+1

            % Only consider bad fits
            if yc(end,yIdx-w,xIdx-w)>r2Thresh
                continue
            end

            r2Vals = repmat(filledYc(end,yIdx-w:yIdx+w,xIdx-w:xIdx+w),[1 1 n]);
            if all(r2Vals <= filledYc(end,yIdx,xIdx))
                continue
            end
            mapVals = filledYc(1:end-1,yIdx-w:yIdx+w,xIdx-w:xIdx+w);

            % Removes bad fits and NaN values
            mapVals(r2Vals<r2Thresh) = [];
            mapVals                  = reshape(mapVals,[],n);
            nanInd                   = repmat(any(isnan(mapVals),2),[1 n]);
            mapVals(nanInd)          = [];
            mapVals                  = reshape(mapVals,[],n);
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

            r2Test = 1-(r'*r)./sum((ydata-mean(ydata)).^2);
            if r2Test > yc(end,yIdx-w,xIdx-w)
                filledYc(1:end-1,yIdx,xIdx)  = x0;
                filledYc(end,yIdx,xIdx) = r2Test;
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

    % Prepare a "filled" version of the maps that allows the edges to be reached
    % by the following 'for' loops
    filledYc                        = zeros([m(1) m(2:end)+2*w]);
    filledYc(:,1:m(2),1:m(3))       = yc; %fill upper left corner
    filledYc(:,2*w+1:end,1:m(3))    = yc; %fill lower left corner
    filledYc(:,2*w+1:end,2*w+1:end) = yc; %fill lower right corner
    filledYc(:,1:m(2),2*w+1:end)    = yc; %fill lower right corner
    filledYc(:,w+1:end-w,w+1:end-w) = yc;

    % Reset waitbar and perform computations running in the vertical direction
    if isWait
        waitbar(0,hWait,'0% Complete');
    end
    mW = m(2)+w;
    for yIdx = w+1:m(2)+w
        for xIdx = w+1:m(3)+w

            % Only consider bad fits
            if yc(end,yIdx-w,xIdx-w)>r2Thresh
                continue
            end

            r2Vals = repmat(filledYc(end,yIdx-w:yIdx+w,xIdx-w:xIdx+w),[1 1 n]);
            if all(r2Vals <= filledYc(end,yIdx,xIdx))
                continue
            end
            mapVals = filledYc(1:end-1,yIdx-w:yIdx+w,xIdx-w:xIdx+w);

            % Removes bad fits and NaN values
            mapVals(r2Vals<r2Thresh) = [];
            mapVals                  = reshape(mapVals,[],n);
            nanInd                   = repmat(any(isnan(mapVals),2),[1 n]);
            mapVals(nanInd)          = [];
            mapVals                  = reshape(mapVals,[],n);
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

            r2Test = 1-(r'*r)./sum((ydata-mean(ydata)).^2);
            if r2Test > yc(end,yIdx-w,xIdx-w)
                filledYc(1:end-1,yIdx,xIdx) = x0;
                filledYc(end,yIdx,xIdx)     = r2Test;
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

end %qt_models.cleanmaps


%------------------------------------------
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

end