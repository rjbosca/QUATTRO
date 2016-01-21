function slider_Callback(hObj,~)
%slider_Callback  Callback for handling slice/series changes in QUATTRO
%
%   slider_Callback(H,EVENT) callback following changes to the slice and series
%   slider UIs.

    % Determine which slider is calling
    sliderStr = strrep(get(hObj,'Tag'),'slider_','');
    if ~any( strcmpi(sliderStr,{'slice','series'}) )
        error(['QUATTRO:' mfilename ':handleChk'],'Invalid slider handle.');
    end

    % Get the slider value value and reset it to the nearest whole number. Only
    % proceed with changing the "sliceIdx" of the current qt_exam object if a
    % slider value change has occured.
    slVal = round(get(hObj,'Value'));
    hFig  = gcbf;
    set(hObj,'Value',slVal);
    if (getappdata(hObj,'currentvalue')==slVal)
        return
    end

    % Disable controls to ensure the user doesn't interrupt
    update_controls(hFig,'disable');

    % Update the associated qt_exam object index
    obj = getappdata(hFig,'qtExamObject');
    obj.([sliderStr 'Idx']) = slVal;

    % Re-enable all UI controls and set the application data of the slider
    update_controls(hFig,'enable');

end %slider_Callback