function smoothness = getSmoothing(h)
%GETSMOOTHING  Determines which sub-menu of Image -> Smoothing is selected

% Get the checked item (note that no error checking is performed)
checked_obj = getCheckedMenu(h);

% Store measure type
label = get(checked_obj,'Label');

% Convert string to number
smoothness = str2double(label(end-1));