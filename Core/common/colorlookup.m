function colorOut = colorlookup( colorIn )
%colorlookup  RGB name/value lookup
%
%   C = colorlookup(NAME) converts the color name specified by the string
%   NAME to the 3-elemner RGB vector. These values/names were adopted from
%   Pinnacle 8.0m.
%
%   NAME = colorlookup(C) converts the 3-elemnet RGB vector specifed by C to the
%   associated color name


if ischar( colorIn )
    colorIn = lower( strrep(colorIn,' ','') );
    switch colorIn
        case 'skyblue'
            colorOut = ([135 206 235]) / 255;
        case 'lavender'
            colorOut = ([230 230 250]) / 255;
        case 'purple'
            colorOut = ([128 0 128]) / 255;
        case 'orange'
            colorOut = ([255 165 0]) / 255;
        case 'blue'
            colorOut = ([0 0 255]) / 255;
        case 'tomato'
            colorOut = ([255 99 71]) / 255;
        case 'brown'
            colorOut = ([165 42 42]) / 255;
        case 'yellow'
            colorOut = ([255 255 0]) / 255;
        case 'green'
            colorOut = ([0 128 0]) / 255;
        case 'khaki'
            colorOut = ([240 230 140]) / 255;
        case 'forest'
            colorOut = ([34 139 34]) / 255;
        case 'lightorange'
            colorOut = ([255 128 0]) / 255;
        case 'yellowgreen'
            colorOut = ([154 205 50]) / 255;
        case 'lightblue'
            colorOut = ([173 216 230]) / 255;
        case 'teal'
            colorOut = ([0 128 128]) / 255;
        case 'aquamarine'
            colorOut = ([127 255 212]) / 255;
        case 'maroon'
            colorOut = ([128 0 0]) / 255;
        case 'red'
            colorOut = ([255 0 0]) / 255;
        case 'inverse_grey'
            colorOut = ([255 255 255]) / 255;
        case 'skin'
            % Used sandy brown
            colorOut = ([244 164 96]) / 255;
        case 'seashell'
            colorOut = ([255 245 238]) / 255;
        case 'olive'
            colorOut = ([128 128 0]) / 255;
        case 'greyscale'
            % Used light gray
            colorOut = ([211 211 211]) / 255;
        case 'slateblue'
            colorOut = ([106 90 205]) / 255;
        case 'Smart'
            % Smart is a color? What the hell?! I used white.
            colorOut = ([255 255 255]) / 255;
        case 'steelblue'
            colorOut = ([70 130 180]) / 255;
        otherwise
            errordlg( ['The color ' colorIn ' was not converted.'] );
            colorOut = colorIn;
    end
else
    colorIn = 255*colorIn;
    if all(colorIn==[135 206 235])
        colorOut = 'skyblue';
    elseif all(colorIn==[230 230 250])
            colorOut = 'lavender';
    elseif all(colorIn==[128 0 128])
            colorOut = 'purple';
    elseif all(colorIn==[255 165 0])
            colorOut = 'orange';
    elseif all(colorIn==[0 0 255])
            colorOut = 'blue';
    elseif all(colorIn==[255 99 71])
            colorOut = 'tomato';
    elseif all(colorIn==[165 42 42])
            colorOut = 'brown';
    elseif all(colorIn==[255 255 0])
            colorOut = 'yellow';
    elseif all(colorIn==[0 128 0])
            colorOut = 'green';
    elseif all(colorIn==[240 230 140])
            colorOut = 'khaki';
    elseif all(colorIn==[34 139 34])
            colorOut = 'forest';
    elseif all(colorIn==[255 128 0])
            colorOut = 'lightorange';
    elseif all(colorIn==[154 205 50])
            colorOut = 'yellowgreen';
    elseif all(colorIn==[173 216 230])
            colorOut = 'lightblue';
    elseif all(colorIn==[0 128 128])
            colorOut = 'teal';
    elseif all(colorIn==[127 255 212])
            colorOut = 'aquamarine';
    elseif all(colorIn==[128 0 0])
            colorOut = 'maroon';
    elseif all(colorIn==[255 0 0])
            colorOut = 'red';
    elseif all(colorIn==[255 255 255])
            colorOut = 'inverse_grey';
    elseif all(colorIn==[244 164 96])
            % Used sandy brown
            colorOut = 'skin';
    elseif all(colorIn==[255 245 238])
            colorOut = 'seashell';
    elseif all(colorIn==[128 128 0])
            colorOut = 'olive';
    elseif all(colorIn==[211 211 211])
            % Used light gray
            colorOut = 'greyscale';
    elseif all(colorIn==[106 90 205])
            colorOut = 'slateblue';
    elseif all(colorIn==[255 255 255]) 
            % Smart is a color? What the hell?! I used white.
            colorOut = 'Smart';
    elseif all(colorIn==[70 130 180])
            colorOut = 'steelblue';
    else
            colorOut = 'red';
    end
end