 function varargout = qmaptool(varargin)
%qmaptool  Creates a figure allowing visualization of parametric maps
%
%   H = qmaptool(I,M) provides a stand-alone GUI for visualizing a true color
%   grayscale image (I) with an indexed color overlay (M). I and M can be
%   indexed images (i.e. m-by-n) or qt_image objects. NaNs values will be
%   interpreted as completely transparent when dispaying the overlay.
%
%   By default, the HSV colormap is used, but can be changed using the on-image
%   context images. The overlay can also be windowed/leveled using by pressing
%   and holding the MMB or shift+LMB.
%
%   qmaptool(OBJ) creates an interactive GUI associated with the current
%   instance of QUATTRO's qt_exam object (or a stand-alone object) specified by
%   OBJ. Because the figures are linked by the QUATTRO figure handle the qt_exam
%   object need only to represent part of the current workspace (i.e. just one
%   object is needed, not the array of objects). 
%
%       ~Note: once the true color gray scale image has been displayed, only 
%              re-creating the GUI will allow access to changing the window and
%              level. This will likely change in a future release.
%
%   See also QUATTRO

    % Parse inputs
    [img,map,obj] = input_parser(varargin{:});
    isExamObj     = ~isempty(obj);
    isStandAlone  = isempty(obj) || isempty(obj.hFig) || ~ishandle(obj.hFig);

    % Validate that the image and map are the same size
    %TODO: update the code to accept images/maps of different size. This could
    %easily be handled if the phsyical image dimensions were available.
    if any( img.imageSize~=map.imageSize )
        error(['QUATTRO:' mfilename ':incommensurateImages'],...
               'The image and overlay must be the same size.');
    end

    % Verify input and prepare figure properties
    figPos = [520 100 542 582];
    figName = 'QUATTRO-Maps';
    if ~isStandAlone
        % Determine new figure position and overwrite with the QUATTRO x/y position.
        % This ensures that the map window will always appear on top of QUATTRO.
        qtPos       = get(obj.hFig,'Position');
        figPos(1:2) = qtPos(1:2);

        % Set figure name
        s       = map.tag;
        figName = sprintf('%s (%s)',figName,s);
    end

    % Color set up
    bkg = [93 93 93]/255;

    % Prepare main figure
    hFig = figure('CloseRequestFcn',    @close_request_Callback,...
                  'Color',               bkg,...
                  'Filename',            mfilename,...
                  'IntegerHandle',      'off',...
                  'MenuBar',            'None',...
                  'Name',                figName,...
                  'NumberTitle',        'off',...
                  'Position',            figPos,...
                  'Tag',                'figure_main',...
                  'Toolbar',            'figure',...
                  'Units',              'Pixels');
         set(hFig,'defaultuicontrolunits',          'normalized',...
                  'defaultuicontrolbackgroundcolor', bkg,...
                  'defaultuicontrolfontsize',        12,...
                  'defaultaxescolor',                bkg,...
                  'defaultaxesunits',               'normalized');
    add_logo(hFig);

    % Prepare the toolbar
    dataCursorCB = @data_cursor_Callback;
    if isStandAlone
        dataCursorCB = @qmap_data_cursor_Callback;
    end
    hTools = findall( findall(hFig,'Type','uitoolbar') );
    delete(hTools([2:4 6 7 9 13 14:17])); hTools([2:4 6 7 9 13 14:end]) = [];
    for hTool = hTools(:)'
        switch get(hTool,'Tag')
            case 'Exploration.DataCursor'
                set(hTool,'ClickedCallback',dataCursorCB,...
                          'Tag','uitoggletool_data_cursor');
            case 'Exploration.Pan'
                set(hTool,'ClickedCallback',@pan_Callback,...
                          'Tag','uitoggletool_drag');
            case 'Exploration.ZoomIn'
                set(hTool,'ClickedCallback',@zoom_Callback,...
                          'Tag','uitoggletool_zoom_in');
            case 'Exploration.ZoomOut'
                set(hTool,'ClickedCallback',@zoom_Callback,...
                          'Tag','uitoggletool_zoom_out');
            case 'Standard.SaveFigure'
                set(hTool,'ClickedCallback',@save_map_image_Callback,...
                          'Tag','uipushtool_save_data');
        end
    end

    % Prepare display
    hAx = axes('Parent',hFig,...
               'Position',[10 60 512 512]./[figPos(3:4) figPos(3:4)],...
               'Tag','axes_main',...
               'XTickLabel','',...
               'YTickLabel','');

    % Prepare tools
    uicontrol('Parent',hFig,...
              'Callback',@change_transparency,...
              'Min',1e-10,... small # prevents alpha map from becoming array of zeros
              'Position',[10 10 512 20]./[figPos(3:4) figPos(3:4)],...
              'Style','Slider',...
              'Tag','slider_transparency',...
              'Value',0.5);
    uicontrol('Parent',hFig,...
              'Callback',@limit_map_Callback,...
              'ForegroundColor',[1 1 1],...
              'Position',[10 35 100 22]./[figPos(3:4) figPos(3:4)],...
              'String','Limit to ROI',...
              'Style','checkbox',...
              'Tag','checkbox_limit_map',...
              'Value',false);
    if isStandAlone
        %TODO: do you really want to delete the UI control? Maybe just hide it?
        delete( findobj(hFig,'Tag','checkbox_limit_map') );
    end

    % Prepare text
    uicontrol('Parent',hFig,...
              'ForegroundColor',[1 1 1],...
              'Position',[216 35 100 20]./[figPos(3:4) figPos(3:4)],...
              'String','Transparency',...
              'Style','Text',...
              'Tag','text_transparency');

    % Update the qt_exam object by registering the newly created figure
    if isExamObj
        obj.register(hFig);

        % Attach some listeners to the exam object to ensure that the map is
        % updated appropriately when changes to these properties occur
        l = [addlistener(obj,'sliceIdx','PostSet',@qtexam_sliceIdx_postset)];

        % Cache the externally created listeners to the figure's application
        % data to be deleted alongside the figure
        setappdata(hFig,'qtexam_listeners',l);
    end

    % Deal the output
    if nargout
        varargout{1} = hFig;
    end

    %TODO: when using the stand-alone capabilities, make sure to attach
    %listeners to delete the image objects when the figure is deleted.

    % Show the image object as an RBG image and the map object as an overlay
    img.show(hAx,true);
    map.show(hAx);

    % Set GUI data
    guidata(hFig,guihandles(hFig));

