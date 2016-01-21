classdef qt_options < modelevents & modelopts
%QUATTRO options environment

%# AUTHOR    : Ryan Bosca
%# $DATE     : 17-Jul-2013 17:28:12 $
%# $Revision : 1.01 $
%# DEVELOPED : 8.1.0.604 (R2013a)
%# FILENAME  : qt_options.m

    properties (SetObservable,AbortSet)

        % Image axes link flag
        %
        %   "linkAxes", when TRUE (default), enables linking of all image axes
        %   associated with the curent instance of QUATTRO
        linkAxes    = true;

        % Last export directory
        %
        %   "exportDir" is a string specifying the last directory to which
        %   images, maps, or ROIs were exported
        exportDir   = pwd;

        % Last loaded QUATTRO save file direcotry
        %
        %   String specifying the location of from which the most recent QUATTRO
        %   save file was loaded.
        loadDir     = qt_path;

        % Last loaded QUATTRO save file name
        %
        %   String specifying the file name of the most recently loaded QUATTRO
        %   save file.
        loadFile    = '';

        % Last report directory
        %
        %   String specifying the location to which a report generated from the
        %   "Reports" menu was saved
        reportDir   = pwd;

        % Last saved QUATTRO save file directory
        %
        %   String specifying the location to which the most recent save
        %   operation generated a QUATTRO save file
        saveDir     = pwd;

        % Last saved QUATTRO save file name
        %
        %   String specifying the file name of the most recently generated
        %   QUATTRO save file
        saveFile    = '';

        % Last image import operation directory
        %
        %   String specifying the location from which images were most recently
        %   imported
        importDir   = qt_path;

        % Last map import operation directory
        %
        %   String specifying the location from which maps were most recently
        %   imported
        mapDir      = qt_path;

        % DICOM dictionary file
        %
        %   "dicomDict" is the full file name of the DICOM dictionary to use
        %   when performing read/write operations on DICOM images. This option
        %   and associated operations require the use of the Image Processing
        %   Toolbox. Setting "dicomDict" to the value 'factory' will restore the
        %   MATLAB default dictionary
        %
        %   Default: 'dicom-dict.txt'
        dicomDict   = which('dicom-dict.txt');

        % Parallel computation flag
        %
        %   If true, parallel computation will be enabled using the number of
        %   processors specified by the property "nProcessors". If false
        %   (default), parallel processing is disabled.
        %
        %   This feature requires the Parallel Computaing Toolbox
        parallel    = false;

        % Number of processors
        %
        %   "nProcessors" is an integer specifying the number of processors to
        %   use for computations supporting parallel computation
        nProcessors = 1;

        % Image scaling factor (viewing purpuses only)
        %
        %   Integer factor used to scale up images for viewing. This provides a
        %   means of creating smoother images for visualization, although speed
        %   is sacrificed.
        scale        = 1;

        % Selected model sub-class
        %
        %   "modelClass" is a structure containing fields names corresponding to
        %   the QUATTRO exam types defined in the qt_models package. Each field
        %   contains a string specifying the model selected currently
        modelClass = struct([]);


        % Parameter map/modeling options
        %-------------------------------

        % Lower ADC bound in [mm^2/s]
        %
        %   Default: 0
        adcMin      = 0;

        % Upper ADC bound in [mm^2/s]
        %
        %   Default: 4x10^-3
        adcMax      = 0.004;

        % Lower fractional anisotropy bound
        %
        %   Default: 0
        faMin       = 0;

        % Upper fractional anisotropy bound
        %
        %   Default: 1
        faMax       = 1;

        % Lower kep bound in [s^-1]
        %
        %   Default: 0
        kepMin      = 0;

        % Upper kep bound in [s^-1]
        %
        %   Default: 5/60
        kepMax      = 5/60;

        % Lower Ktrans bound in [s^-1]
        %
        %   Default: 0
        ktransMin   = 0;

        % Upper Ktrans bound in [s^-1]
        %
        %   Default: 5/60
        ktransMax   = 5/60;

        % Lower ve bound [unitless]
        %
        %   Default: 0
        veMin       = 0;

        % Upper ve bound [unitless]
        %
        %   Default: 1
        veMax       = 1;

        % Lower vp bound [unitless]
        %
        %   Default: 0
        vpMin       = 0;

        % Upper vp bound [unitless]
        %
        %   Default: 1
        vpMax       = 1;

        % Lower T1 bound in [ms]
        %
        %   Default: 0
        t1Min       = 0;

        % Upper T1 bound in [ms]
        %
        %   Default: 10^5
        t1Max       = 10000;

        % Lower T2 bound in [ms]
        %
        %   Default: 0
        t2Min       = 0;

        % Upper T2 bound in [ms]
        %
        %   Default: 10^3
        t2Max       = 1000;

        % Minimum value of the coefficient of determination
        %
        %   Default: 0.5
        r2Threshold = 0.5;

        % Gd-DTPA r2 relaxivity in [/sec/mM]
        %
        %   Default: 5.9
        r2Gd         = 5.9;

        % Pharmacokinetic units
        %
        %   Value specifying the pharmacokinetic untis to be used in DCE
        %   computations. Valid values are:
        %
        %       Value       Units
        %       -----------------
        %         1          s^-1
        %         2         min^-1
        %
        %   Default: 1
        dceUnits = 1;

        % Time vector shift
        %
        %   "timeShift" is a scalar or vector value specifying the amount of
        %   time by which the temporal window for a DCE/DSC exam should be
        %   shifted. This is used, for example, when processing clinical breast
        %   MRI exams to shift the data points to the center of k-space
        timeShift = 0;

        % Multi-slice map computation flag
        %
        %   Default: true
        multiSlice   = true;

        % R-squared map computation/storage flag
        %
        %   Default: true
        rSqMap = true;

        % R1 map calculation/storage flag
        %
        %   Default: false
        r1Map = false;

        % Thermal equilibrium signal intensity map calculation/storage flag
        %
        %   Default: false
        s0Map = false;

        % T1 map calculation/storage flag
        %
        %   Default: true
        t1Map = true;

        % Initial area under the curve map calculation/storage flag
        %
        %   When computing the initial area under the curve, a time interval
        %   must also be defined. Common intervals are 60, 90, and 120 seconds.
        %
        %   Default: true
        iaucMap = true;

        % Ktrans map calculation/storage flag
        %
        %   Default: true
        ktransMap = true;

        % kep map calculation/storage flag
        %
        %   kep:=Ktrans/ve.
        %
        %   Default: false
        kepMap = false;

        % ve map calculation/storage flag
        %
        %   Default: true
        veMap = true;

        % vp map calculation/storage flag
        %
        %   Default: true
        vpMap = true;

        % Signal enhancement ratio map
        %
        %   Default: ture
        serMap = true;

        % Time-to-peak map
        %
        %   Default: true
        ttpMap = true;

        % Contrast washout map
        %
        %   Default: true
        washoutMap = true;

        % Mean transit time map calculation/storage flag
        %
        %   Default: true
        mttMap   = true;

        % Relative cerbral blood volume calculation/storage flag
        %
        %   Default: true
        rcbvMap  = true;

        % ADC map calculation/storage flag
        %
        %   Default: true
        adcMap = true;

        % FA map calculation/storage flag
        %
        %   Default: true
        faMap = true;

        % Mean ADC map calculation/storage flag
        %
        %   This flag will likely be removed in a future release
        meanAdcMap = false;

        % Pseudo-diffusion coefficient (D*) map calculation/storage flag
        %
        %   Default: true
        dStarMap = true;

        % Perfusion fraction (f) map calculation/storage flag
        %
        %   Default: true
        fMap = true;

        % Kurtosis (K) map calculation/storage flag
        %
        %   Default: true
        kMap = true;

        % Inversion flip angle map calculation/storage flag
        %
        %   Default: false
        flipAngleMap = false;

        % R2 map calculation/storage flag
        %
        %   R2:=1/T2
        %
        %   Default: false
        r2Map = false;

        % T2 map calculation/storage flag
        %
        %   Default: true
        t2Map = true;

        % ROI summary stats cut-off
        %
        %   "trimPct" defines the percentage of stats to trim from the upper and
        %   lower values of ROI measurements.
        %
        %   Default: 0
        trimPct = 0;

    end

    properties (SetAccess='protected',Transient)
    % Internal directories, configuration file, and QUATTRO handle properties

        % Location of the user's application directory
        appDir  = qt_path('appdata');

        % Location of the QUATTRO scripts directory
        scptDir = qt_path('script');

        % Location of the QUATTRO configuration file
        cfgFile = '';

        % Cahced QUATTRO handle
        hQt

    end

    properties (SetAccess='protected',Hidden,SetObservable,AbortSet)

        % Flag specifying the DICOM dictionary
        %
        %   "isDfltDict" is a logical flag that specifies that the current value
        %   of the "dicomDict" property is MATLAB's factory default
        isDfltDict = true;

    end

    properties (Dependent)

        % Lower R1 bound in [ms^-1]
        %
        %   Derived from 1/t1Max
        r1Min

        % Upper R1 bound in [ms^-1]
        %
        %   Derived from 1/t1Min
        r1Max

        % Lower R2 bound in [ms^-1]
        %
        %   Derived from 1/t2Max
        r2Min

        % Upper R2 bound in [ms^-1]
        %
        %   Derived from 1/t2min
        r2Max

    end

    properties (Constant,Hidden)

        % Warning information for set methods
        wrnid = 'QUATTRO:options:invalidOption';
        wrnc  = ['Invalid option not applied.\n',...
                                '\t\t Option=%s\t Current Value=%s\t Input=%s'];
        wrnn  = ['Invalid option not applied.\n',...
                                '\t\t Option=%s\t Current Value=%f\t Input=%f'];
        invldn = @(x) isempty(x) || ~isnumeric(x) || isnan(x);
        invldc = @(x) isempty(x) || ~ischar(x);

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = qt_options(varargin)
        % qt_options  Class constructor for QUATTRO options class
        %
        %   OBJ = qt_options loads and stores default or user-defined options
        %   from the file "QUATTRO.cfg", using default options where missing or
        %   invalid options are specified. For more information on defining
        %   QUATTRO options, see QUATTRO.cfg
        %
        %   OBJ = qt_options(H) creates an instance of the qt_options class,
        %   associating the object with the instance of QUATTRO specified by
        %   the handle H.

            % Store QUATTRO handle for access
            if nargin==1 && ishandle(varargin{1}) &&...
                                       strcmp( get(varargin{1},'Name'),qt_name )
                obj.hQt = varargin{1};
            end

            % Initialize the new object
            obj.initialize;

            % Attach the properties' listeners
            addlistener(obj,'dicomDict',     'PostSet',@obj.dicomDict_postset);
            addlistener(obj,'hctCap',        'PostSet',@updatemodels);
            addlistener(obj,'r2Gd',          'PostSet',@updatemodels);

            % Attach the event listeners for the events defined in the class
            % "modelevents"
            addlistener(obj,'updateModel',@updatemodels);

        end %qt_options

    end


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.r1Min(obj)
            val = 1/obj.t1Max;
        end %get.r1Min

        function val = get.r1Max(obj)
            val = 1/obj.t1Min;
        end %get.r1Max

        function val = get.r2Min(obj)
            val = 1/obj.t2Max;
        end %get.r2Min

        function val = get.r2Max(obj)
            val = 1/obj.t2Min;
        end %get.r2Max

    end % Get methods


    %------------------------------- Set Methods -------------------------------
    methods

        % QUATTRO handle set method
        function set.hQt(obj,val)
            if ~ishandle(val) && ~strcmpi(get(val,'Name'),qt_name)
                warning(['QUATTRO:' mfilename ':invalidHandle'],...
                         'An attempt was made to assign an invalid QUATTRO handle.');
            else
                obj.hQt = val;
            end
        end %set.hQt

        % General GUI options
        function set.dicomDict(obj,val)

            % Special case for factory reset
            if strcmpi(val,'factory')
                dicomdict('factory');
                obj.dicomDict = dicomdict('get');
            else

                % Attempt to modify the DICOM dictionary
                try
                    % Set the dictionary and attempt to access a field. This
                    % action will return an error if an invalid file was
                    % specified
                    dicomdict('set',val);
                    dicomlookup('FlipAngle');
                    obj.dicomDict = val;
                catch ME
                    validErrs = {'images:dicomdict:fileNotFound',...
                                 'MATLAB:dataread:TroubleReading'};
                    if all( ~strcmpi(ME.identifier,validErrs) )
                        rethrow(ME);
                    end
                    warning('QUATTRO:qt_options:invalidDicomDict',...
                            'Invalid dictionary file specified. No changes made...');
                end

                % Ensure that the current value is actually set
                dicomdict('set',obj.dicomDict);

            end

        end %set.dicomDict

        function set.importDir(obj,val)
            if obj.invldc(val) || ~exist(val,'dir')
                warning(obj.wrnid,obj.wrnc,'importDir',obj.importDir,val);
            else
                obj.importDir = val;
            end
        end %set.importDir
        function set.mapDir(obj,val)
            if obj.invldc(val) || ~exist(val,'dir')
                warning(obj.wrnid,obj.wrnc,'mapDir',obj.mapDir,val);
            else
                obj.mapDir = val;
            end
        end %set.mapDir
        function set.linkAxes(obj,val)
            if isempty(val) || isnan(val)
                warning(obj.wrnid,obj.wrnn,'linkAxes',obj.linkAxes,val);
            elseif ~isempty(obj.hQt) && ishandle(obj.hQt)
                obj.linkAxes = logical(val);

                % Link or unlink axes
                eObj = getappdata(obj.hQt,'qtExamObject');
                if ~isempty(eObj) && val
                    linkaxes(eObj.hImgs);
                elseif ~isempty(eObj) && ~val
                    linkaxes(eObj.hImgs,'off');
                end
            end
        end %set.linkAxes
        function set.loadDir(obj,val)
            if obj.invldc(val) || ~exist(val,'dir')
                warning(obj.wrnid,obj.wrnc,'loadDir',obj.loadDir,val);
            else
                obj.loadDir = val;
                obj.saveDir = val;
            end
        end %set.loadDir
        function set.loadFile(obj,val)
            if (obj.invldc(val) && ~isempty(val)) ||...
                                  ~exist(fullfile(obj.loadDir,val),'file')
                warning(obj.wrnid,obj.wrnc,'loadFile',obj.loadFile,val)
            else
                obj.loadFile = val;
                obj.saveFile = val;
            end
        end %set.loadFile
        function set.nProcessors(obj,val)
            if ~is_par
                obj.nProcessors = 1;
            elseif obj.invldn(val) || val<1 || val>feature('numcores')
                warning(obj.wrnid,obj.wrnn,'nProcessors',obj.nProcessors,val);
            elseif obj.parallel
                obj.nProcessors = round(val);
                if is_par==3
                    matlabpool close
                end
                if obj.nProcessors>1 && obj.parallel
                    try
                        matlabpool(obj.nProcessors);
                    catch ME
                        warning(['QUATTRO:' mfilename ':parallelStartFail'],...
                                ['Initiation of parallel computations failed ',...
                                 'with the following error:\n%s\n'],ME.identifier);
                    end
                end
            end
        end %set.nProcessors
        function set.parallel(obj,val)
            if ~is_par
                obj.parallel = false;
                warning(obj.wrnid,'Parallel computation toolbox not installed.');
            elseif isempty(val) || isnan(val)
                warning(obj.wrnid,obj.wrnn,'parallel',obj.parallel,val);
            else
                obj.parallel = logical(val);
                if ~obj.parallel %destroy old pools
                    obj.nProcessors = 1;
                    if matlabpool('size')>0
                        matlabpool close force
                    end
                end
            end
        end %set.parallel
        function set.scale(obj,val)
            if obj.invldn(val) || ~any(val==[1 2 4 8])
                warning(obj.wrnid,obj.wrnn,'scale',obj.scale,val);
            else
                obj.scale = val;
            end
        end %set.scale
        function set.saveDir(obj,val)
            if obj.invldc(val) || ~exist(val,'dir')
                warning(obj.wrnid,obj.wrnc,'saveDir',obj.saveDir,val);
            else
                obj.saveDir = val;
            end
        end %set.saveDir
        function set.saveFile(obj,val)
            if (~isempty(val) && obj.invldc(val)) ||...
                    (~isempty(val) && ~exist(fullfile(obj.saveDir,val),'file'))
                warning(obj.wrnid,obj.wrnc,'saveFile',obj.saveFile,val);
            else
                obj.saveFile = val;
            end
        end %set.saveDir
            

        % Modeling options
        function set.adcMin(obj,val)
            if obj.invldn(val) || val<0 || val>=obj.adcMax %#ok<*MCSUP>
                warning(obj.wrnid,obj.wrnn,'adcMin',obj.adcMin,val);
            else
                obj.adcMin = val;
            end
        end %set.adcMin
        function set.adcMax(obj,val)
            if obj.invldn(val) || val<=obj.adcMin
                warning(obj.wrnid,obj.wrnn,'adcMax',obj.adcMax,val);
            else
                obj.adcMax = val;
            end
        end %set.adcMax
        function set.faMin(obj,val)
            if obj.invldn(val) || val<0 || val>=obj.faMax
                warning(obj.wrnid,obj.wrnn,'faMin',obj.faMin,val);
            else
                obj.faMin = val;
            end
        end %set.faMin
        function set.faMax(obj,val)
            if obj.invldn(val) || val<=obj.faMin
                warning(obj.wrnid,obj.wrnn,'faMax',obj.faMax,val);
            else
                obj.faMax = val;
            end
        end %set.faMax
        function set.r2Gd(obj,val)
            if obj.invldn(val) || val<=0
                warning(obj.wrnid,obj.wrnn,'r2Gd',obj.r2Gd,val);
            else
                obj.r2Gd = val;
            end
        end %set.r2Gd
        function set.kepMin(obj,val)
            if obj.invldn(val)|| val<0 || val>=obj.kepMax
                warning(obj.wrnid,obj.wrnn,'kepMin',obj.kepMin,val);
            else
                obj.kepMin = val;
            end
        end %set.kepMin
        function set.kepMax(obj,val)
            if obj.invldn(val) || val<=obj.kepMin
                warning(obj.wrnid,obj.wrnn,'kepMax',obj.kepMax,val)
            else
                obj.kepMax = val;
            end
        end %set.kepMax
        function set.ktransMin(obj,val)
            if obj.invldn(val) || val<0 || val>=obj.ktransMax
                warning(obj.wrnid,obj.wrnn,'ktransMin',obj.ktransMin,val)
            else
                obj.ktransMin = val;
            end
        end %set.ktransMin
        function set.ktransMax(obj,val)
            if obj.invldn(val) || val<=obj.ktransMin
                warning(obj.wrnid,obj.wrnn,'ktransMax',obj.ktransMax,val);
            else
                obj.ktransMax = val;
            end
        end %set.ktransMax
        function set.veMin(obj,val)
            if obj.invldn(val) || val<0 || val>=obj.veMax
                warning(obj.wrnid,obj.wrnn,'veMin',obj.veMin,val);
            else
                obj.veMin = val;
            end
        end %set.veMin
        function set.veMax(obj,val)
            if obj.invldn(val) || val<=obj.veMin || val>1
                warning(obj.wrnid,obj.wrnn,'veMax',obj.veMax,val);
            else
                obj.veMax = val;
            end
        end %set.veMax
        function set.vpMin(obj,val)
            if obj.invldn(val) || val<0 || val>=obj.vpMax
                warning(obj.wrnid,obj.wrnn,'vpMin',obj.vpMin,val);
            else
                obj.vpMin = val;
            end
        end %set.vpMin
        function set.vpMax(obj,val)
            if obj.invldn(val) || val<=obj.vpMin || val>1
                warning(obj.wrnid,obj.wrnn,'vpMax',obj.vpMax,val);
            else
                obj.vpMax = val;
            end
        end %set.vpMax
        function set.t1Min(obj,val)
            if obj.invldn(val) || val<0 || val>=obj.t1Max
                warning(obj.wrnid,obj.wrnn,'t1Min',obj.t1Min,val);
            else
                obj.t1Min = val;
            end
        end %set.t1Min
        function set.t1Max(obj,val)
            if obj.invldn(val) || val<=obj.t1Min
                warning(obj.wrnid,obj.wrnn,'t1Max',obj.t1Max,val);
            else
                obj.t1Max = val;
            end
        end %set.t1Max
        function set.t2Min(obj,val)
            if obj.invldn(val) || val<0 || val>=obj.t2Max
                warning(obj.wrnid,obj.wrnn,'t2Min',obj.t2Min,val);
            else
                obj.t2Min = val;
            end
        end %set.t2Min
        function set.t2Max(obj,val)
            if obj.invldn(val) || val<=obj.t2Min
                warning(obj.wrnid,obj.wrnn,'t2Max',obj.t2Max,val);
            else
                obj.t2Max = val;
            end
        end %set.t2Min
        function set.r2Threshold(obj,val)
            if obj.invldn(val) || ((val<0 || val>1) && ~isinf(val))
                warning(obj.wrnid,obj.wrnn,'r2Threshold',obj.r2Threshold,val);
            else
                obj.r2Threshold = val;
            end
        end %set.r2Threshold

    end %Set methods

end %qt_options