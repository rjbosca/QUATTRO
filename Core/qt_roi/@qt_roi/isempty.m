function tf = isempty(obj)
%isempty  True for empty qt_roi objects
%
%   **DEPRECATED**
%
%   isempty(OBJ) returns true if the qt_roi object specified by OBJ 

warning(['qt_roi:' mfilename ':deprecatedMethod'],...
         'This method is deprecated, use "validaterois" instead');

n  = numel(obj);
if n>1
    tf = arrayfun(@(x) x.isempty,obj);
else
    tf = (n==0) || ~obj.isvalid || isempty(obj.position);
end