end %qmaptool


%-------------------------Callback Functions------------------------------------

function change_transparency(hObj,eventdata) %#ok<*INUSD>

    % Get the slider current value
    val  = get(hObj,'Value');
    hFig = guifigure(hObj);

    % Get the map object and update the transparency
    imgObj              = getappdata(hFig,'qtMapObject');
    imgObj.transparency = val;

    % For QUATTRO linked instances, also update all other maps of the same tag
    obj = getappdata(hFig,'qtExamObject');
    if ~isempty(obj) && obj.isvalid
        for slIdx = 1:numel(obj.maps)
            obj.maps(slIdx).(imgObj.tag).transparency = val;
        end
    end
    

end %change_transparency

function close_request_Callback(hObj,eventdata)

    % Determine if the stand-alone or QUATTRO functionality is being used. For
    % the former, the image objects must be destroyed otherwise those objects
    % won't be deleted (QUATTRO usually handles this).
    hQt = getappdata(hObj,'linkedfigure');
    if isempty(hQt) || ~ishandle(hQt)
        % Destroy the image and map objects for the figure. See the note in
        % imgview_hAxes_postset regarding extensibility
        delete( getappdata(hObj,'qtImgObject') );
        delete( getappdata(hObj,'qtMapObject') );
    end

    % Delete the listeners
    delete( getappdata(hObj,'qtexam_listeners') );

    % Delete the figure 
    delete(hObj);

end %close_request_Callback

function limit_map_Callback(hObj,eventdata)

    % Get object and refine map
    obj = getappdata(hQt,'qtExamObject');
    obj.show('maps','rois');

end %limit_map_Callback


%----------------------------------Input Parser---------------------------------
function varargout = input_parser(varargin)

    % Validate the number of inputs
    narginchk(1,2);

    % Create an input parser
    parser = inputParser;
    if (nargin==1)
        % Add the parser input
        parser.addRequired('obj',@(x) x.isvalid &&...
                                                strcmpi( class(x), 'qt_exam' ));
        parser.parse(varargin{1})

        %FIXME: the following is a workaround...
        obj     = parser.Results.obj;
        mapTags = fieldnames( obj.maps(obj.sliceIdx) );
        maps    = [obj.maps.(mapTags{obj.mapIdx})];
        [maps.transparency] = deal(0.5);
        [maps.color]        = deal('hsv');
        
        % Get the image and map to be sent to the input parser
        [varargin{2:3}] = deal(parser.Results.obj.image,parser.Results.obj.map);
    else
        parser.addOptional('obj',[]);
    end
    parser.addRequired('image',@imvalidator);
    parser.addRequired('map',  @imvalidator);

    % Parse the inputs
    parser.parse(varargin{:});
    results = parser.Results;

    % For the stand-alone functionality and for the ease of coding, convert
    % non-qt_image inputs to qt_image objects
    if ~strcmpi( class(results.image), 'qt_image' )
        results.image = qt_image(results.image);
    end
    if ~strcmpi( class(results.map), 'qt_image' )
        results.map   = qt_image(results.map,'color','hsv','tag','overlay');
    end

    % Deal the outputs
    varargout = struct2cell(results);

end %input_parser

%----------------------------
function tf = imvalidator(im)

    tf = strcmpi(class(im),'qt_image') || (isnumeric(im) && (ndims(im)==2));

end %imvalidator