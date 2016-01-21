function image3d_fileName_postset(src,eventdata)
%image3d_fileName_postset  Post-set event for IMAGE3D property "fileName"
%
%   image3d_fileName_postset(SRC,EVENT)

    % Get the affected object and newly set file name
    obj = eventdata.AffectedObject;
    val = obj.fileName;

end %image3d.image3d_fileName_postset