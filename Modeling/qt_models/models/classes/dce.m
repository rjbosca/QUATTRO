classdef dce < qt_models

    properties (AbortSet=true,SetObservable=true) %general model properties

        % MR imaging repetition time in ms
        tr

        % MR imaging flip angle in degrees
        fa

        % Number of baseline time points
        %
        %   An integer representing the number of baseline time points to use
        %   in the estimation of the steady-state signal intensity, S0. Note
        %   that preEnhance>ignore
        preEnhance

        % Image number of the recirculation cut-off
        %
        %   An integer representing the last image before contrast recirculation
        %   occurs. This value is used in "first pass" models to neglect data
        %   that contain contributions from recirculated contrast. Note that
        %   recirc>preEnhance
        recirc

        % Minimum enhancement threshold
        %
        %   "enhanceThresh" defines the minimum enhancement ratio (defined as
        %   the ratio of the signal intensity change from baseline to the
        %   baseline signal intensity). Voxels below this threshold are ignored
        %   during map computations
        enhanceThresh = 0.5;

        % Large artery hematocrit
        %
        %   Default: 0.45
        hctArt = 0.45;

        % Blood T10 in milliseconds
        %
        %   Assumed blood pre-contrast relaxation time in ms (default: 1440).
        %   This value is only used when T1 correction is enabled.
        bloodT10 = 1440;

        % Tissue T10 in milliseconds
        %
        %   Assumed tissue pre-contrast relaxation time in ms (default: 1000).
        %   Tissue T10 can be either a scalar nd array of values. This property
        %   is only used when T1 correction is enabled.
        tissueT10 = 1000;

        % Contrast relaxivity in /mM/s
        %
        %   Assumed relaxivity of the contrast agent in /mM/s (default: 4.9).
        %   This property is only used when T1 correction is enabled.
        r1 = 4.9;

        % Flag for converting signal intensity to contrast concentration
        %
        %   When true (default), signal intensity changes (measured from
        %   pre-contrast) are converted to changes in contrast agent
        %   concetration assuming a linear relaxation rate relationship.
        t1Correction = true;

        % Integration time for area under the curve (AUC)
        %
        %   "tIntegral" is a numeric vector (or scalar) of integration times
        %   (specified in seconds) to use when calculating the initial area
        %   under the curve (IAUC) and blood-normalized initial area under the
        %   curve (BNIAUC).
        %
        %   Default: [60 120 180]
        tIntegral = 60:30:180;

        % Vascular input function storage
        %
        %   A vector containing the vascular signal intensity for DCE and
        %   DSC exams. To use a custom VIF, set this property. When using
        %   the qt_models object with QUATTRO, just calling this property
        %   will access the curent ROIs to calculate the VIF
        vif

    end

    properties (Dependent = true)

        % Function used for model fitting
        %
        %   Function handle to the current DCE model of the form @(x0,t) f(x0,t)
        %   where x0 are model parameters and t is the dependent variable (i.e.
        %   time).
        %
        %   Note that uniformly spaced values of t are assumed for this function
        %   handle. For non-uniformly spaced values, use plotFcn instead
        modelFcn

        % Function used for plotting the model
        %
        %   Function handle to the current DCE convenient for plotting the model
        %   with the form @(x0,t) f(x0,t).
        plotFcn

    end

    properties (Dependent = true, Hidden = true)

        % Flag for computation readiness
        %
        %   This flag is defined in all sub-classes of qt_models. However,
        %   because the "calcsReady" property of qt_models checks the x/y data
        %   of the object, no checks need be performed here.
        isReady

        % Semi-quantitative parameters
        %
        %   "otherParams" is a cell array of strings containing the specifier
        %   for all model parameters that can be computed without a non-lienar
        %   fitting alogrithm. These parameters are computed during the call to
        %   the "processFit" method. Valid parameters are:
        %
        %       Parameter       Description
        %       ===========================
        %       'BNIAUC'        Blood normalized initial area under the curve
        %                       integrated from contrast arrival to the time
        %                       interval specified by the property "tIntegral"
        %                       (units: arb)
        %
        %       'IAUC'          Initial area under the [Gd] curve integrated
        %                       from contrast arrival (preEnhancement+1) to the
        %                       time interval specified by the property
        %                       "tIntegral" (units: arb).
        %
        %       'kep'           Reflux rate constant (for GKM) defined as the
        %                       ratio of Ktrans to ve (see nlinParams for more
        %                       information; units: 1/s).
        %
        %       'SER'           Signal enhancement ratio (units: arb)
        %
        %       'TTP'           Time to peak enhancement, not to exceed the time
        %                       at which contrast recirculation (see the
        %                       "recirc" property) is defined (units: s)
        %
        %       'Washout'       Washout slope calculated from an ordinary least
        %                       squares fit of the [Gd] estimate from the peak
        %                       enhancement to the end of the exam (units:
        %                       [Gd]/s). Note that the fitted line is forced to
        %                       pass through the peak [Gd].
        otherParams

        % Parameter units
        %
        %   "paramUnits" is a cell array of strings specifying the units each of
        %   the parameters in the properties "nlinParams" and "otherParams"
        paramUnits

        % Processed VIF curve
        %
        %   Calculated [Gd] concentration of the VIF
        vifProc

    end

    properties (Constant,Hidden = true)

        % Model names
        %
        %   A string cell array containing the names of the models. The location
        %   of each string specifies the index that should be used to access the
        %   actual model using the model property.
        %
        %   The qt_models GUI uses this property to populate the "Models" pop-up
        %   menu.
        modelNames = {'GKM 3 Param','GKM 2 Param','Washout'};

        % Non-linear model parameter names
        %
        %   "nlinParams" is a cell a array of strings containing the specifiers
        %   for each model parameter. Valid parameters are:
        %
        %       Parameter       Description
        %       ===========================
        %       'Ktrans'        Initial [Gd] transfer rate (units: 1/s)
        %                       between the capillary space and extracellular
        %                       extravasculal space (EES)
        %
        %       've'            Fractional EES volume (units: arb)
        %
        %       'vp'            Fractional plasma volume (units: arb)
        nlinParams = { {'Ktrans','ve','vp'},...GKM 3-parameter
                       {'Ktrans','ve'},...GKM 2-parameter
                       {} };

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = dce(varargin)
        %dce  Class for performing quantitative DCE-MRI modeling
        %
        %   OBJ = dce(T,Y,VIF) creates a dce model object for the vector of
        %   signal intensities, Y, at time points T using the vascular input
        %   function VIF. **Important** the time vector should be specified in
        %   units of seconds
        %
        %   OBJ = dce(QTEXAM) creates a dce modeling object from the data stored
        %   in the qt_exam object QTEXAM. Associated QUATTRO links are generated
        %   if available.
        %
        %   OBJ = dce(...,'PROP1',VAL1,...) creates a dce modeling object as
        %   above, initializing the class properties specified by 'PROP1' to
        %   the value VAL1

            % Construct DCE specific defaults
            obj.bounds = [0 inf
                          0  1
                          0  1];
            obj.xLabel = 'Time (min)';
            obj.yLabel = '\Delta S.I. (a.u.)';
            obj.guess  = [0.1 0.5 0.04]; %[ktrans,ve,vp]

            % Parse the inputs
            if (nargin==0)
                return
            end
            [props,vals] = parse_inputs(varargin{:});

            % Apply user-specified options
            for prpIdx = 1:length(props)
                obj.(props{prpIdx}) = vals{prpIdx};
            end

            % Add PostSet listeners to update the display/fitting routines when
            % changes to dce specific properties occur
            addlistener(obj,'fa',          'PostSet',@fa_postset);
            addlistener(obj,'preEnhance',  'PostSet',@preEnhance_postset);
            addlistener(obj,'recirc',      'PostSet',@recirc_postset);
            addlistener(obj,'t1Correction','PostSet',@t1Correction_postset);
            addlistener(obj,'tr',          'PostSet',@tr_postset);

        end %dce

    end %class constructor


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.isReady(obj)

            % Determine if all necessary parameters for computations with or
            % without T1 correction are ready
            t1Ok = (obj.t1Correction &&...
                    ~isempty(obj.tr) &&...
                    ~isempty(obj.fa) &&...
                    ~isempty(obj.bloodT10) &&...
                    ~isempty(obj.tissueT10)) ||...
                   (~obj.t1Correction &&...
                    ~isempty(obj.preEnhance));

            % Determine if the modeling choices are consistent with current data
            % such that computations can be run
            mOk = (any( obj.modelVal==1:2 ) &&...
                   ~isempty(obj.vifProc)) ||...
                  (obj.modelVal==3);

            val = t1Ok && mOk;

        end %get.isReady

        function val = get.modelFcn(obj)

            % Cache the VIF and hematocrit to avoid extra property calls
            v   = obj.vifProc;
            hct = obj.hctArt;

            switch obj.modelVal
                case 1
                    val = @(x,xdata) GKM(x(:),xdata,v,hct);
                case 2
                    val = @(x,xdata) GKM([x(:);0],xdata,v,hct);
                case 3
                    val = @(x,xdata) x(1)*(xdata-x(2)) + x(3);
            end

        end %get.modelFcn

        function val = get.otherParams(obj)

            % Initialize the output
            val = {'Washout','Kinetics','MaxUptake','Uptake',...
                                                   'IAUC','BNIAUC','SER','TTP'};

            % Create values for the IAUC and BNIAUC since these tags will need
            % some kind of flag for different integration times
            if ~isempty(obj.tIntegral)

                % Round all integration times to the nearest second
                tInt = round(obj.tIntegral);

                % Remove the IACU and BNIAUC strings
                val = val( ~strcmpi(val,'IAUC') & ~strcmpi(val,'BNIAUC') );
                val = [val,...
                       arrayfun(@(x) ['IAUC' num2str(x)],tInt,...
                                                      'UniformOutput',false)];
                if ~isempty(obj.vifProc)
                    val = [val arrayfun(@(x) ['BNIAUC' num2str(x)],tInt,...
                                                        'UniformOutput',false)];
                end
            else %remove IAUC strings
                val = val( ~strcmpi(val,'IAUC') & ~strcmpi(val,'BNIAUC') );
            end

            % Kep should be calculated when "modelVal" is 1 or 2 (i.e., using
            % GKM)
            if any(obj.modelVal==1:2)
                val{end+1} = 'kep';
            end

        end %get.otherParams

        function val = get.paramUnits(obj)

            % Basic unit setup
            val = struct('Ktrans','1/second',...
                         'kep','1/second',...
                         've','',...
                         'vp','',...
                         'Kinetics','',...
                         'IAUC','mole/liter*second',...
                         'BNIAUC','',...
                         'SER','',...
                         'TTP','second',...
                         'MaxUptake','millimole/liter/second',...
                         'Uptake','millimole/liter/second',...
                         'Washout','millimole/liter/second');

            % For IAUC and BNIAUC, grab the integration time dependent names
            % from the "otherParams" property and create fields for those maps
            pNames = obj.otherParams;
            pNames = pNames( ~cellfun(@isempty,strfind(pNames,'IAUC')) );
            for nameIdx = 1:numel(pNames)
                if strcmpi(pNames{nameIdx}(1:4),'IAUC')
                    val.(pNames{nameIdx}) = val.IAUC;
                else
                    val.(pNames{nameIdx}) = val.BNIAUC;
                end
            end

            % Remove the unnecessary fields
            val = rmfield(val,{'IAUC','BNIAUC'});

        end %get.paramUnits

        function val = get.plotFcn(obj)

            % Cache the VIF and hematocrit to avoid future property calls
            v   = obj.vifProc;
            hct = obj.hctArt;

            switch obj.modelVal
                case 1
                    val = @(x,xdata) GKM_plot(x,xdata,v,hct);
                case 2
                    val = @(x,xdata) GKM_plot([x 0],xdata,v,hct);
                case 3
                    val = obj.modelFcn;
            end

        end %get.plotFcn

        function val = get.vifProc(obj)

            val = obj.vif(:);
            if isempty(val)
                return
            end

            % Process the VIF and return only those values specified by "index"
            val = squeeze(obj.process(val,obj.bloodT10));
            val = val(obj.subset);

        end %get.vifProc

    end %get methods


    %------------------------------ Other Methods ------------------------------
    methods (Hidden = true)

        function val = process(obj,val,t10)
        %proccess  Performs pre-processing the "y" data
        %
        %   process(OBJ,VAL) calculates signal inensity conversions for various
        %   qt_models sub-classes during calls to the "yProc" property of
        %   qt_models, where OBJ is the dce object and VAL is the data to be
        %   converted
        %
        %   process(...,T10) performs the above operation, using T10 in lieu of
        %   the value stored in the "tissueT10" property.
        %
        %   This method converts dce signal intensity to arbitrary units of [Gd]
        %   by one of two methods: (1) ratio of the difference in post-contrast
        %   and pre-contrast signal intensity (SI) to pre-contrast SI (i.e.
        %   relative SI) or (2) using the si_ratio2gd based on the value of
        %   "t1Correction"

            % Determine value for T10
            if (nargin<3)
                t10 = obj.tissueT10;
            end

            % Calculate the average pre-contrast signal (averaging along the
            % temporal dimension)
            tPre                       = obj.subset; %initialize the vector
            tPre(obj.preEnhance+1:end) = false; %pre-enhancement series mask
            preSi                      = mean( val(tPre,:), 1 );
            
            % Process y-data
            n   = numel( size(val) )-1;
            val = double(val);
            if obj.t1Correction
                val = si_ratio2gd(preSi,val,obj.fa,obj.tr,t10,obj.r1);
            else %delta SI: post-pre
                val = val-repmat(preSi,[size(val,1) ones(1,n)]);
            end
            
            % Discrete convolution requires uniform time increments,
            % fix time here if necessary
            %TODO: this is a pain. The check on the number of unique elements
            %will slow down the processing
            if any( ~obj.subset ) &&...
                                    (numel(unique( diff(obj.x(obj.subset)) ))>1)
                xi  = linspace(1,length(obj.x),length(obj.x));
                val = interp1(obj.x,val,xi);
            end

        end %dce.process

        function val = processFit(obj,val)
        %processFit  Performs post-processing on fitted data
        %
        %   processFit calculates additional model parameters that are not
        %   otherwise computed by the "fit" method. For DCE objects, the
        %   additional model parameter kep is calculated in addition to the
        %   initial area under the curve (IAUC) and blood normalized IAUC
        %   (BNIAUC). The latter two maps use the value specified in the
        %   "preEnahcne" property to determine the initial integration bound.

            % Determine if maps are being computed or if the user is performing
            % single data analysis
            isSingle = obj.isSingle;
            results  = obj.results;
            isSemiQ  = (isempty(val) && (obj.modelVal==3));

            % Calculate kep
            if all(isfield(results,{'ktrans','ve'}))
                results.kep = results.ktrans./results.ve;
            end

            % Gather some data from the current object that will be used for
            % computations
            t0Idx                         = obj.preEnhance;
            tRCIdx                        = obj.recirc; %recirculation cut-off
            [tPre,tPost]                  = deal(obj.subset);
            tPre(t0Idx+1:end)             = false; %pre-enhancement time vector mask
            tPost([1:t0Idx tRCIdx+1:end]) = false; %pre-recirculation time vector mask
            t                             = 60*obj.x; %convert time vector from min. to s.
            y                             = obj.yProc;
            mY                            = size(y);
            yVif                          = obj.vifProc;
            preSi                         = mean( obj.y(tPre,:), 1 );
            nanMask                       = ~obj.mapSubset;


            %==================================================
            % Calculate the initial area under the curve (IAUC)
            %==================================================
            for aucIdx = obj.tIntegral(:)'

                % Interpolate every 5 seconds
                tNew = ( (0:5:aucIdx)+t(t0Idx) )'; %enforce column vector

                % Create the map and associated meta data
                mapTag           = sprintf('IAUC%d',round(aucIdx));
                iaucMap.(mapTag) = squeeze( trapz(tNew, interp1(t,y,tNew), 1) );
                if ~isSingle
                    iaucMap.(mapTag)           = reshape(iaucMap.(mapTag),...
                                                                     mY(2:end));
                    iaucMap.(mapTag)(nanMask) = NaN;
                end

            end


            %=============================================
            % Calculate the blood normalized IAUC (BNIAUC)
            %=============================================
            if ~isempty(yVif)

                for aucIdx = obj.tIntegral(:)'

                    % Interpolate every 5 seconds
                    tNew   = ( (0:5:aucIdx)+t(t0Idx) )'; %enforce column vector
                    yNew   = interp1(t,y,tNew);
                    vifNew = interp1(t,yVif,tNew);

                    % Create the map and associated meta data
                    mapTag             = sprintf('BNIAUC%d',round(aucIdx));
                    bniaucMap.(mapTag) = squeeze( trapz(tNew,yNew,1) )/...
                                                           trapz(tNew,vifNew,1);
                    if ~isSingle
                        bniaucMap.(mapTag) =...
                                          reshape(bniaucMap.(mapTag),mY(2:end));
                        bniaucMap.(mapTag)(nanMask) = NaN;
                    end

                end

            end


            %========================================
            % Calculate the frame of peak enhancement
            %========================================
            % Note that this cacluation is limited to the window defined by the
            % recirculation cut-off, so the number of pre-enhancement images
            % must be added to the actual index (ttp).
            [yPeak,ttp] = max( y(tPost,:), [], 1);
            ttp         = ttp + sum(tPre);


            %=============================================
            % Calculate the signal enhancement ratio (SER)
            %=============================================
            ser = squeeze( yPeak./preSi );


            %====================================
            % Calculate the washin/washout curves
            %====================================
            % Determine the washout slope using ordinary least squares, forcing
            % the fit through the peak enhancement point
            [initSlp,slp,washKin,rSq,mSqErr,res,stdRes] =...
                                                       deal(nan( size(yPeak) ));
            for idx = 1:prod(mY(2:end))

                if isempty(ser) || any( isnan(y(:,idx)) ) ||...
                                 (ser(idx)<obj.enhanceThresh) || isnan(ser(idx))
                    continue
                end

                % Create an indexer for the time vector
                tIdxer               = obj.subset;
                tIdxer(1:ttp(idx)-1) = false;
                yUp                  = y(t0Idx:ttp(idx),idx);
                yWash                = y(tIdxer,idx);

                % Grab the time vector
                tUpSlp   = t(t0Idx:ttp(idx));
                tWashSlp = t(tIdxer);

                % Calculate the uptake and washout slopes (shift the x values so
                % the OLS fit is forced to go throught the maximum signal point)
                slp(idx)     = olsfi(tWashSlp-min(tWashSlp),yWash,yPeak(idx));
                initSlp(idx) = olsfi(tUpSlp-max(tUpSlp),yUp,yPeak(idx));

                % When using the semi-quantitative washout model, the non-linear
                % fitting call is bypassed, so the fitting criteria must be
                % calculated here
                if isSemiQ %washout model, create an R^2 map
                    x0          = [slp(idx);t(ttp(idx));yPeak(idx)];
                    wFcn        = obj.modelFcn(x0,tWashSlp);
                    rSq(idx)    = r_squared(tWashSlp,yWash,wFcn);
                    mSqErr(idx) = mean_sq_err(tWashSlp,yWash,wFcn);
                    res(idx)    = sum( wFcn-yWash );
                    stdRes(idx) = sum( std_res(tWashSlp,yWash,wFcn) );
                    kin         = (wFcn(end)-wFcn(1))/wFcn(1);
                    washKin(idx) = 0;
                    if (kin>0.1)
                        washKin(idx) = 1;
                    elseif (kin<-0.1)
                        washKin(idx) = -1;
                    end
                end
            end

            % Calculate the maximum slope in the recirculation window
            maxSlp = max( diff(y(obj.preEnhance:obj.recirc,:))./...
                         repmat(diff(t(obj.preEnhance:obj.recirc)),[1 prod(mY(2:end))]), [], 1 );

            % Again, for the semi-quantitative computations, dealing the
            % goodness-of-fit criteria must be handled here
            if isSemiQ
                val = reshape(rSq,[1 mY(2:end)]);
                if isSingle %MSE, Res, and StdRes only computed for "fitplot"
                    results.MSE    = mSqErr;
                    results.Res    = res;
                    results.StdRes = stdRes;
                end
            end

            %========================================
            % Calculate the frame of peak enhancement
            %========================================
            % Map the TTP values to the actual acquistion time
            ttpInds = unique(ttp(:))';
            for tIdx = ttpInds
                ttp( ttp==tIdx ) = t(tIdx);
            end

            % Before dealing the results, maps that were calculated in this
            % function must be reshaped
            if ~isSingle
                initSlp = reshape(initSlp,mY(2:end));
                maxSlp  = reshape(maxSlp,mY(2:end));
                ser     = reshape(ser,mY(2:end));
                slp     = reshape(slp,mY(2:end));
                ttp     = reshape(ttp,mY(2:end));
                washKin = reshape(washKin,mY(2:end));
            end

            % Replace the map arrays (i.e. val) with image objects for each map
            % and (R^2) or simply attach units to the new single data fit
            paramNames = [obj.modelParams(:);'RSq']';
            for param = paramNames

                switch param{1}
                    case 'Ktrans'
                        pData                      = val(1,:,:);
                        metaData.SeriesDescription = param{1};
                    case 'kep'
                        pData                      = val(1,:,:)./val(2,:,:);
                        metaData.SeriesDescription = param{1};
                    case 've'
                        pData                      = val(2,:,:);
                        metaData.SeriesDescription = param{1};
                    case 'vp'
                        pData                      = val(3,:,:);
                        metaData.SeriesDescription = param{1};
                    case 'RSq'
                        pData                       = val(end,:,:);
                        metaData.SeriesDescription = 'R Squared';
                    case 'SER'
                        pData                      = ser;
                        metaData.SeriesDescription = 'Signal enhancement ratio';
                    case 'TTP'
                        pData                      = ttp;
                        metaData.SeriesDescription = 'Time-to-peak';
                    case 'Kinetics'
                        pData                      = washKin;
                        metaData.SeriesDescription = 'Washout Kinetics';
                    case 'MaxUptake'
                        pData                      = maxSlp;
                        metaData.SeriesDescription = 'Maximum initial slope';
                    case 'Uptake'
                        pData                      = initSlp;
                        metaData.SeriesDescription = 'Initial slope';
                    case 'Washout'
                        pData                      = slp;
                        metaData.SeriesDescription = 'Washout';
                    otherwise %handle IAUC and BNIAUC

                        if exist('iaucMap','var') &&...
                           isempty( strfind(param{1},'BN') ) &&...
                                    ~isempty( strfind(param{1},'IAUC') )
                            pData                      = iaucMap.(param{1});
                            metaData.SeriesDescription =...
                                sprintf('Initial area under the curve (%ss)',...
                                        param{1}(5:end));
                        elseif exist('bniaucMap','var') &&...
                                  ~isempty( strfind(param{1},'BNIAUC') )
                            pData                      = bniaucMap.(param{1});
                            metaData.SeriesDescription =...
                                            sprintf('%s %s (%ss)',...
                                                    'Blood-normalized',...
                                                    'initial area under the curve',...
                                                    param{1}(7:end));
                        elseif ~exist('iaucMap','var') &&...
                                                       ~exist('bniaucMap','var')
                            warning('dce:processFit:invalidParam',...
                                    'Unknown model parameter "%s"...\n',....
                                                              param{1});
                            continue
                        end

                end

                % Deal the data appropriately
                pUnits = ''; %default units
                if isfield(obj.paramUnits,param{1})
                    pUnits = obj.paramUnits.(param{1});
                end
                if ~isSingle

                    % Compute the window width and window center. These meta
                    % data fields are used to update the WW/WL when the qt_image
                    % object is constructed
                    pDataMin = min( pData(~isnan(pData) & ~isinf(pData)) );
                    pDataMax = max( pData(~isnan(pData) & ~isinf(pData)) );
                    metaData.WindowWidth  = (pDataMax-pDataMin);
                    metaData.WindowCenter = pDataMin + (pDataMax-pDataMin)/2;

                    results.(param{1}) =...
                                            qt_image(squeeze(pData),...
                                                     'metaData',metaData,...
                                                     'tag',param{1},...
                                                     'units',pUnits);
                else
                    results.(param{1}) = unit(pData,pUnits);
                end
            end

            % Store the structure
            obj.results = results;

        end %dce.processFit

        function val = processGuess(obj,val)
        %processGuess  Performs sub-class specific estimates for "guess"
        %
        %   processGuess(OBJ,VAL)

            % Only continue if y data exist
            %FIXME: the second condition of this if statment is supposed to
            %avoid applying the fitting threshold to plot computations, but I
            %need to validate that the data check is accomplishing that...
            if isempty(obj.y) || (size(obj.y,2)==1)
                return
            end

            % Calculate the mask of voxels that need to be processed (i.e. those
            % that enhanced)
            mask = obj.processMapSubset;

            % Since there is currently no way to estimate the parameters, the
            % "guess" property should simply be a vector of N elements, where N
            % is the number of model parameters
            if (numel(val)==length(val)) %only enlarge the array for vector guesses
                val      = repmat(val,[1 numel(mask)]);
            end
            val(:,~mask) = NaN;

        end %dce.processGuess

        function val = processShow(obj,val)
        %processShow  Perform sub-class specific "show" operations
        %
        %   processShow(OBJ) performs display operations specific to the
        %   dce object OBJ following a call to the qt_models method "show".
        %   Calls to this method result, if possible, in the display of the VIF,
        %   contrast agent arrival/recirculation times, and washout fit.

            % Validate that non-map data exist
            if isempty(obj.y) || isempty(obj.x) || (ndims(obj.y)>2)
                return
            end

            % Grab the axis and cache some global values that are used in all
            % additional plots
            hAx = findobj(obj.hFig,'Tag','axes_main');
            t0  = obj.preEnhance;
            xD  = obj.x;
            xP  = obj.xProc;
            yP  = obj.yProc;


            %=============
            % Show the VIF
            %=============
            if ~isempty(obj.vifProc)

                % Try to find a previous plot
                hVif = findobj(hAx,'Tag','vifPlot');

                % Plot the data
                if isempty(hVif) || ~ishandle(hVif)
                    plot(hAx,xP,obj.vifProc,'-r','Tag','vifPlot');
                else
                    set(hVif,'XData',xP,'YData',obj.vifProc);
                end

            end


            %==============================
            % Show the initial uptake slope
            %==============================
            if (obj.modelVal==3) && isfield(obj.results,'Uptake') &&...
                                   ~isempty(obj.results.TTP.value) &&...
                                   ~isempty(obj.results.Uptake.value)

                % Try to find the previous uptake plot
                hUp = findobj(hAx,'Tag','uptakePlot');

                % Create the y-data to be plotted
                ttpMin  = obj.results.TTP.convert('min');
                upMin   = obj.results.Uptake.convert('millimole/liter/min');
                peakIdx = find(xD==ttpMin.value);
                xData   = xD(t0+1:peakIdx);
                yData   = upMin.value*(xData-xData(end))+yP(peakIdx);

                % Plot the actual line
                if isempty(hUp)
                    plot(hAx,xData,yData,'-k','Tag','uptakePlot');
                else
                    set(hUp,'XData',xData,'yData',yData);
                end

            end


            %=======================
            % Show the washout slope
            %=======================
            if (obj.modelVal==3) && isfield(obj.results,'Washout') &&...
                                   ~isempty(obj.results.TTP.value) &&...
                                   ~isempty(obj.results.Washout.value)

                % Try to find a previous plot
                hWash = findobj(hAx,'Tag','washoutPlot');

                % Create the yData
                ttpMin  = obj.results.TTP.convert('min');
                washMin = obj.results.Washout.convert('millimole/liter/min');
                peakIdx = find(xP==ttpMin.value);
                x0      = [washMin.value;xP(peakIdx);yP(peakIdx)];
                xData   = obj.x(peakIdx:end);
                yData   = obj.plotFcn(x0,xData);

                % Plot the washout curve
                if isempty(hWash) || ~ishandle(hWash)
                    plot(hAx,xData,yData,'-k','Tag','washoutPlot');
                else
                    set(hWash,'XData',xData,'yData',yData);
                end

            end


            %===============================
            % Show the contrast arrival time
            %===============================
            hPre  = findobj(hAx,'Tag','arrivalPlot');
            xData = repmat(obj.x(obj.preEnhance+1),[2 1]);
            yData = get(hAx,'YLim');
            if isempty(hPre) || ~ishandle(hPre)

                % Plot the data
                plot(hAx,xData,yData,'-g',...
                                     'Tag','arrivalPlot');
            else
                set(hPre,'XData',xData,'YData',yData);
            end


            %============================
            % Show the recirculation time
            %============================
            hRecirc = findobj(hAx,'Tag','recircPlot');
            xData   = repmat(obj.x(obj.recirc),[2 1]);
            if isempty(hRecirc) || ~ishandle(hRecirc)
                plot(hAx,xData,yData,'-r',...
                                     'Tag','recircPlot');
            else
                set(hRecirc,'XData',xData,'YData',yData);
            end

        end %dce.processShow

        function val = processMapSubset(obj)
        %processMapSubset  Creates a mask of enhancing voxels
        %
        %   MASK = processMapSubset(OBJ) creates a mask of voxels that enhance
        %   at least as much as the threshold defined by the "enhanceThresh"
        %   property of the dce object OBJ. These computations are only used
        %   when working with maps.

            % Define the pre-contrast and contrast recirculation window masks
            [tPre,tPost]               = deal(obj.subset);
            tPre(obj.preEnhance+1:end) = false; %pre-enhancement series mask
            tPost(obj.recirc+1:end)    = false; %pre-recirculation series mask

            % Calculate the pre-contrast signal intensity
            preSi = mean(obj.y(tPre,:),1); %average along temporal dimension

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

        function [yc,r2] = results2array(obj)

            % Generate the parameter array
            yc(:,:,1) = obj.results.ktrans;
            yc(:,:,2) = obj.results.ve;
            yc(:,:,3) = obj.results.vp;
            
            % Output R^2
            r2 = obj.results.R_squared;

            % Apply any bounds
            %TODO: there are currently no bounds for handling kep. This is a
            %major issue that needs to be addressed.

        end %dce.results2array

    end %methods (Hidden = true)

