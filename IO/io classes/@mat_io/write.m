function write(obj,varargin)
%write  Writes data to the mat_io object's MAT-file
%
%   write(OBJ) stores the caller's workspace as a MAT-file according to the
%   current properties of the mat_io object, OBJ.
%
%   write(OBJ,VARNAME1,VARNAME2,...) stores only the specified variables from
%   the caller's workspace.
%
%   write(OBJ,'-struct',STRUCTNAME,FIELDS) stores the fields of the specified
%   structure from the caller's workspace with name STRUCTNAME. The optional
%   input FIELDS specifies which fields of hte structure should be saved.
%
%   For more information about writing MAT-files, see the SAVE documentation

    % Create the string to be evaluated in the caller
    %TODO: all inputs should be strings, maybe verify this...
    saveStr = sprintf(['save(' repmat('''%s'',',[1 nargin])],obj.file,varargin{:});
    saveStr = [saveStr(1:end-1) ');']; %remove extra comma and close expression

    % Just pass the arguments to the SAVE function and evaluate in the caller's
    % workspace
    evalin('caller',saveStr);

end %mat_io.write