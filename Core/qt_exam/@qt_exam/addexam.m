function obj = addexam(obj,varargin)
%addexam  Adds an exam to QUATTRO
%
%   OBJ = addexam(OBJ,METHOD,NAME) adds an additional exam to a qt_exam object
%   specified by OBJ using the add method string METHOD and exam name string
%   NAME. The exam type is automatically detected, where possible, and the
%   updated qt_exam object is returned. Valid method strings are:
%
%       Method       Description
%       -----------------------
%       'import'     Imports a directory of supported image types
%
%       'loadqsave'  Loads a QUATTRO save file
%
%
%   OBJ = addexam(...,EXAMTYPE) adds an additional exam to as described
%   previously using the exam type specified by the string EXAMTYPE. This syntax
%   is often useful when a given data set's type is known to be incorrectly
%   interpreted as a 'generic' or other inappropriate exam types. Specifying
%   'auto' as the exam type is equivalent to using the previous syntax.
%
%   OBJ = addexam(...,EXAMTYPE,FILE) adds an additional exam, where the file
%   name string FILE can specify a file or directory. When using the 'import'
%   method, FILE should specify a valid directory from which to import images.
%   When loading QUATTRO save files, FILE should specify a valid file.

    % Parse inputs
    [method,examType,argsIn] = parse_inputs(varargin{:});

    % Determine the number of current exams
    nExams = numel(obj);
    if (nExams==1) && ~obj.exists.any
        nExams = 0;
    end

    % Create a new exam object to be passed to import/load
    newObj = obj;
    if nExams
        newObj = qt_exam(obj(1));
    end

    % Load new data
    switch method
        case 'import'
            newObj = qt_exam.import(newObj,argsIn{:});
        case 'loadqsave'
            newObj = qt_exam.load(newObj,argsIn{:});
    end

    % Verify data were loaded
    if isempty(newObj) || ~newObj.isvalid
        return
    end

    % Update the exam type
    if ~strcmpi(examType,'auto')
        newObj.type = examType;
    end

    % Combine the exam
    if nExams
        obj = [obj(:);newObj(:)]';
    end


    %------------------------------------------
    function varargout = parse_inputs(varargin)

        % Initial validation
        validMethods    = {'import','loadqsave'};
        validExams      = {'auto','dce','dsc','dti','dw','edwi','gsi',...
                           'multiflip','multite','multiti','multitr',...
                           'surgery','generic'};
        varargin{1}     = validatestring(varargin{1},validMethods);
        if (nargin>2)
            varargin{3} = validatestring(varargin{3},validExams);
        end

        % Parse setup
        parser = inputParser; 
        parser.addRequired('method',@ischar);
        parser.addRequired('name',@ischar);
        parser.addOptional('type','auto',@ischar);
        parser.addOptional('path','',@ischar);

        % Parse the inputs
        parser.parse(varargin{:});
        results = parser.Results;

        % Perform method specific validations on the file/path input
        if ~strcmpi(parser.Results.method,'import') && isempty(results.path)
            results.path = obj.opts.loadDir;
        end

        % Deal the outputs
        varargout = {results.method, results.type};
        if strcmpi(results.method,'import')
            varargout{end+1} = {results.name};
            if ~isempty(results.path) %qt_exam.import will error with an empty
                                      %string. So don't use this as input
                varargout{end}{2} = results.path;
            end
        else
            varargout{end+1} = {results.path};
        end

    end %parse_inputs

end %qt_exam.addexam