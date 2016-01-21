function gui_roiIdx_preset(~,eventdata)
%gui_roiIdx_preset  GUI post-set event for QT_EXAM property "roiIdx"
%
%   gui_roiIdx_preset(SRC,EVENT) clears the ROI statistics boxes before changing
%   the ROI index

    hs = guidata(eventdata.AffectedObject.hFig); %handles structure
    set([hs.text_mean
         hs.text_area
         hs.text_median
         hs.text_nan_ratio
         hs.text_stddev
         hs.text_kurtosis
         hs.text_snr],'String','');    

end %gui_roiIdx_preset