function varargout = filebar(h,pos)
%filebar  File bar API
%
%   HPAN = filebar(H,POS) creates a file bar (edit text box and get file push
%   button encapsulated in a UI panel). H is the handle to the parent graphics
%   object (either a figure or UI panel) and POS is the four-element position
%   vector (in units of pixels) of the file bar's UI panels. The handle to the
%   encapsulating UI panel is returned (HPAN).
%
%   [HPAN,HEDIT,HPUSH] = filebar(...) also return the handles for the edit text
%   box (HEDIT) and push button (HPUSH).
%
%
%   A note on callbacks: the user is ultimately responsible for setting the
%   callback for the push button. By default, the edit text box will validate,
%   via the callback function, that any new inputs are either a valid file or
%   directory.

    % Parse the inputs
    [h,pos] = parse_inputs(h,pos);

    % Use the parent graphics object's properties
    bkgClr = get(h,'BackgroundColor');
    if strcmpi( get(h,'Type'), 'uitab' ) &&...
                               isprop( get(h,'Parent'), 'BackgroundColor' )
        %TODO: this is a workaround. Currently (R2011b), it appears that UI tabs
        %have a background color of 'none', which will cause errors in the
        %following code when programatically calculating colors using RGB
        %vectors...
        bkgClr = get( get(h,'Parent'), 'BackgroundColor' );
    end

    % Create the panel that acts as the parent for all other UI tools
    hOut(1) = uipanel('Parent',h,...
                      'BackgroundColor',bkgClr,...
                      'Tag','uipanel_filebar',...
                      'Title','File:',...
                      'Units','Pixels',...
                      'Position',pos);

    % Create the UI controls
    hOut(2) = uicontrol('Parent',             hOut(1),...
                        'BackgroundColor',    ones(1,3),...
                        'Callback',           @edit_file_Callback,...
                        'ForegroundColor',    zeros(1,3),...
                        'HorizontalAlignment','left',...
                        'String',             '',...
                        'Style',              'Edit',...
                        'Tag',                'edit_file',...
                        'Units',              'Normalized',...
                        'Position',           [1/52 3/40 11/13 25/30]);
    hOut(3) = uicontrol('Parent',             hOut(1),...
                        'BackgroundColor',    0.5*(1+bkgClr),...
                        'String',             '...',...
                        'Style',              'PushButton',...
                        'Tag',                'pushbutton_file',...
                        'Units',              'Normalized',...
                        'Position',[58/65 1/8 1/13 5/8]);

    % Initialize the edit text box's application data
    setappdata(hOut(2),'currentstring','');

    % Deal the outputs
    varargout = num2cell(hOut(1:nargout));

end %filebar


%----------------------------------
function edit_file_Callback(hObj,~)
    str = get(hObj,'String');
    if exist(str,'dir')
        setappdata(hObj,'currentstring',str)
    else
        set(hObj,'String',getappdata(hObj,'currentstring'));
    end
end %edit_file_Callback


%---------------------------------
function [h,p] = parse_inputs(h,p)

    narginchk(2,2);

    % Validate that the handle can contain a UI panel child (i.e., it's a panel,
    % tab, or figure graphics object)
    if ~any( strcmpi(get(h,'Type'), {'figure','uipanel','uitab'}) )
        error(['QUATTRO:' mfilename ':invalidParent'],...
              ['Image displays can only be created on graphics objects that ',...
               'support UI panels as children.']);
    end

    p = p(:)'; %enforce row vector
    validateattributes(p,{'numeric'},{'vector','numel',4});

end %parse_inputs