end %classdef


%------------------------------------------
function varargout = parse_inputs(varargin)

    % Determine input syntax (either qt_exam object or time/signal/vif)
    parser = inputParser;
    if strcmpi(class(varargin{1}),'qt_exam')
        parser.addRequired('hExam',@(x) x.isvalid);
        opts = varargin(2:2:end);
    elseif (nargin==1)
        error(['qt_models:' mfilename ':invalidExamObj'],...
                        'Single input syntax requires a valid qt_exam object.');
    else
        parser.addRequired('x',  @isnumeric);
        parser.addRequired('y',  @isnumeric);
        parser.addRequired('vif',@isnumeric);
        opts = varargin(4:2:end);
    end

    % Add additional options to the parser
    if ~isempty(opts)

        % Validate the options
        obj   = eval( mfilename );
        props = properties(obj);
        opts  = cellfun(@(x) validatestring(x,props),opts,...
                                                         'UniformOutput',false);

        % Assign the options to the parser
        for prop = opts(:)'
            parser.addParamValue(prop{1},obj.(prop{1}));
        end

    end

    % Parse the inputs
    parser.parse(varargin{:});
    results = parser.Results;

    % When using the qt_exam syntax, populate the properties/values for the
    % qt_exam-derived data
    if isfield(results,'hExam') &&...
                                ~isempty(results.hExam) && results.hExam.isvalid
        props = {'x','bloodT10','tissueT10','preEnhance','recirc',...
                 't1Correction','enhanceThresh','fa','tr','guiDialogs'};
        for prop = props

            % The field is already populated. Since no defaults are used in
            % parsing the inputs and since user-specified options override exam
            % options, skip the current property if data exist in the parser
            % results
            if isfield(results,prop{1}) && ~isempty(results.(prop{1}))
                continue
            end

            switch prop{1}
                case 'fa'
                    results.(prop{1}) = results.hExam.metaData.FlipAngle;
                case 'guiDialogs'
                    results.(prop{1}) = results.hExam.guiDialogs;
                case 'tr'
                    results.(prop{1}) = results.hExam.metaData.RepetitionTime;
                case 'x'
                    results.(prop{1}) = results.hExam.modelXVals.convert('s').value;
                otherwise
                    results.(prop{1}) = results.hExam.opts.(prop{1});
            end

        end
    end

    % Deal the outputs
    varargout{1} = fieldnames(results);
    varargout{2} = struct2cell(results);

end