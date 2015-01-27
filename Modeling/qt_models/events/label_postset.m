function newlabel(src,eventdata)
%newlabel  PostSet event handler for qt_models properties "xLabel" and "yLabel"
%
%   newlabel(SRC,EVENT)

    if strcmpi(src.Name,'xLabel')
    elseif strcmpi(src.Name,'yLabel')
    else
    end

end %qt_models.newlabel