function y = restore_ir(x,y)
%restore_ir  Restores polarity of IR data
%
%   res = restore_ir(x,y) restores the polarity of IR data using the TI
%   values, x, and magnitude data, y.

% Find the value closet to zero
[y_min1 x1] = min(y);

% Take a point on either side (x+1 and x-1)
if x1==1
    return
elseif x1==length(x)
    y = -y;
    return
else
    xp1 = x(x1+1);
    xm1 = x(x1-1);
    yp1 = y(x1+1);
    ym1 = y(x1-1);
end

% Since the signal should be monotonically increasing, there are 4 cases to
% consider: (1) none inverted, (2) first pt. inverted, (3) first 2 pts.
% inverted, (4) all inverted. Calculate slope of secant through the two side
% points. The slope of this secant is the same for cases 2 and 3.
m(1) = ( yp1-ym1)/(xp1-xm1);
m(2) = ( yp1+ym1)/(xp1-xm1);
m(3) = m(2);
m(4) = (-yp1+ym1)/(xp1-xm1);
b(1) =  yp1-m(1)*xp1;
b(2) =  yp1-m(2)*xp1;
b(3) = b(2);
b(4) = -yp1-m(3)*xp1;

% Calculate the squared differences
f = @(slp,int) x(x1)*slp+int;
d(1) = ( y_min1-f(m(1),b(1)))^2;
d(2) = ( y_min1-f(m(2),b(2)))^2;
d(3) = (-y_min1-f(m(2),b(2)))^2;
d(4) = (-y_min1-f(m(3),b(3)))^2;

% Remove negative slopes from consideration
d(m<0) = inf;

% Check for convexity

% Find the slope that creates the minimum SSD
[ssd idx] = min(d); %#ok
if idx~=1
    y(1:x1+idx-3) = -y(1:x1+idx-3);
end

% Estimate derivative of magnitude signal
% d_ti = diff(y)./diff(x);
% 
% % Locate all negative slopes
% neg_ind = d_ti < 0;
% first_neg = find(neg_ind,1,'first'); % first negative index
% neg_ind = find(diff(neg_ind) == -1, 1, 'first'); %first index where d_ti switches
%                                                  %from negative to positive
% if isempty(neg_ind) && all( d_ti < 0 ) %all decreasing magnitude SI
%     y = -y;
%     return
% elseif isempty(first_neg) ||...SI slope becomes negative after increasing
%         (all( d_ti(1:first_neg-1)>0 ) && first_neg>1)
%     return
% elseif neg_ind==1
%     y(1) = -y(1);
% end
%     
% y_neg = y(1:neg_ind-1); %Removes possible errant value
% x_neg = x(1:neg_ind-1);
% 
% % Fits the remaing negative slopes to determine T1 to find the null
% fcn = @(x,xdata) multi_ti(x,xdata);
% t1_guess = x(y==min(y))/log(2);
% b = lsqcurvefit(fcn,[max(y) t1_guess 180],x_neg,-y_neg);
% null_x = log(1-cosd(b(3))) * b(2);
% 
% % Negates all y values
% y(x<null_x) = -y(x<null_x);