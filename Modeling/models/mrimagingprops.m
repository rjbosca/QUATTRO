classdef mrimagingprops < handle

    properties (AbortSet,SetObservable)

        % Flip angle
        %
        %   "fa" is the MR imaging flip angle in units of degrees
        fa

        % Echo time
        %
        %   "te" is the MR imaging echo time specified in units of milliseconds
        te

        % Inversion time
        %
        %   "ti" is the MR imaging inversion time specified in units of
        %   milliseconds
        ti

        % Repetition time
        %
        %   "tr" is the MR imaging repetition time in units of milliseconds
        tr

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = mrimagingprops
        end %mrimagingprops.mrimagingprops

    end


    %------------------------------- Set Methods -------------------------------
    methods

        function set.fa(obj,val)
            validateattributes(val,{'numeric'},...
                     {'scalar','finite','nonnan','positive','real','nonempty'});
            obj.fa = val;
            notify(obj,'checkCalcReady');
            notify(obj,'updateModel');
        end %mrimagingprops.set.fa

        function set.te(obj,val)
            validateattributes(val,{'numeric'},...
                     {'scalar','finite','nonnan','positive','real','nonempty'});
            obj.te = val;
            notify(obj,'checkCalcReady');
            notify(obj,'updateModel');
        end %mrimagingprops.set.te

        function set.ti(obj,val)
            validateattributes(val,{'numeric'},...
                     {'scalar','finite','nonnan','positive','real','nonempty'});
            obj.ti = val;
            notify(obj,'checkCalcReady');
            notify(obj,'updateModel');
        end %mrimagingprops.set.ti

        function set.tr(obj,val)
            validateattributes(val,{'numeric'},...
                     {'scalar','finite','nonnan','positive','real','nonempty'});
            obj.tr = val;
            notify(obj,'checkCalcReady');
            notify(obj,'updateModel');
        end %mrimagingprops.set.tr

    end %set methods


    %------------------------------ Other Methods ------------------------------
    methods (Static)

        function obj = dicom2obj(obj,hdr)
        %dicom2obj  Converts a DICOM header to an mrimagingprops object
        %
        %   OBJ = mrimagingprops.dicom2obj(S) converts the DICOM header stored
        %   in the structure S to an MRIMAGINGPROPS object OBJ
        %
        %   OBJ = mrimagingprops.dicom2obj(OBJ,S) populates the properties of
        %   the object OBJ that are common to MRIMAGINGPROPS properties using
        %   the DICOM header stored in the structure S.

            % Initialize the workspace
            if isempty(obj)
                obj = eval(mfilename);
            end

            % Apply the DICOM header
            for prop = properties(mfilename)'

                switch prop{1}
                    case 'fa'
                        str = 'FlipAngle';
                    case 'te'
                        str = 'EchoTime';
                    case 'ti'
                        str = 'InversionTime';
                    case 'tr'
                        str = 'RepetitionTime';
                    otherwise
                        continue
                end

                if isfield(hdr,str) && (hdr.(str)>0) && isprop(obj,prop{1})
                   obj.(prop{1}) = hdr.(str);
                end

            end
        end

    end

end %mrimagingprops