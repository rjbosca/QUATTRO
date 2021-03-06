function save(obj)
%save  Store the current QUATTRO configuration options
%
%   save(OBJ) stores the current QUATTRO configuration of the qt_options object
%   OBJ in the file specified by the "cfgFile" property

    % Define configuration file header
    hdr = {'% QUATTRO options definition',...
           '',...
           '% NOTES: Use the ''%'' symbol for commenting in this file.',...
           '',...
           '%        These options are read by the qt_options object class using an "eval"',...
           '%        command. To edit the options, simply replace the value in this file',...
           '%        with the desired one. If assigning a string, use single quotations to',...
           '%        enclose the new value',...
           '',...
           '%        DEFINING NEW OPTIONS can be performed by modifying the qt_options.m',...
           '%        file to includ either a new public or private property. A new method',...
           '%        that validates the option can be coded, but is not necessary, using the',...
           '%        function name set.<opt name> where "opt name" is the option name',...
           '%        following the variable naming convention of MATLAB.',...
           '',...
           '%        ASSIGNING OPTION VALUES is done by placing a value (numeric or character)',...
           '%        to the right of the "=". For empty values use one of [], '', or {}',...
           '%        depending on the prefered data type.',...
           '',...
           '%        CALCULATED OPTION VALUES: certain options are created through calculations',...
           '%        performed on other options (e.g. r1Min and r1Max). Although values can',...
           '%        be set in this file, there is no guarantee that those options will be used',...
           '%        by QUATTRO.',...
           '',...
           '%        ***WARNING*** Invalid options or those for which a public or private',...
           '%        qt_options property has not been programmed will produce a warning',...
           '%        and will be ignored after qt_options instatiation. Moreover, setting',...
           '%        improper values may result in unanticipated results.'};

    % Open config file for writing
    fid = fopen(obj.cfgFile,'w');
    if (fid==-1)
        warning(['QUATTRO:' mfilename ':writeError'],...
                       'Unable to write QUATTRO options to %s\n','QUATTRO.cfg');
        return
    end

    % Get option names, removing temporary and dependent properties
    optsObj   = ?qt_options;
    optsProps = optsObj.PropertyList( ~[optsObj.PropertyList.Transient] &...
                                      ~[optsObj.PropertyList.Dependent] &...
                                      ~[optsObj.PropertyList.Constant]);
    opts      = sort({optsProps.Name});

    % Write new configuration file
    cellfun(@(x) fprintf(fid,'%s\n',x),hdr); fprintf(fid,'\n\n');
    for opt = opts

        % Grab the value - there is no need to write the option if it has no
        % value...
        val = obj.(opt{1});
        if isempty(val)
            continue
        end

        if isnumeric(val)
            nVal = numel(val);
            %TODO: what if there is an option that contains a matrix?
            if (nVal==1) %scalar
                fprintf(fid,'%s = %f\n',opt{1},val);
            elseif (nVal>1) %vector
                fprintf(fid,['%s = [' repmat('%f ',[1 nVal-1]) '%f]\n'],...
                                                                    opt{1},val);
            end
        elseif islogical(val)
            fprintf(fid,'%s = %d\n',opt{1},val);
        elseif isstruct(val)
            data  = [fieldnames(val) struct2cell(val)]';
            nData = numel(data);
            fprintf(fid,['%s = struct(' repmat('''%s'',',[1 nData-1]) '''%s'');\n'],...
                opt{1},data{:});
        elseif ischar(val)
            fprintf(fid,'%s = ''%s''\n',opt{1},val);
        end
    end

end %qt_options.save