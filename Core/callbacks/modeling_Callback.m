function modeling_Callback(~,~)
%modeling_Callback  Callback for handling QUATTRO modeling requests
%
%   modeling_Callback(H,EVENT)

    % Use the qt_exam method "createmodel" to fire the modeling platform
    obj = getappdata(gcbf,'qtExamObject');
    obj.createmodel;

end %modeling_Callback