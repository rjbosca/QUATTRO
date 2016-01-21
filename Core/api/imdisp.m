function hOut = imdisp(h,pos,vec)
%imdisp  Image display API
%
%   HOUT = imdisp(H,POS) creates an image display in the graphics object
%   specified by the handle H at the position POS, returning a structure
%   containing the handles to the newly created graphics objects. POS is a four
%   element position vector that specifies, in pixel units, [X Y HEIGHT WIDTH],
%   where X and Y specify the position with respect to the lower left corner of
%   the parent graphics object.
%
%   HOUT = imdisp(...,VEC) creates the image display as described previously
%   only creating additional tools as specified by the numeric vector VEC. Valid
%   vector values are:
%
%       Value           Tool
%       ---------------------
%         1             Slider in the empty space between
%                       the UI panel's right edge and axis
%
%         2             Slider in the empty space between
%                       the UI panel's bottom edge and axis

    % Parse the inputs
    if (nargin<3)
        vec = 1:2;
    end
    [h,pos,vec] = parse_inputs(h,pos,vec);

    % Create the panel that acts as the parent for all other UI tools
    hPanel = uipanel('Parent',h,...
                     'BackgroundColor',[0 0 0],...
                     'BorderType','none',...
                     'Tag','uipanel_image',...
                     'Units','Pixels',...
                     'Position',pos);

    % Create the image axis
    hImAx = axes('Parent',hPanel,...
                 'Units','Normalized',...
                 'Position',[0.01 0.03 0.96 0.96],...
                 'XTick',[],...
                 'XTickLabel','',...
                 'YTick',[],...
                 'YTickLabel','',...
                 'Visible','off');

    % Create optional tools
    for toolIdx = vec
        switch toolIdx
            case 1
                uicontrol('Parent',hPanel,...
                          'Style','slider',...
                          'Units','Normalized',...
                          'Position',[0.976 0.025 0.02 0.95],...
                          'Tag','slider_side');
            case 2
                uicontrol('Parent',hPanel,...
                          'Style','slider',...
                          'Units','Normalized',...
                          'Position',[0.015 0.006 0.95 0.02],...
                          'Tag','slider_bottom');
        end
    end

    % Add the property pre- and post-set listeners
    if ~verLessThan('matlab','8.5.0')
        addlistener(hImAx,'Tag','PreSet', @axes_Tag_preset);
        addlistener(hImAx,'Tag','PostSet',@axes_Tag_postset);
    end

    % Set the image axis tag (this will fire the post-set listener)
    set(hImAx,'Tag','axes_image');

    % Create a structure of handles
    allH    = num2cell([hPanel;get(hPanel,'Children')]);
    allTags = cellfun(@(x) get(x,'Tag'),allH,'UniformOutput',false);
    hOut    = cell2struct(allH(:),allTags(:),1);
                        
end %imdisp

%---------------------------------------
function axes_Tag_postset(src,eventdata)
%axes_Tag_postset  Enforces a non-empty axis tag
%
%   axes_Tag_postset(SRC,EVENT) enforces a non-empty axis tag. This is a
%   workaround for an issue with the IMAGE function that clears any tag from the
%   axis on which an image is displayed

    % Grab the cached axis tag
    axTag = getappdata(eventdata.AffectedObject,'cachedAxisTag');

    % Determine if a change needs to be made to the property or the cache
    if isempty(eventdata.AffectedObject.(src.Name))
        eventdata.AffectedObject.(src.Name) = axTag;
    end

end %axes_Tag_postset

%---------------------------------------
function axes_Tag_preset(~,eventdata)
%axes_Tag_preset  Enforces a non-empty axis tag
%
%   axes_Tag_preset(SRC,EVENT), in conjunction with axesTag_postset, enforces a
%   non-empty axis tag. This is a workaround for an issue with the IMAGE
%   function that clears any tag from the axis on which an image is displayed

    % Update the "cachedAxisTag" application data. This will be used by the
    % post-set listener to determine how/if to update the "Tag" property
    setappdata(eventdata.AffectedObject,'cachedAxisTag',...
                                                  eventdata.AffectedObject.Tag);

end %axes_Tag_pretset

%-------------------------------------
function [h,p,v] = parse_inputs(h,p,v)

    narginchk(3,3);

    % Validate that the handle can contain a UI panel child (i.e., it's a panel
    % or figure graphics object)
    if ~any( strcmpi(get(h,'Type'), {'figure','uipanel','uitab'}) )
        error(['QUATTRO:' mfilename ':invalidParent'],...
              ['Image displays can only be created on graphics objects that ',...
               'support UI panels as children.']);
    end

    % Validate the vector
    v = v(:)'; %enforce row vector
    validateattributes(v,{'numeric'},{'row','positive','integer','<=',2});

end %parse_inputs