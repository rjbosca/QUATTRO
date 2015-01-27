classdef qt_options < hgsetget
%QUATTRO options environment

%# AUTHOR    : Ryan Bosca
%# $DATE     : 17-Jul-2013 17:28:12 $
%# $Revision : 1.01 $
%# DEVELOPED : 8.1.0.604 (R2013a)
%# FILENAME  : qt_options.m

    properties (SetObservable=true,AbortSet=true)
    % Global options

        % Flag for linking all image axes
        %
        %   If true (default), the linkAxes flag will link all image axes
        %   associated with the curent instance of QUATTRO
        linkAxes    = true;

        % Last export directory
        %
        %   Cache containing, as a string, the location of the last directory
        %   used for exporting images/maps/etc.
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
        %   Integer specifying the number of processors to use for operations
        %   supporting parallel computation
        nProcessors = 1;

        % Imaging exam type
        %
        %   String specifying the imaging exam type (valid options below).
        %   Although this property is writable, there is no guarantee that
        %   changes will occur without error, unless changing to 'generic'
        %
        %       Exam Strings        Description
        %       ---------------------------
        %       'dce'               4D serial dynamic contrast enhanced MRI data
        %                           derived from T1-weighted imaging sequences.
        %
        %       'dsc'               4D serial dynamice susceptibility weighted
        %                           MRI data derived from T2*-weighted imaging
        %                           sequences.
        %
        %       'dti'               Diffusion tensor MRI data. No computations
        %                           are supported currently
        %
        %       'dw' or 'edwi'      Diffusion weighted MRI data. This differs
        %                           from 'DTI' exams in that the number of
        %                           diffusion encoding directions is less than
        %                           6. Computation of the ADC or IVIM parameters
        %                           is supported.
        %
        %       'gsi'               Dual energy CT. No computations are
        %                           supported currently
        %
        %       'multiflip'         Variable flip angle MRI data used to
        %                           estimate T1
        %
        %       'multite'           Variable echo time MRI data used to estimate
        %                           T2
        %
        %       'multiti'           Multiple inversion time MRI data used to
        %                           estimate T1
        %
        %       'multitr'           Multiple repetition time (i.e. saturation
        %                           recovery) used to estimate T1
        %
        %       'surgery'           Mode used to navigate 3D image data sets in
        %                           3 orthogonal planes (axial, coronal,
        %                           sagittal), dropping points for visualization
        %                           and surgical planning purposes
        %
        %      ('generic')          Default exam type used for navigating image
        %                           data sets. No computations are supported
        %                           currently.
        examType    = 'generic';

        % Image scaling factor (viewing purpuses only)
        %
        %   Integer factor used to scale up images for viewing. This provides a
        %   means of creating smoother images for visualization, although speed
        %   is sacrificed.
        scale        = 1;


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

        % Gd-DTPA r1 relaxivity in [/sec/mM]
        %
        %   Default: 4.9
        r1Gd         = 4.9;

        % Gd-DTPA r2 relaxivity in [/sec/mM]
        %
        %   Default: 5.9
        r2Gd         = 5.9;

        % Number of pre-contrast images
        %
        %   Number of pre-contrast images. This option determines the number of
        %   image frames considered in the computation of pre-contrast signal
        %   intensity, and is currently only used in DCE and DSC models.
        %
        %   Default: 6
        preEnhance    = 6;

        % Number of pre-steady state images to ignore
        %
        %   In certain applications, such as DCE and DSC, steady-state imaging
        %   may be achieved at some point in the series beyond the first frame.
        %   This option is used to control what images are ignored in
        %   computations.
        %
        %   Default: 0
        preSteadyState = 0;

        % Minimum enhancement threshold
        %
        %   Fractional enhancement required for performing quantitation in DCE
        %   applications. Enhancement is defined as the ratio of signal
        %   intensity change from baseline to the baseline signal intensity.
        %   Values below this threshold are ignored in the computation of maps.
        enhanceThresh = 0.5;

        % Arterial hematocrit
        %
        %   Default: 0.45
        hctArt        = 0.45;

        % Capillary hematocrit
        %
        %   Default: 0.25
        hctCap        = 0.25;

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

        % Blood T10 (units: milliseconds)
        %
        %   Default: 1440 ms
        bloodT10 = 1440;

        % Tissue T10 (units: milliseconds)
        %
        %   Default: 1000 ms
        tissueT10 = 1000;

        % T1 correction flag for DCE computations
        %
        %   When "t1Correction" is true, estimation of [Gd] is performed based
        %   on the data available to QUATTRO (e.g., single T10 values or T10
        %   maps). Otherwise, the [Gd] concentration is cacluated using delta
        %   S.I.
        %
        %   Default: false
        t1Correction = false;

        % Tissue density
        %
        %   Density of tissue (units: [g/mL]) to be modeled. For brain tissue,
        %   the default value is for brain tissue: 1.04
        density = 1.04;

        % [Gd] proportionality constant
        %
        %   A scalar value providing the proportionality constant to convert DSC
        %   signal intensity to [Gd] concentration using the relationship,
        %   -k/TE*log(S(t)/S0), where k is the proportionality constant. The
        %   default value is 1.
        dscK = 1;

        % Recirculation cut-off
        %
        %   A scalar value specifying the last position in the time vector for
        %   which first-pass tracer kinetics should be used. This value is
        %   preEnhance+5 by default.
        recirc  = 10;

        % Time vector shift
        %
        %   "timeShift" is a scalar or vector value specifying the amount of
        %   time by which the temporal window for a DCE/DSC exam should be
        %   shifted. This is used, for example, when processing clinical breast
        %   MRI exams to shift the data points to the center of k-space
        timeShift = 0;

        % DSC-MRI model value
        %
        %   DSC computations currently support first pass tracer kinetics. Valid
        %   model values and associated descriptions are as follows:
        %
        %       Model Value     Description
        %       ---------------------------
        %            1          First-pass kinetics extracted from a
        %                       gamma-variate fit and subsequent integration 
        dscModel = 1;

        % DCE-MRI model value
        %
        %   DCE computations employ pharmacokinetic models and semi-quantitative
        %   descriptors to produce parameter maps. Valid model values and
        %   associated descriptions are as follows:
        %
        %       Model Value     Description
        %       ---------------------------
        %            1          Two parameter general kinetic model
        %                       (Tofts-Kermode model)
        %
        %            2          Three parameter general kinetic model
        %
        %   Default: 1
        dceModel = 1;

        % Diffusion-weighted model value
        %
        %   DW computations employ the intra-voxel incoherent motion model (or
        %   some simplificiation) to calcaulte diffusion/perfusion parameters.
        %   Valid model values and associated descriptions are as follows:
        %
        %       Model Value     Description
        %       ---------------------------
        %            1          Simple single exponential model including terms
        %                       for the ADC and S0
        %
        %            2          Full IVIM model. ADC, S0, pseudo-diffusion (D*),
        %                       perfusion fraction (k), and kurtosis (K).
        %
        %            3          IVIM excluding psedo-diffusion
        %
        %            4          Linearized single exponential model
        dwModel = 1;

        % DTI model value (not implemented)
        %
        %   Diffusion tensor is currently unsupported.
        %TODO: This is simply a placeholder
        dtiModel = 1;

        % Multiple TE relaxometry model values
        %
        %   T2 computations are performed using one of two exponential models.
        %   Valid model values and associated descriptions are as follows:
        %
        %       Model Value     Description
        %       ---------------------------
        %            1          Single exponential decay including T2 and S0.
        %
        %            2          Single exponential decay modeling R2 instead of
        %                       T2
        %
        %   Default: 1
        multiteModel = 1;

        % Multiple TI relaxometry model values
        %
        %   T1 computations are performed using one of two variable inversion
        %   time (VTI) spin echo (SE) models. Valid model values and associated
        %   descriptions are as follows:
        %
        %       Model Value     Description
        %       ---------------------------
        %            1          VTI SE model assuming an inversion flip angle of
        %                       180 deg. T1 and S0 are modeled
        %
        %            2          Same as 1, except R1 is modeled in lieu of T1
        %
        %            3          VTI SE modeling with an additional free
        %                       parameter for the inversion flip angle. T1, S0,
        %                       and the flip angle are modeld.
        %
        %            4          Same as 4, except R1 is modeled in lieu of T1
        %
        %   Default: 1
        multitiModel  = 1;

        % Multiple TR (saturation recovery) relaxometry model values
        %
        %   T1 computations are performed using a spin echo saturation recovery
        %   signal intensity model. Valid model values and associated
        %   descriptions are as follows:
        %
        %       Model Value     Description
        %       ---------------------------
        %            1          Saturation recovery incorporating T1 and S0
        %
        %            2          Same as 1, except R1 is modeling in lieu of T1
        %
        %   Default: 1
        multitrModel = 1;

        % Multiple flip angle relaxometry model values
        %
        %   T1 computations are performed using a fast spoiled gradient echo
        %   signal intensity model. Valid model values and associated
        %   descriptions are as follows:
        %
        %       Model Value     Description
        %       ---------------------------
        %            1          FSPGR incorporating T1 and S0
        %
        %            2          Same as 1, except R1 is modeling in lieu of T1
        %
        %   Default: 1
        multiflipModel = 1;

        % Generic QUATTRO exam model value
        %
        %   This is simply a placeholder. "genericModel" must equal 1
        genericModel = 1;

        % Surgery QUATTRO exam model value
        %
        %   This is simply a placeholder. "surgeryModel" must equal 1
        surgeryModel = 1;

        % Polarity correction flag for VTI computations
        %
        %   When true (default), polarity correction is performed on magnitude
        %   signal intensities
        invertIr = true;

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

    properties (SetAccess='protected')
    % Internal directories, configuration file, and QUATTRO handle properties

        % Location of QUATTRO.m on current system
        guiDir  = qt_path;

        % Location of the user's application directory
        appDir  = qt_path('appdata');

        % Location of the QUATTRO scripts directory
        scptDir = qt_path('script');

        % Location of the QUATTRO configuration file
        cfgFile = '';

        % Cahced QUATTRO handle
        hQt

    end

    properties (SetAccess='protected',Hidden=true,SetObservable=true,AbortSet=true)

        % Flag specifying the DICOM dictionary
        %
        %   "isDfltDict" is a logical flag that specifies that the current value
        %   of the "dicomDict" property is MATLAB's factory default
        isDfltDict = true;

        % Current MATLAB version
        %
        %   "matlabVer" is a stucture containing the fields for the MATLAB
        %   version, release name, and release data
        matlabVer

        % QUATTRO path cache
        %
        %   "qtPathCache" is a cell array of strings containing system directory
        %   locations of all necessary QUATTRO files
        qtPathCache

    end

    % Wrapper properties
    properties (Dependent=true)

        %Same as dwModel, but handles GE eDWI acquisitions
        edwiModel

        %Proxy for exam model # (e.g. for DCE, modelVal = dceModel)
        modelVal

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

    properties (Constant,Hidden=true)

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
            addlistener(obj,'bloodT10',      'PostSet',@updatemodels);
            addlistener(obj,'hctArt',        'PostSet',@updatemodels);
            addlistener(obj,'hctCap',        'PostSet',@updatemodels);
            addlistener(obj,'invertIr',      'PostSet',@updatemodels);
            addlistener(obj,'preEnhance',    'PostSet',@updatemodels);
            addlistener(obj,'preSteadyState','PostSet',@updatemodels);
            addlistener(obj,'r1Gd',          'PostSet',@updatemodels);
            addlistener(obj,'r2Gd',          'PostSet',@updatemodels);
            addlistener(obj,'recirc',        'PostSet',@updatemodels);
            addlistener(obj,'tissueT10',     'PostSet',@updatemodels);
            addlistener(obj,'t1Correction',  'PostSet',@updatemodels);

        end %qt_options

    end


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.edwiModel(obj)
            val = obj.dwModel;
        end %get.edwiModel

        function val = get.modelVal(obj)

            % Get the model value from the specific exam
            val = obj.([lower(obj.examType) 'Model']);

        end %get.modelVal

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

        function set.examType(obj,val)
            if obj.invldc(val)
                warning(obj.wrnid,obj.wrnc,'examType',obj.examType,val)
                return
            end

            % Set the value and dependent values
            obj.examType = lower(val);

        end %set.examType

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

        % Model selection
        function set.dscModel(obj,val)
            if obj.invldn(val) || ~any(val==1)
                warning(obj.wrnid,obj.wrnn,'dscModel',obj.dscModel);
            else
                obj.dscModel = val;
            end
        end %set.dscModel
        function set.multitiModel(obj,val)
            if obj.invldn(val) || ~any(val==1:4)
                warning(obj.wrnid,obj.wrnn,'multitiModel',obj.multitiModel);
            else
                [obj.modelVal,obj.multitiModel] = deal(val);
                if any(val==1:2)
                    obj.flipAngleMap = false;
                end
            end
        end %set.multitiModel
        function set.edwiModel(obj,val)
            if obj.invldn(val) || ~any(val==1:3)
                warning(obj.wrnid,obj.wrn,'dwModel',obj.dwModel,val);
            else
                obj.dwModel = val;
            end
        end %set.edwiModel
            

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
        function set.preEnhance(obj,val)
            if obj.invldn(val) || val<0 || isinf(val)
                warning(obj.wrnid,obj.wrnn,'preEnhance',obj.preEnhance,val)
            elseif obj.preEnhance~=val
                obj.preEnhance = val;
            end
        end %set.preEnhance
        function set.enhanceThresh(obj,val)
            if obj.invldn(val) || val<0
                warning(obj.wrnid,obj.wrnn,'enhanceThresh',obj.enhanceThresh,val)
            else
                obj.enhanceThresh = val;
            end
        end %set.enhanceThresh
        function set.preSteadyState(obj,val)
            if obj.invldn(val) || val<0 || isinf(val)
                warning(obj.wrnid,obj.wrnn,'preSteadyState',obj.preSteadyState,val)
            elseif obj.preSteadyState~=val
                obj.preSteadyState = val;
            end
        end %set.preSteadyState(obj,val)
        function set.bloodT10(obj,val)
            if obj.invldn(val) || val<0
                warning(obj.wrnid,obj.wrnn,'bloodT10',obj.bloodT10,val)
            elseif obj.bloodT10~=val
                obj.bloodT10 = val;
            end
        end %set.bloodT10
        function set.r1Gd(obj,val)
            if obj.invldn(val) || val<=0
                warning(obj.wrnid,obj.wrnn,'r1Gd',obj.r1Gd,val);
            else
                obj.r1Gd = val;
            end
        end %set.r1Gd
        function set.r2Gd(obj,val)
            if obj.invldn(val) || val<=0
                warning(obj.wrnid,obj.wrnn,'r2Gd',obj.r2Gd,val);
            else
                obj.r2Gd = val;
            end
        end %set.r2Gd
        function set.hctArt(obj,val)
            if obj.invldn(val) || val<0 || val>1
                warning(obj.wrnid,obj.wrnn,'hctArt',obj.hctArt,val);
            else
                obj.hctArt = val;
            end
        end %set.hctArt
        function set.hctCap(obj,val)
            if obj.invldn(val) || val<0 || val>1
                warning(obj.wrnid,obj.wrnn,'hctCap',obj.hctCap,val);
            else
                obj.hctCap = val;
            end
        end %set.hctCap
        function set.invertIr(obj,val)
            if isempty(val) || isnan(val) || ~any(val==0:1)
                warning(obj.wrnid,obj.wrnn,'invertIr',obj.invertIr,val);
            elseif obj.invertIr~=val
                obj.invertIr = val;
            end
        end %set.invertIr
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
        function set.recirc(obj,val)
            if obj.invldn(val) || val<0 || isinf(val)
                warning(obj.wrnid,obj.wrnn,'recirc',obj.recirc,val)
            elseif obj.preEnhance~=val
                obj.recirc = val;
            end
        end %set.recirc
        function set.tissueT10(obj,val)
            if obj.invldn(val) || val<=0
                warning(obj.wrnid,obj.wrnn,'tissueT10',obj.tissueT10,val);
            else
                obj.tissueT10 = val;
            end
        end %set.tissueT10
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
        function set.t1Correction(obj,val)
            if isempty(val) || isnan(val) || ~any(val==0:1)
                warning(obj.wrnid,obj.wrnn,'t1Correction',obj.t1Correction,val);
            elseif obj.t1Correction~=val
                obj.t1Correction = val;
            end
        end %set.t1Correction
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