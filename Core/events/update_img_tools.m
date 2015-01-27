function update_img_tools(src,eventdata)
%update_img_tools  Updates the QUATTRO GUI following changes to image data
%
%   update_img_tools(SRC,EVENT) updates the 

    % Validate the event source
    if ~strcmpi(src.Name,'imgs')
        error(['QUATTRO:' mfilename ':invalidEventSrc'],...
                                     'Only "imgs" PostSet events are allowed.');
    end

    % Grab the exam object, the rois, and some handles
    obj = eventdata.AffectedObject;
    hdr = obj.metaData;
    hs  = guihandles(obj.hFig);

    % Determine if images exist
    imsExist = ~isempty(obj.imgs) && any( obj.imgs(:).isvalid );

    % Update the UI controls according to the existence of images
    if imsExist

        % Prepare patient display
        if ~isempty(hdr)
            dateStr = hdr.StudyDate;
            strInfo = {num2str(hdr.PatientID),...
                        num2str(hdr.StudyID),...
                       [dateStr(5:6) '/' dateStr(7:8) '/' dateStr(1:4)],...
                        hdr.SeriesDescription};
            str = sprintf('MRN: %s   Study: %s   Date: %s   Description: %s',...
                                                                    strInfo{:});
        else
            str = '';
        end
        set(hs.text_exam_info,'String',str,...
                              'Visible','on');

        % Update the slice/series sliders according to the size of the image
        % stack
        mIm = size(obj.imgs);
        if mIm(1)>1
            set(hs.slider_slice,'Min',1,...
                                'Max',mIm(1),...
                                'Value',obj.sliceIdx,...
                                'Visible','on',...
                                'SliderStep',[1/(mIm(1)-1) 2/(mIm(1)-1)]);
        else %only one slice exists in this stack
            set(hs.slider_slice,'Min',1,...
                                'Max',1.01,...
                                'Value',1,...
                                'Visible','off');
        end
        if mIm(2)>1
            set(hs.slider_series,'Min',1,...
                                 'Max',mIm(2),...
                                 'Value',obj.seriesIdx,...
                                 'Visible','on',...
                                 'SliderStep',[1/(mIm(2)-1) 2/(mIm(2)-1)]);
        else %only one series exists in this stack
            set(hs.slider_series,'Min',1,...
                                 'Max',1.01,...
                                 'Value',1,...
                                 'Visible','off');
        end
        set(hs.axes_main,'Visible','on',...
                         'XTick',[],...
                         'YTick',[]);

        % Update the exams pop-up menu
        set(hs.popupmenu_exams,'Visible','on');

        % Make the the exams and ROI panels visible
        set([hs.uipanel_exams
             hs.uipanel_roi_tools],'Visible','on');

    else %images do not exist
        set([hs.uipanel_exams
             hs.uipanel_roi_tools
             hs.slider_series
             hs.slider_slice
             hs.axes_main],'Visible','off');
    end

end %update_img_tools