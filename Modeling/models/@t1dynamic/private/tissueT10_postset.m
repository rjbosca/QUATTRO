function tissueT10_postset(obj,~,~)
%tissueT10_postset  Post-set event for T1DYNAMIC class property "tissueT10"
%
%   tissueT10_postset(OBJ,SRC,EVENT) performs validation of the "tissueT10"
%   property with respect to the "y" property of the T1DYNAMIC (or sub-classed)
%   object OBJ. Specifically, this post-set listener is used to ensure that the
%   maps specified in both properties are the same size. SRC and EVENT are the
%   source and event object's provided by the event; these inputs are unused.

    % Validate non-scalar values of the "tissueT10" property
    mT10 = size(obj.tissueT10);
    mY   = size(obj.y);
    if any(mT10>1) && any(mY) &&...
                          ( (numel(mT10)~=numel(mY)-1) || any(mT10~=mY(2:end)) )

        % Determine (programatically) the default value for "tissueT10"
        metaObj    = ?t1dynamicopts;
        defaultT10 = metaObj.PropertyList(...
                             strcmpi({metaObj.PropertyList.Name},'tissueT10') );
        defaultT10 = defaultT10.DefaultValue;

        % Display two different warnings for clarity
        if (prod(mY(2:end))==1)
            warning(['t1dynamic:' mfilename ':T10MapandSingleY'],...
                    ['Tissue T10 maps are not supported for single y data ',...
                     'computations. The "tissueT10" property has been reset ',...
                     'to the default value of: %5.0f ms'],defaultT10);
        else
            warning(['t1dynamic:' mfilename ':incommensurateT10andY'],...
                    ['Maps specified in the "tissueT10" property must contain ',...
                     'the same number of elements as the map specified in the ',...
                     '"y" (i.e., the number of elements of the T10 map should ',...
                     'match the number of elements of the second and higher ',...
                     'dimensions of y). The "tissueT10" property has been ',...
                     'reset to the default value of: %5.0f ms'],defaultT10);
        end

        % Reset the value of "tissueT10"
        obj.tissueT10 = defaultT10;

    end

end %t1dynamic.tissueT10_postset