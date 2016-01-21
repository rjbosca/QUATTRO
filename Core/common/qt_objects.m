function varargout = qt_objects(hObj)
%qt_objects  Returns all non-empty QUATTRO objects
%
%   [EXAM,MODEL,OPTS] = qt_objects(H) returns the three primary QUATTRO objects
%   (qt_exam, qt_model, and qt_opts) associated with the parent figure H, where
%   H can be the handle to any graphics object that is associated with an
%   instance of the QUATTRO application.

    % Validate the number of inputs/outputs
    narginchk(1,1);
    nargoutchk(1,3);

    % Determine which app the handle belongs to
    hFig = guifigure(hObj);
    if strcmpi( get(hFig,'Name'), qt_name ) %handle belongs to QUATTRO
        hQt = hFig;
    else %handle belongs to ancillary figure window
        hQt = getappdata(hFig,'linkedfigure');
    end

    % Deal the outputs
    exObj            = getappdata(hQt,'qtExamObject');
    varargout{1}     = exObj;
    if (nargout>1)
        warning(['QUATTRO:' mfilename ':deprecatedSyntax'],...
                ['QUATTRO no longer caches a modeling object within the ',...
                 'application data of the main GUI. This output is deprecated ',...
                 'and will be changed in a future release.']);
        %TODO: update this to create a new modeling object for the current exam
        varargout{2} = [];
    end
    if (nargout>2)
        varargout{3} = varargout{1}.opts;
    end

end %qt_objects