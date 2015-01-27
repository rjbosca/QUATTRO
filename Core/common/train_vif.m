function [a c] = train_vif(a,c,flag,obj)
%train_vif  Trains VIF data
%
%   a = train_vif(a,c)
%
%   a = train_vif(a,c,flag) trains the VIF using only unique rows of a. In a
%   future release, the user will be able to specify a similarity measure.

% Reformat data and subtract contrast
a = cell2mat(a); tr = m_info.opts.tr; fa = m_info.opts.fa;
[b t10 r] = deal_cell( get(obj.opts,{'preEnhance','bloodT10','r1Gd'}) );
if obj.opts.t1Correction
    for i = 1:size(a,1)
        a(i,:) = si_ratio2gd(b,a(i,:),fa,tr,t10,r,true);
    end
else
    a = a-repmat( mean(a(:,1:b),2), [1 size(a,2)] );
end

% Use only unique voxel time courses
if exist('flag','var') && flag
    [a I ~] = unique(a,'rows');
    c = c(I);
end

% Determine new vector size
t = m_info.xvals; data_new = zeros(size(a,1),round(t(end)+1));
for i = 1:size(a,1)
    data_new(i,:) = interp1(t,a(i,:),0:round(t(end)));
end

% Remove data immediately before contrast arrival
t0 = floor( t(b) );
data_new(:,1:t0-1) = [];
a = data_new;