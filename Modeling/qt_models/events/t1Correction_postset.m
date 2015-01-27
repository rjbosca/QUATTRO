function t1Correction_postset(src,eventdata)
%t1Correction_postset  PostSet event for the dce property "t1Correction"
%
%   t1Correction_postset(SRC,EVENT)

    % Update the y-axis label
    eventdata.AffectedObject.yLabel = '\Delta [Gd] (mM)';

    % Update using the new data
    obj.update;

end %dce.t1Correction_postset