function th = vec2angle(v1,v2)
%vec2angle  Calculates the angle between two vectors
%
%   TH = vec2angle(V1,V2) calculates the angle TH between the two vectors V1 and
%   V2 using arc cosine

    % Calculate the angle between the two vectors, v1 and v2.
    th = acos( dot(v1,v2)./(sqrt(dot(v1,v1))*sqrt(dot(v2,v2))) );

end %vec2angle