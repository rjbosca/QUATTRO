function y_postset(obj,~,~)
%y_postset  Post-set event for T1DYNAMIC class property "y"
%
%   y_postset(OBJ,SRC,EVENT)

    % Verify that the "tissueT10" property is the same size as "y". Only perform
    % this validation for non-scalar values of "tissueT10"
    mT10 = numel(obj.tissueT10);
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

end %t1dynamic.y_postset