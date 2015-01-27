function vals = trim_stats(perc_trim,vals)
%trim_stats  Removes some number of pixels from a collection of measurements
%
%   A = TRIMSTATS(P,VALS) removes a percent, defined by PERC, of
%   pixels from the collection of measurements PERC

% Calculate percentiles and remove those data
pcts = prctile(vals,[perc_trim 100-perc_trim]);
vals(vals<pcts(1) | vals>pcts(2)) = [];