function qtimage_transparency_postset(obj,src,eventdata)
%qtimage_transparency_postset  PostSet event for qt_image property "transparency"
%
%   qtimage_transparency_postset(OBJ,SRC,EVENT)

    % Grab the alpha data from the axis and convert the data into a mask
    alpha = get(obj.hImg,'AlphaData');
    alpha = ceil(alpha);

    % Apply the new transparency factor
    alpha = eventdata.AffectedObject.transparency*alpha;
    set(obj.hImg,'AlphaData',alpha)

end %imgview.qtimage_transparency_postset