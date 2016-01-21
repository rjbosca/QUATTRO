function update_roi_stats(~,eventdata,hFig)
%update_roi_stats  Updater for qt_roi "imgVals" post set event
%
%   update_roi_stats(SRC,EVENT,H) calculates and updates the ROI statistics
%   display (mean, median, standard deviation, kurtosis, area, and NaN ratio)
%   and ROI SNR of the QUATTRO GUI specified by the handle H using the currently
%   selected ROI information. All statistics are trimmed according to the
%   settings under the menus "Analysis" -> "Trim Stats"

    %TODO: since multiple ROIs can exist, this code will need to be updated in
    %the following way: grab the ROI objects from qt_exams (obj.roi) create a
    %singlular mask from all ROIs that are not the object affected by this
    %event, combine all values, and calculate stats.

    % Get the ROI object and associated figure handle
    obj  = eventdata.AffectedObject;
    if isempty(hFig) || ~strcmpi( get(hFig,'Name'), qt_name )
        return
    end

    % Get the handles and image values. If a single ROI is selected, simply grab
    % the value of the "roiStats" property. When multiple ROIs are selected,
    % qt_roi does not handle the interaction and the "getroivals" method of the
    % qt_exam object must be used instead
    hs = guihandles(hFig);
    s  = []; %initialize
    if (numel(obj)==1) && isempty(obj.roiStats)
        %TODO: I'm not sure that this case needs to be here. I noticed that
        %while using the "Go To" ROI menu, if the ROI indexed was changed while
        %no ROI was present at the current location and if the modeling window
        %was active, an error occured because the "roiStats" field was empty.
        %This fixes that issue, but might not be necessary. That issue might be
        %indicative of poor program design elsewhere... 
        s   = obj.calcstats( obj.imgVals );
    elseif (numel(obj)==1)
        % Determine what to get from the stats structure
        tag = lower( getPopupMenu(hs.popupmenu_stats) );
        s   = obj.roiStats.(tag);
    elseif (numel(obj)>1)
        % Derive the image values
        vals = cellfun(@(x) x(:)',{obj.imgVals}, 'UniformOutput',false);
        vals = cell2mat(vals);

        % Calculate the stats structure
        s = qt_roi.calcstats(vals);
    end
    
    if isempty(s)
        set([hs.text_mean
             hs.text_area
             hs.text_median
             hs.text_nan_ratio
             hs.text_stddev
             hs.text_kurtosis
             hs.text_snr],'String','');
        return
    end

    % Update the SNR
    hSnr = getCheckedMenu(hs.menu_snr_calcs);
    snr  = s.mean/s.stdDev; %default single ROI computation
    if ~strcmpi( get(hSnr,'Tag'), 'menu_single_roi_snr' ) &&...
                                                       ~strcmpi(obj.tag,'noise')

        % Determine if there are any noise ROIs
        exObj = getappdata(hFig,'qtExamObject');
        if isfield(exObj.rois,'noise')
            vals = exObj.getroivals('roi',[],true,'tag','noise');
            if ~isempty(vals)
                snr = s.mean/( (2-pi/2)^-0.5 * std( double(vals) ) );
            end
        end
            
    end

    % Update the appropriate fields
    switch obj(1).tag
        case {'noise','vif'}
            set(hs.text_mean,     'String',sprintf('%4.2d',s.mean));
            set(hs.text_area,     'String',s.area);
            set(hs.text_median,   'String',sprintf('%4.2d',s.median));
            set(hs.text_stddev,   'String',sprintf('%4.2d',s.stdDev));
            set(hs.text_kurtosis, 'String',s.kurtosis);
            set([hs.text_nan_ratio hs.text_snr],'String','');
        otherwise
            set(hs.text_mean,     'String',sprintf('%4.2d',s.mean));
            set(hs.text_area,     'String',s.area);
            set(hs.text_median,   'String',sprintf('%4.2d',s.median));
            set(hs.text_nan_ratio,'String',s.nanRatio);
            set(hs.text_stddev,   'String',sprintf('%4.2d',s.stdDev));
            set(hs.text_kurtosis, 'String',s.kurtosis);
            set(hs.text_snr,      'String',snr);
    end

end %update_roi_stats