function fitmaps(obj,varargin)
%fitmaps  Performs the fitting operation for maps
%
%   fitmaps(OBJ) performs fitting operations over an entire stack of images
%   stored in the "y" property of the qt_models sub-class object OBJ. To save
%   memory, the individual residuals are not computed as this would effectively
%   double the memory requirements for a given data set.
%
%   fitmaps(OBJ,'WaitBar',H) performs fitting operations as described
%   previously, but updates the wait bar specified by the handle H. This syntax
%   provides a means of customizing the progress display.

    % Parse the inputs
    [hWait] = parse_inputs(obj,varargin{:});
    

    % Non-linear computations (all others are performed in the sub-class
    % specific method "processFit").
    nInds = numel( obj.nlinParams{obj.modelVal} );
    yc    = []; %initialize in the event no non-linear fits are required
    if any(nInds)

        % Get some preliminary info. During this process the data stored in the
        % "y" and "guess" properties are reshaped into a 2D array so that the
        % fitting algorithms can more easily handle arbitrary multi-dimensional
        % data.
        y           = obj.yProc(:,:);
        mY          = num2cell( size(obj.y) );
        yc          = obj.guess(:,:);
        yc(end+1,:) = NaN; %expand to include R^2

        % Use the "mapSubset" property to force values of "y" to NaNs
        y( repmat(~obj.mapSubset(:)',[mY{1} 1]) ) = NaN;

        % Pre-proccess the parameter array, "yc", to exclude NaNs from further
        % analysis. NaN values in the parameter array are used to omit values
        % in the data array, "y", from processing.
        yc( repmat(any(isnan(y),1),[nInds+1 1]) ) = NaN;

        % Pre-process the yc array for non-dynamic exams. Image values of 0 or
        % NaN are excluded from further analysis. Dynamic exams estimate [Gd],
        % which can reasonably assume values of 0. Since the NaN values from the
        % "guess" property are implicity inserted into the estimation array,
        % there is no need to repeat the process here
        if ~any(strcmpi(class(obj),{'dce','dsc'}))
            yc( repmat( any(y==0,1), [nInds+1 1]) ) = NaN;
        end

        % Determines computation type
        if (is_par<3) %serial computation
            calcF = @serialcalc;
        elseif (is_par==3) %paralell computation using Parallel Toolbox
            calcF = @parcalc;
        end

        % Compute the maps and ignore errors if the user kills the waitbar
        try
            yc = calcF();

            % Cleans up map (the inputs must be reshaped to the original size to
            % ensure that the spatial component of the "cleanmaps" method will
            % work)
            argsIn = {reshape(y,mY{:}),reshape(yc,[],mY{2:end})};
            if obj.guiDialogs
                argsIn(end+1:end+2) = {'WaitBar',hWait};
            end
            yc = obj.cleanmaps(argsIn{:});

        catch ME
            validErrs = {'MATLAB:waitbar:InvalidInputs'};
            if ~any( strcmpi(ME.identifier,validErrs) )
                rethrow(ME);
            else
                return
            end
        end

    end

    % Perform any additional exam specific processing
    obj.processFit(yc);

    % Delete the waitbar
    if ishandle(hWait)
        delete(hWait);
    end

%--------------------------------Map Calculations-------------------------------

    % Serial map calculation
    function ycOut = serialcalc

        % Initialize
        ycOut  = yc;
        m      = size(ycOut);
        fitFcn = obj.fitFcn;

        % Calculate maps
        isWaitBar = ~isempty(hWait);
        for vIdx = 1:m(2)

            if any( isnan(ycOut(1:end-1,vIdx)) )
                continue
            end

            % Fit/store ydata and R^2
            ydata         = y(:,vIdx);
            [x0,~,r]      = fitFcn(yc(1:end-1,vIdx),ydata);
            ycOut(:,vIdx) = [x0;1-(r'*r)./sum((ydata-mean(ydata)).^2)];

            % Update waitbar
            if isWaitBar
                waitbar(vIdx/m(2), hWait,...
                                         [num2str(vIdx/m(2)*100) '% Complete']);
            end

        end

    end %serial_calc

    % MATLAB Parallel map calculation
    function ycOut = parcalc

        % Initialize
        m     = size(yc);
        mData = size(y);
        n     = matlabpool('size');

        % Formats arrays for parallel computation
        y    = parallelize(y,n,2);
        yc   = parallelize(yc,n,2);

        % The following parfor loop requires that a unique function handle 
        % exists for each worker. Create a cell to store the unique function
        % handles
        fitFcns = cell(n,1);
        for parIdx = 1:n
            fitFcns{parIdx} = obj.fitFcn;
        end

        % Perform the map computations
        parfor parIdx = 1:n

            % Slice the loop variables
            parYc = squeeze(yc(parIdx,:,:));
            parY  = squeeze(y(parIdx,:,:));
            for vIdx = 1:size(parY,2)
                if any(isnan(parYc(1:end-1,vIdx)))
                    continue
                end

                % Fit data
                ydata         = parY(:,vIdx);
                [x0,~,r]      = fitFcns{parIdx}(parYc(1:end-1,vIdx),ydata(:));
                parYc(:,vIdx) = [x0;1-(r'*r)./sum((ydata-mean(ydata)).^2)];
            end

            % Store data
            yc(parIdx,:,:) = parYc;

        end

        % Reshapes data
        y     = unparallelize(y,mData);
        ycOut = unparallelize(yc,m);

    end %par_calc

end %fitmaps


%------------------------------------------
function varargout = parse_inputs(obj,varargin)

    % Default wait dialog setup
    hWait = [];
    if ~nargin && obj.guiDialogs
        hWait = waitbar(0,'0% Complete',...
                                       'Name','Calculating parametric maps...');
    end

    % Initialize the input parser and setup the optional inputs
    parser = inputParser;
    parser.addParamValue('WaitBar',hWait,@ishandle)

    % Parse the inputs and deal the outputs
    parser.parse(varargin{:});
    varargout = struct2cell(parser.Results);

end %parse_inputs