function tr_postset(src,eventdata)
%tr_postset  PostSet event for dce "tr" property
%
%   tr_postset(SRC,EVENT)

    % Update the model if "t1Correction" is true. Otherwise, the property "tr"
    % is unused
    if eventdata.AffectedObject.t1Correction
        eventdata.AffectedObject.update;
    end

end %dce.tr_postset