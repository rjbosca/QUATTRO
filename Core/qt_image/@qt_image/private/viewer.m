function hAx = viewer(obj)
%viewer  Basic image viewer for the qt_image class
%
%   HAX = viewer(OBJ) constructs a basic image viewer for a stack (or single)
%   image objects specified by OBJ, returning the axes handle. The design of
%   this viewer is simple in nature, providing a means (sliders) of viewing 2D
%   image stacks (slice/series) with basic window width/window leveling.

    % Create a figure/axes
    hFig = figure; hAx = axes;

    % Get figure height and width in case sliders are needed
    posFig = get(hFig,'Position');
    posFig = posFig(3:4);

    % Hide the axes for the moment...
    axis(hAx,'off')

    % For multiple image objects create sliders for navigation
    m = size(obj);
    if m(1)>1 %prepare slice slider
        h(1) = uicontrol('Parent',hFig,...
                         'Max',m(1),...
                         'Min',1,...
                         'Style','Slider',...
                         'Tag','slider_slice_qt_image',...
                         'Units','Normalized',...
                         'Value',1);
        pos = [20 10 posFig(1)-40 20]./posFig([1 2 1 2]);
        set(h(1),'Position',pos,...
                 'SliderStep',[1/(m(1)-1) round(m(1)/5)/(m(1)-1)]);
    end
    if m(2)>1 %prepare time/series sldier
        h(2) = uicontrol('Parent',hFig,...
                         'Max',m(2),...
                         'Min',1,...
                         'Style','Slider',...
                         'Tag','slider_series_qt_image',...
                         'Units','Normalized',...
                         'Value',1);
        pos = [posFig(1)-35 35 20 posFig(2)-45]./posFig([1 2 1 2]);
        set(h(2),'Position',pos,...
                 'SliderStep',[1/(m(2)-1) round(m(2)/5)/(m(2)-1)]);
    end

    % Set application data so the sliders can show new images            
    if exist('h','var')
        h( ~ishandle(h) ) = []; %handles the case of m(1)==1 and m(2)>1
        for hIdx = 1:length(h)
            setappdata(h(hIdx),'imageObject',obj);
            setappdata(h(hIdx),'currentvalue',1);
        end
    end


    % Set figure title and callbacks
    [~,fName] = fileparts(obj(1).fileName{1});
    set(hFig,'Name',fName,...
             'NumberTitle','off',...
             'WindowButtonMotionFcn',@image_button_motion_fcn,...
             'WindowButtonDownFcn',  @image_button_down_fcn,...
             'WindowButtonUpFcn',    @image_button_up_fcn);

    % Get the slider objects
    hSl = findobj(hFig,'Tag','slider_slice_qt_image');
    hSe = findobj(hFig,'Tag','slider_series_qt_image');

    % Set the callbacks
    if ~isempty(hSl)
        set(hSl,'Callback',@slider_Callback);
    end
    if ~isempty(hSe)
        set(hSe,'Callback',@slider_Callback);
    end

end %viewer


function slider_Callback(hObj,eventdata) %#ok

    % Round the slider location
    val = round( get(hObj,'Value') );
    set(hObj,'Value',val);

    % Determine which slider was called and if anything should be done
    tag = get(hObj,'Tag');
    if (val==getappdata(hObj,'currentvalue'))
        return
    end

    % Get the image object and associated axis handle
    obj  = getappdata(hObj,'imageObject');
    hFig = guifigure(hObj);

    % Perform action
    if strcmpi(tag,'slider_slice_qt_image')

        % Determine if a series slider exists
        hSe   = findobj(hFig,'Tag','slider_series_qt_image');
        valSe = 1; %used if no slider exists
        valSl = val;
        if ~isempty(hSe)
            valSe = round( get(hSe,'Value') );
        end

    elseif strcmpi(tag,'slider_series_qt_image')

        % Determine if a slice slider exists
        hSl   = findobj(hFig,'Tag','slider_slice_qt_image');
        valSe = val;
        valSl = 1; %used if no slider exists
        if ~isempty(hSl)
            valSl = round( get(hSl,'Value') );
        end

    else
        error(['qt_image:' mfilename ':invalidHandle'],...
                            'Callback handle should be for a qt_image slider.');
    end

    % Show new image
    obj(valSl,valSe).show( getappdata(hFig,'qtImgObject') );

    % Update the figure title and app data
    [~,fName] = fileparts(obj(valSl,valSe).fileName{1});
    set(hFig,'Name',fName);
    setappdata(hObj,'currentvalue',val);

end %slider_Callback