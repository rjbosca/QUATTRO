function mObj = createmodel(obj,varargin)
%createmodel  Create an exam object associated modeling object
%
%   createmodel(OBJ) attaches a modeling object to the exam object OBJ. The
%   current properties of the exam object are used to generate the modeling
%   object.
%
%   MOBJ = createmodel(OBJ) creates the modeling object based on the properties
%   of the exam object without associating the two objects.
%
%   [...] = createmodel(OBJ,'PROP1',VAL1,...) generates the modeling object as
%   described previously in addition to passing the model object property/value
%   pairs - specified by 'PROP1', etc. and VAL1, etc., respectively - to the
%   model class constrcutor

    narginchk(1,inf);

    % Create a modeling object registered with the current qt_exam object. The
    % package is imported as a coding convenience
    import([qt_models.model2str(obj.type) '.*']);
    mObj = eval( [obj.opts.([obj.type 'Model']) '(''x'',obj.modelXVals,varargin{:});'] );

    % Update additional modeling properties based on the imaging properties and
    % the current exam
    mObj = mrimagingprops.dicom2obj(mObj,obj.metaData);

    % Update additional modeling properties based on the exam options
    opts = obj.opts;
    for prop = properties(mObj)'
        if isprop(opts,prop{1})
            try
                mObj.(prop{1}) = opts.(prop{1});
            catch ME
                %FIXME: this is temporary... I was getting an error because the
                %"tIntStart" property was being stored in the QUATTRO.cfg file
                %as an empty array (or not stored). It needs to be a non-empty
                %scalar. Maybe initialize to 0?
            end
        end
    end

    % For those models that require special inputs (i.e., ROI tags), see if one
    % of the tags exists
    roiTags = fieldnames(obj.roiIdx);
    if any( cellfun(@(x) isprop(mObj,x),roiTags) )
        %FIXME: this should be more general, but I needed a quick fix
        mObj.vif = obj.calculatevif;
    end


    % At this point, if output has been requested, exit this method in lieu of
    % initializing the quantitative imaging tools
    if nargout %output the object - do not associate with the qt_exam object
        return
    end

    % Create and register an instance of the QIMTOOL
    hQim       = qimtool(mObj);
    hs         = guidata(hQim);
    obj.addmodel(mObj);
    obj.register(hQim); %ensure the GUI is destroyed with the exam object

    % Now that QIMTOOL has been created, create QUATTRO GUI specific listeners
    % and properties

    % Set the figure position so it coincides with the main QUATTRO GUI
    qtPos  = get(obj.hFig,'Position');
    qimPos = get(hQim,'Position');
    set(hQim,'Position',[qtPos(1:2) qimPos(3:4)])

    % Update the data mode pop-up menu and model pop-up menu to reflect the data
    % available from the main QUATTRO GUI. Also, prepare the the ROI selection
    % pop-up menu if data are available
    if obj.exists.rois.roi
        set(hs.popupmenu_data,'String',...
                       {'','Cur. Pixel','Cur. ROI Proj.','Cur. ROI','VOI'});
        set(hs.popupmenu_roi,'String',obj.roiNames.roi,...
                                   'Value',max([obj.roiIdx.(obj.roiTag)(1) 1]));
    else
        set(hs.popupmenu_data,'String',{'','Cur. Pixel'});
    end

    % By default, the modeling GUI is linked to QUATTRO. Add a number of qt_exam
    % property post-set listeners for updating the QIMTOOL. Update the slice and
    % series locations now
    lhs = [getappdata(hQim,'propListeners')
           addlistener(obj,'rois',     'PostSet',@qim_rois_postset)
           addlistener(obj,'sliceIdx', 'PostSet',@qim_sliceIdx_postset)
           addlistener(obj,'seriesIdx','PostSet',@qim_seriesIdx_postset)
           addlistener(obj,'roiIdx',   'PostSet',@qim_roiIdx_postset)];
    set(hs.edit_slice, 'String',num2str(obj.sliceIdx));
    set(hs.edit_series,'String',num2str(obj.seriesIdx));

    % Store the listeners in the application to data to ensure that they are
    % deleted when the GUI is terminated
    setappdata(hQim,'propListeners',lhs);

end %qt_exam.createmodel