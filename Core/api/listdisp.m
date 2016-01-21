function varargout = listdisp(h,pos)
%listdisp  List push display API
%
%   HLIST = listdisp(H,POS) creates a listbox push-style display (i.e., setting
%   the "String" property appends the new value instead of overwritting). H is
%   the handle to the parent graphics object (either a figure, UI panel, or UI
%   tab) and POS is the four-element position vector (in pixels). The handle to
%   the listbox is returned

    % Parse the inputs
    [h,pos] = parse_inputs(h,pos);

    % Use the parent graphics object's properties
    switch get(h,'Type')
        case 'figure'
            bkgClr = get(h,'Color');
        case 'uitab'
            bkgClr = get( get(h,'Parent'), 'BackgroundColor' );
        otherwise
            bkgClr = get(h,'BackgroundColor');
    end

    % Create the encapsulating UI panel that acts as the parent for all other UI
    % tools
    hUip = uipanel('Parent',h,...
                   'BackgroundColor',bkgClr,...
                   'Tag','uipanel_listdisp',...
                   'Units','Pixels',...
                   'Position',pos);

    % Create the UI controls. (1) hidden listbox that acts as a proxy, (2)
    % visible listbox that displays the information
    hOut =  uicontrol('Parent',hUip,...
                      'BackgroundColor',ones(1,3),...
                      'ForegroundColor',zeros(1,3),...
                      'HandleVisibility','off',...
                      'HorizontalAlignment','left',...
                      'String',{''},...
                      'Tag','listbox_listdisp',...
                      'Position',[0 0 pos(3:4)]);
    hHide = uicontrol('Parent',hUip,...
                      'Tag','listbox_hidden_listdisp',...
                      'Position',[-2 -2 1 1]);

    % Setup the "String" post-set listener that will forward the new strings to
    % the viewable listbox

end %listdisp

%-----------------------------------
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