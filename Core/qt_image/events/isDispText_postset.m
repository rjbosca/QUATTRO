function isDispText_postset(src,eventdata)
%isDispText_postset  PostSet event for imgview "isDispText" property
%
%   isDispText_postset(SRC,EVENT)

    eventdata.AffectedObject.updatetext;

end %imgview.isDispText_postset