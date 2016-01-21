function data = scriptdata(h,dataIn)
%scriptdata  Store/retrieve QUATTRO script data
%
%   scriptdata(H,DATA) stores DATA in the figure (or parent figure) of the
%   graphics object H. H can be any descendent of a figure
%
%   DATA = scriptdata(H) retrieves the QUATTRO script data from the figure (or
%   parent figure) of the graphics object H.
%
%   This function nominally performs the same operation as GUIDATA (essentially
%   a shortcut). However, QUATTRO utilizes GUIDATA to store the figure handles
%   structure for quick retrieval. To avoid bogging down the retrieval of this
%   structure, a separate application data storage is implemented by SCRIPTDATA.
%   In addition to this functionality, SCRIPTDATA also stores the data in any
%   GUIs that were linked by QUATTRO

    % Validate the inputs/outputs
    narginchk(1,2)
    if (nargin==2)
        nargoutchk(0,0);
    end

    % Validate (or get) the input handle (from a figure descendent)
    hFig = h;
    if ~strcmpi( get(hFig,'Type'), 'figure' )
        hFig = guifigure(hFig);
    end
    if isempty(hFig)
        error(['QUATTRO:' mfilename ':invalidHandle'],...
              ['The handle input, H, must be a valid figure handle or a ',...
               'figure descendent.']);
    end

    if (nargin==1)
        data = getappdata(hFig,'qtScriptData');
    else
        if isempty(dataIn) && isappdata(hFig,'qtScriptData')
            rmappdata(hFig,'qtScriptData');
        elseif ~isempty(dataIn)
            setappdata(hFig,'qtScriptData',dataIn);

            % Also store the data in any external figures
            hExt = getappdata(hFig,'linkedfigure');
            hExt = hExt(ishandle(hExt));
            if ~isempty(hExt)
                arrayfun(@(x) setappdata(x,'qtScriptData',dataIn),hExt);
            end
        end
    end

end %scriptdata