function add_logo(h)
%add_logo  Adds the QUATTRO logo to a figure
%
%   add_logo(h) adds the QUATTRO logo to the figure specified by the handle h.

    warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

    javaFrame = get(h,'JavaFrame');
    fName     = which('QT Logo.png');
    fName     = strrep(fName,'\','/');
    if ~isempty(fName) && exist(fName,'file')
        javaFrame.setFigureIcon(javax.swing.ImageIcon(fName));
    end

end %add_logo