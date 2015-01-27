function set_toolbar_color(h)

% Find toolbar object and children
hToolbar = findall(h,'Type','uitoolbar');
hTools   = get(hToolbar,'Children');


jToolbar = get(get(hToolbar,'JavaContainer'),'ComponentPeer');
jToolbar.setBackground(java.awt.Color(93/255,93/255,93/255));