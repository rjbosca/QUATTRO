function dicomDict_postset(obj,src,eventdata)
%dicomDict_postset  PostSet event for qt_options "dicomDict" property
%
%   dicomDict_postset(OBJ,SRC,EVENT) updates changes to the qt_options object
%   OBJ (specifically the "isDfltDict" property) following changes to the
%   "dicomDict" property

    % Determine the factory dictionary file
                  dicomdict('factory');
    factoryDict = dicomdict('get');
                  dicomdict('set',obj.dicomDict);

    % Update the value
    obj.isDfltDict = strcmpi(obj.dicomDict,factoryDict);

end %qt_options.dicomDict_postset