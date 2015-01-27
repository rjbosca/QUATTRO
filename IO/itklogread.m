function wc = itklogread(fName)
%itklogread  Imports an ITK registration log file into a cell array

A = importdata(fName);

% Convert from degrees to radians
A.data(:,2:4)=  (pi/180)*A.data(:,2:4);

% Write to cell
wc = cell(max(A.data(:,1)),1);
for i = 1:size(A.data,1)
    wc{A.data(i,1)} = A.data(i,2:7);
end