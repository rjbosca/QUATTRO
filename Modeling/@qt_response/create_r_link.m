function create_r_link(obj,varargin)
%createRLink  Creates the script used by Rscript
%
%   create_r_link generates the script that operates the Rscript linkage using
%   the data and script files of the "rLinkFile" property. This syntax is for
%   internal usage
%
%   create_r_link(SCRIPT,DATA) generates the R-link script described previously
%   using the file name specified by SCRIPT with access to the files specified
%   by DATA

% Get file path if not specified
if nargin==1
    fName = obj.rLinkFile;
    fPath = strrep(obj.appDir,'\','/');
else
    error('This has not been programmed, yet'); %#ok
end

% Attempt to open the file
fid = fopen(fullfile(fPath,[fName 'Script.R']),'w');
if fid==-1
    error(['qt_response: ' mfilename ':invalidFile'],...
                                      'Unable to open R-link file for writing');
end

% Create the script
fprintf(fid,'# Set the requirements\n');
fprintf(fid,'require(ordinal);\n\n');
fprintf(fid,'# Load the data set\n');
fprintf(fid,'source("%s/%s.R");\n',fPath,fName);
fprintf(fid,'x <- read.table("%s/%s.dat");\n\n',fPath,fName);
fprintf(fid,'# Convert the y data into a "factor" (needed for clm) and generate the frame\n');
fprintf(fid,'y        <- factor(x[,1], levels = order); x<-x[,-1];\n');
fprintf(fid,'response <- eval(parse(text=frameStr));\n');
fprintf(fid,'rm(x,y,order,frameStr)\n\n');
fprintf(fid,'# The modeling is now ready to proceed. First, fit the null model and then\n');
fprintf(fid,'# fit the full model\n');
fprintf(fid,'fmNull <- clm(Response~1, data=response, link=linkF,\n');
fprintf(fid,'                                         control=clm.control(maxIter=1000))\n');
fprintf(fid,'fm     <- clm(modelStr, data=response, link=linkF,\n');
fprintf(fid,'                                         control=clm.control(maxIter=1000))\n\n');
fprintf(fid,'# Perform drop-one-out test\n');
fprintf(fid,'doo <- drop1(fm);\n\n');
fprintf(fid,'# Print the summary for capturing in MATLAB\n');
fprintf(fid,'summary(fm)\n');
fprintf(fid,'ncf = dim(fm$coefficients)\n\n');
fprintf(fid,'writeMat("%s/%s.mat",\n',fPath,fName);
fprintf(fid,'B      = fm$coefficients,\n');
fprintf(fid,'BNull  = fmNull$coefficients,\n');
fprintf(fid,'cv     = fm$vcov,\n');
fprintf(fid,'p      = fm$fitted.values,\n');
fprintf(fid,'pC     = predict(fm,type="class"),\n');
fprintf(fid,'pCNull = predict(fmNull,type="class"),\n');
fprintf(fid,'d1     = doo$AIC);');

fclose(fid);