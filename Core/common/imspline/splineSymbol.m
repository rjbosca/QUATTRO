function draw_api = splineSymbol
%SplineRender  Creates renderer structure for spline ROIs.
%   DRAW_API = SplineRender creates a DRAW_API structure composed of
%   function handles to draw and update a spline ROI created by
%   IMSPLINE.

%   Created by: Ryan Bosca
%   rjbosca@mdanderson.org


% Initialize handle objects
[h_top_line,h_bottom_line,h_patch,...
 mode_invariant_obj,mode_variant_obj,all_obj,...
 show_vertices,is_closed,buttonDown,line_width] = deal([]);

% Store renderer function handles
draw_api.setColor               = @setColor;
draw_api.initialize             = @initialize;
draw_api.setVisible             = @setVisible;
draw_api.updateView             = @updateView;
draw_api.pointerManagePolygon   = @pointerManagePolygon;


    %---------------------
    function initialize(h)
    %Initialize  Creates initial properties for line and patch objects.

        % Determine the appropriate line width to use
		line_width = 72/get(0,'ScreenPixelsPerInch');

        % Store input h in function scoped variable
        h_group = h;
	
		% Store buttonDown event to be used by line and patch objects
		buttonDown = getappdata(h_group,'buttonDown');

        % Initialize patch parameters
		h_patch = patch('FaceColor', 'none',...
			'EdgeColor', 'none', ...
			'HitTest', 'on', ...
			'Parent', h_group,...
			'ButtonDown',buttonDown,...
			'Tag','patch',...
			'Visible','on');

        % Initialize bottom line 
        h_bottom_line = line('Color', 'w', ...
                                   'LineStyle', '-', ...
                                   'LineWidth', 3*line_width, ...
                                   'HitTest', 'on', ...
								   'ButtonDown',buttonDown, ...
                                   'Parent', h_group,...
                                   'Tag','bottom line',...
                                   'Visible','off');

        % Initialize top line
        h_top_line = line('LineStyle', '-', ...
                          'LineWidth', line_width, ...
                          'HitTest', 'on', ...
                          'Parent', h_group,...
						  'ButtonDown',buttonDown,...
                          'Tag','top line',...
                          'Visible','off');

    end %initialize

	%-------------------
	function setColor(c)
    %SetColor  Update color of line object

        set(h_top_line,'Color',c);

    end %setColor

    %------------------------------------------
    function setupLinePointerManagement(h_line)

        lineBehavior.enterFcn = [];
        lineBehavior.exitFcn = [];
        lineBehavior.traverseFcn = @(h_fig,pos) set(h_fig,'Pointer','fleur');

        iptSetPointerBehavior(h_line,lineBehavior)

    end %setupLinePointerManagement

    %--------------------------------------------
    function setupPatchPointerManagement(h_patch)

        patchBehavior.enterFcn = [];
        patchBehavior.exitFcn = [];
        patchBehavior.traverseFcn = @(h_fig,pos) set(h_fig,'Pointer','fleur');
        
        iptSetPointerBehavior(h_patch,patchBehavior);
        
    end

   %----------------------
    function setVisible(TF)

        all_obj = [h_bottom_line,h_top_line,h_patch];
        if TF
            set(all_obj,'Visible','on');
        else
            set(all_obj,'Visible','off');
        end
       
    end %setVisible

    %--------------------------------
    function pointerManagePolygon(TF)

        if TF

            setupPatchPointerManagement(h_patch);
            setupLinePointerManagement(h_top_line);
            setupLinePointerManagement(h_bottom_line);

        else

            iptSetPointerBehavior(h_patch,[]);
            iptSetPointerBehavior(h_top_line,[]);
            iptSetPointerBehavior(h_bottom_line,[]);

        end

    end % pointerManagePolygon
            
    %---------------------------
    function updateView(new_pos)

        set(h_patch,...
            'XData',new_pos(:,1),...
            'YData',new_pos(:,2));

        set([h_bottom_line,h_top_line],...
            'XData',new_pos(:,1),...
			'YData',new_pos(:,2));

	end %UpdateView

end