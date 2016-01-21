function register_helper(obj, varargin)

    %Calls function PARSE_OPTS to ensure appropriate property-value pairs are passed
    parse_opts(nargin-1, varargin);

    %Creates cell arrays OPTNAMES and OPTVALS containing the names and
    %values, respectively, from VARARGIN
    optNames = varargin(1:2:length(varargin)).';
    optVals = varargin(2:2:length(varargin)).';
    
    %Creates the INI file with the name assigned to FNAME
    fName = fullfile(obj.appDir,[obj.itkFile '.ini']);
    inifile(fName, 'new');
    
    %Creates a list LIST of properties for the object OBJ, and makes an empty
    %cell array CA of corresponding size
    list = meta.class.fromName('regopts').PropertyList;
    CA = cell(length(list) + (nargin-1)/2, 4); %(nargin-1)/2 to account for optional inputs
    
    %Fills the first column of CA (section name) with "Properties" and the
    %second (subsection name) with the empty string
    [CA{:,1}] = deal('Properties');
    [CA{:,2}] = deal('');
    
    %Creates a cell array PROPNAMES containing all property names of OBJ
    propNames = cell(length(list),1);
    [propNames{:}] = list(:).Name;
    
    %Creates a cell array PROPVALS containing all property values of OBJ
    propVals = cellfun(@(prop) obj.(prop), propNames, 'UniformOutput', false);
    
    %Add the optional property names to PROPNAMES
    propNames = [propNames;optNames];
   
    %Add the optional property values to PROPVALS
    propVals = [propVals;optVals];
    
    %Converts arrays to strings; required for the INI writer
    mask = cellfun(@(val) isnumeric(val) && numel(val) > 1, propVals);
    if sum(mask)
        propVals(mask) = {mat2str(propVals{mask})};
    end
    
    %Fills the third column of CA (property name) from PROPNAMES and the
    %fourth (property value) from PROPVALS
    [CA{:,3}] = propNames{:};
    [CA{:,4}] = propVals{:};
    
    %Writes the data from CA to the INI file
    inifile(fName, 'write', CA, 'tabbed');
end

function parse_opts(num, inputs)
%Parsing
    %Ensure an even number of optional arguments is input
    if mod(num,2) ~= 0
        disp('Improper number of inputs. Must be property-value pairs.');
        throw(MException('', 'Improper number of inputs. Must be property-value pairs.'));
    end
    
    %Ensure inputs are either strings or numeric
    cellfun(@(input) validateattributes(input, {'numeric', 'char'}, {'nonempty'}), inputs, 'UniformOutput', false);
end