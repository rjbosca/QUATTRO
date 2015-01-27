function fa_postset(src,eventdata)
%fa_postset  PostSet event for dce "fa" property
%
%   fa_postset(SRC,EVENT)

    % Update the model if "t1Correction" is true. Otherwise, the property "tr"
    % is unused
    if eventdata.AffectedObject.t1Correction
        eventdata.AffectedObject.update;
    end

end %dce.fa_postset