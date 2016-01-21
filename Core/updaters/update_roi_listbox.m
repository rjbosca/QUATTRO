function update_roi_listbox(hList,obj)
%update_roi_listbox  Applies conditional changes to the ROI listbox
%
%   update_roi_listbox(H) applies changes to the ROI listbox child of QUATTRO
%   specified by the handle H.
%
%   update_roi_listbox(H,OBJ) performs the same operation, but uses the QT_EXAM
%   object OBJ. This syntax will run faster as the QUATTRO figure handle and
%   exam object will not need to be found.

    % Parse and validate the input(s)
    if (nargin==1) %only the listbox handle was provided
        hFig = guifigure(hList);
        obj  = getappdata(hFig,'qtExamObject');
    end
    if ~strcmpi( get(hList,'Type'), 'uicontrol' ) ||...
            ~strcmpi( get(hList,'Style'), 'listbox' )
        error(['QUATTRO:' mfilename ':invalidObjectHandle'],...
              ['The provided handle must be a UI control with a value of ',...
               '''listbox'' for the ''Style'' property.']);
    elseif ~strcmpi( get(hList,'Tag'), 'listbox_rois' )
        warning(['QUATTRO:' mfilename ':unknownListbox'],...
                ['An unexpected signature for the listbox handle was ',...
                 'detected. The listbox should correspond to QUATTRO''s ROI ',...
                 'listbox, otherwise unanticipated results may occur.']);
    end

    % Get the exams object and various handles. Attempt to grab the requested
    % ROIs
    rois    = obj.rois.(obj.roiTag);
    isValid = any( rois(:,:).validaterois, 2 );

    % Get current listbox index and ROI names
    names       = obj.roiNames.(obj.roiTag);
    nRoi        = size(rois(isValid,:,:),1);
    vals        = obj.roiIdx.(obj.roiTag);
    vals(~vals) = []; %remove index value of 0

    % Update listbox values
    set(hList,'Max',max([2 nRoi]),'String',names,'Value',vals);

end %update_roi_listbox