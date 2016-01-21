function isDispText_postset(~,eventdata)
%isDispText_postset  Post-set event for imgview "isDispText" property
%
%   isDispText_postset(SRC,EVENT)

    eventdata.AffectedObject.updatetext;

end %imgview.isDispText_postset