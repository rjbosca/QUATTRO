function test_model(src,eventdata) %#ok<*INUSD>
%test_model  Pre-set method for the qt_response property "model"

% Try the new model on a piece of test data
try
    xP  = src.model(src.x(1,:));
    nxP = size(xP,2);
catch ME
    warning('qt_response:invalidModel','%s\n\n%s\n\n%s\n',...
            'An error occured while setting the "model" property.',...
            ME.message,'No changes were made to "model".');
    src.model = eventdata.originalValue;
    return
end

% Check the covariate index
if nxP && (nxP~=length(src.covIdx))
    src.covIdx = true(1,nxP);
end

% Check the covariate names
if nxP && (nxP~=length(src.names))
    src.names = cellfun(@(x) ['x' num2str(x)],num2cell(1:nxP),...
                                             'UniformOutput',false);
end