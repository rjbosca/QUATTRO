function flush_cache(obj,~,~)
%flush_cache  Event for flushing temporary storage
%
%   flush_cache(OBJ,SRC,EVENT) flushes the temporary image storage property of
%   the imagebase (or sub-class) object OBJ "imageRaw" when the memory saver
%   mode is active. SRC and EVENT are unused inputs required by MATLAB's event
%   syntax

    if obj.memorySaver
        obj.imageRaw = [];
    end

end %imagebase.flush_cache