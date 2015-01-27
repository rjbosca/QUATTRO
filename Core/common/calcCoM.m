function com = calcCoM(im)
%CALCCOM  Calculates the center of mass of a binary image

% Summation of all pixels (i.e. total mass)
mass = sum( im(:) );

% Finds the positions of non-zero pixels
[x y z] = deal(0);
for ii = 1:size(im,3)
    [yi xi] = find( squeeze(im(:,:,ii)) ~= 0 );
    zi = ii*sum( sum( squeeze(im(:,:,ii)) ) );
    x = sum([x;xi]); y = sum([y;yi]); z = sum([z;zi]);
end

% Calculates the first moment (center of mass)
if ndims(im)==3
    com = [sum(x) sum(y) sum(z)] / mass;
else
    com = [sum(x) sum(y)] / mass;
end