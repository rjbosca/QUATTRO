function [wc,d] = itkiterread(fName)
%itkiterread  Imports an ITK iteration history array of transforms

fid = fopen(fName);
if fid==-1
    error('Unable to read file');
end

T = textscan(fid,'%s','Delimiter','\n'); T = T{1};
fclose(fid);

[wc,d] = parse_itk_cmd( sprintf('%s\n',T{:}) );