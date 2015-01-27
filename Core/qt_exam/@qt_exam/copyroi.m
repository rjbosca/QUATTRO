function copyroi(obj)
%copyroi  Copies the current ROI's details
%
%   copyroi(OBJ) creates a cloned copy of the current ROI (derived from the
%   qt_exam property "roi"), placing the ROI in the "roiCopy" property for
%   future use.

    roiIdx = obj.roiIdx;
    if (numel(obj.roiIdx)>1)
        roiIdx = roiIdx(1);
        warning(['qt_exam:' mfilename ':tooManyRois'],...
                ['Too many ROIs were selected.\n',...
                 '''%s'' allows only one ROI to be copied at a time.\n',...
                 'Using ROI index %d\n'],mfilename,roiIdx);
    end

    % Copy the ROI using the "clone" method of the qt_roi object. By storing the
    % qt_roi object in a new variable, in this case the "roiCopy" property, a
    % shallow copy (i.e., a reference to the original object) is created. This
    % means any modifications to that original ROI will modify the copied
    % version - an undesired functionality. Hence the clone operation
    obj.roiCopy = obj.roi.clone('tag');

end %qt_exam.copyroi