function trace = removesSaccades( trace, beginSaccade, endSaccade )
% This function replaces parts of trace where there were saccades with nans

for s = 1:length(beginSaccade)
    trace (beginSaccade(s):endSaccade(s)) = nan;
end
    


end

