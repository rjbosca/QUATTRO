function addroiundo(obj,varargin)
%addroiundo  Creates an ROI undo structure for the qt_exam object
%
%   addroiundo(OBJ,ROI,TYPE) creates an ROI undo structure for the qt_exam
%   object specified by OBJ, using the qt_roi object ROI and the modification
%   event specified by TYPE. TYPE is a string, either 'moved' or 'deleted'. The
%   index data (i.e. ROI index and slice/series location) is derived from the
%   index properties of the qt_exam object.

    % Parse the inputs
    if nargin==3
        [roi,roiType] = deal(varargin{:});
        nRoi          = numel(roi);
        index         = cell(nRoi,1);
        for rIdx = 1:nRoi
            index{rIdx} = {obj.roiIdx.(roi(rIdx).tag)(rIdx),...
                                                    obj.sliceIdx obj.seriesIdx};
        end
    else
        error(['qt_exam:' mfilename ':invalidInputs'],'%s\n%s\n',...
                           'Invalid input syntax.',...
                           'Type ''qt_exam.addroiundo'' for more information.');
    end

    % Validate the inputs: (1) ensure a valid ROI type, (2) ensure that the user
    % didn't pass the original ROI object
    roiType   = validatestring(roiType,{'moved','deleted'});
    isOrigRoi = arrayfun(@(x) any(obj.roi==x),roi);
    if any(isOrigRoi)
        error(['qt_exam:' mfilename ':invalidRoi'],...
              ['The input ROI is the same object as the current ROI.\n',...
               'A clone (see qt_roi.clone) was created and used instead.\n']);
    end

    % Create the undo structure to store
    undo = struct('roi',roi,'type',roiType,'index',{index});

    % Grab the current undo structure
    currentUndo = obj.roiUndo;
    if isempty(currentUndo)
        obj.roiUndo = undo;
    else
        obj.roiUndo = [currentUndo;undo];
    end

end %addroiundo