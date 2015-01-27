function register(obj,h)
%register  Register quantitative image modeling (QIM) GUI
%
%   register(OBJ,H) register the QIM GUI specified by the handle H to the
%   modeling object OBJ. The latter must be one of the qt_models' sub-classes.

    % Validate the input
    if (numel(h)~=1)
        error(['qt_models:' mfilename ':nonScalarHandle'],...
                             'qt_models.register only supports scalar inputs.');
    elseif ~ishandle(h) || ~strcmpi( get(h,'Name'), 'QUATTRO:: Modeling ::' )
        error(['qt_models:' mfilename ':invalidHandle'],...
                              'H must be a valid and supported figure handle.');
    end

    % Perform the "registration"
    obj.hFig = h;

end %qt_models.register