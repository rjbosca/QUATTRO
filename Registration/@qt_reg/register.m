function register(obj)
%register  Performs image registration
%
%   register(OBJ) performs image registration using the properties stored in the
%   qt_reg object OBJ.

    % Start the timer - let's see how long this takes
    tic;

    % Perform registration preparation tasks. This includes generating file
    % names for the images used during registration, writing those images, and
    % generating an options string to be passed to the ITK executable
    imFixedFile  = fullfile(obj.appDir,[obj.itkFile,'_fixed.mha']);
    hdr          = struct('NDims',obj.n,...
                          'DimSize',size(obj.imTarget),...
                          'ElementSpacing',obj.pixdimTarget,...
                          'ElementType','MET_FLOAT');
    mhawrite(obj.imTarget,imFixedFile,hdr);
    imMovingFile = fullfile(obj.appDir,[obj.itkFile,'_moving.mha']);
    hdr          = struct('NDims',obj.n,...
                          'DimSize',size(obj.imMoving),...
                          'ElementSpacing',obj.pixdimMoving,...
                          'ElementType','MET_FLOAT');
    mhawrite(obj.imMoving,imMovingFile,hdr);
    iterHistFile = fullfile(obj.appDir,[obj.itkFile,'_iterHistory.txt']);

    % Create the INI file
    obj.register_helper('imFixedFile',imFixedFile,...
                        'imMovingFile',imMovingFile,...
                        'iterHistFile',iterHistFile);

%TODO: this is old code. Remove after testing "register_helper"
% imFile4 = fullfile(obj.appDir,[obj.itkFile,'_output.mha']);
%     optStr  = sprintf('"%s" ',imFixedFile,...
%                               imMovingFile,...
%                               iterHistFile);
% 
%     % Determine the similarity and transformation option numbers. The "-1"
%     % accounts for the zero indexing of C++
%     similarity = find( strcmpi(obj.metric,{'MeanSquares',...
%                                            'GradientDifference',...
%                                            'MutualInformation',...
%                                            'NormalizedCrossCorrelation',...
%                                            'MattesMutualInformation',...
%                                            'MutualInformationHistogram',...
%                                            'NormalizedMutualInformationHistogram'}) )-1;
%     transform  = find( strcmpi(obj.transformation,{'rigid','affine'}) )-1;
% 
%     % Generate the string that will be evaluate and run the registration code
%     optStr = [sprintf('%d ',obj.n) optStr,...
%               sprintf('%d ',obj.stepSizeMax,...
%                             obj.stepSizeMin,...
%                             obj.nSpatialSamples,...
%                             obj.multiLevel,...
%                             obj.signalThresh,...
%                             similarity,...
%                             obj.nIterations,...
%                             transform)];

    exeFile = which('itkReg.exe');
    eval(['!"' exeFile '" ' optStr]);

    % Parse the ITK iteration history file
    fid             = fopen(iterHistFile,'r');
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

end %qt_reg.register