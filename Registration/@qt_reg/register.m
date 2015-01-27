function register(obj)
%register  Performs image registration
%
%   register(OBJ) performs image registration using the properties stored in the
%   qt_reg object OBJ.

% Start the timer - let's see how long this takes
tic;

% Perform registration preparation tasks. This includes generating file names
% for the images used during registration, writing those images, and generating
% an options string to be passed to the ITK executable.
imFile1 = fullfile(obj.appDir,[obj.itkFile,'_fixed.mha']);
imFile2 = fullfile(obj.appDir,[obj.itkFile,'_moving.mha']);
hdr     = struct('NDims',obj.n,...
                 'DimSize',size(obj.imTarget),...
                 'ElementSpacing',obj.pixdim1,...
                 'ElementType','MET_SHORT');
mhawrite(obj.imTarget,imFile1,hdr);
hdr     = struct('NDims',obj.n,...
                 'DimSize',size(obj.imMoving),...
                 'ElementSpacing',obj.pixdim2,...
                 'ElementType','MET_SHORT');
mhawrite(obj.imMoving,imFile2,hdr);
imFile3 = fullfile(obj.appDir,[obj.itkFile,'_iterHistory.txt']);
imFile4 = fullfile(obj.appDir,[obj.itkFile,'_output.mha']);
optStr  = sprintf('"%s" ',imFile1,...
                          imFile2,...
                          imFile3,...
                          imFile4);
similarity = find( strcmpi(obj.metric,{'mmi','ncc','mi'}) )-1;
transform  = find( strcmpi(obj.transformation,{'rigid','affine'}) )-1;
if (obj.n==2)
    optStr = [optStr sprintf('%d ',obj.stepSizeMax,obj.stepSizeMin,transform)];
    eval(['!itkReg2D ' optStr]);
else
    optStr = [optStr sprintf('%d ',obj.stepSizeMax,...
                                   obj.stepSizeMin,...
                                   obj.nSpatialSamples,...
                                   obj.multiLevel,...
                                   obj.signalThresh,...
                                   similarity,...
                                   obj.nIterations,...
                                   transform)];
    eval(['!itkReg3D ' optStr]);
end

% Parse the ITK iteration history file
fid             = fopen(imFile3,'r');
T               = textscan(fid,'%s','Delimiter','\n');
T               = T{1};
fclose(fid);
[obj.wcHistory,obj.simHistory] = parse_itk_cmd(sprintf('%s\n',T{:}));
delete(findall(0,'Name','Reg'));

% Grab the final transformation from the iteration history file and store as the
% object transformation
obj.wc   = obj.wcHistory{end}(end,:);

% Stop the clock
obj.time = toc;

% Report registration info
fprintf('Registration Report\n');
fprintf('===================\n');
fprintf('Obj Fcn value: %f\n',obj.similarity);
s = repmat('%f, ',1,length(obj.wc)); s(end-1:end) = '\n';
fprintf(['W: ' s],obj.wc);
fprintf('Time elapsed (s): %f\n',obj.time);