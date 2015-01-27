function newposition_Callback(obj,pos)
%newposition_Callback  New position listener for ROI objects
%
%   newposition_Callback(OBJ,POS) is used as a listener for new ROI object
%   positions using the addNewPositionCallback functionality of MATLAB ROI
%   objects

    % Update the scaled position qt_roi object property
    obj.roiObj.scaledPosition = pos;

end %roview.newposition_Callback