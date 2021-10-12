function [psth,counter] = lickTriggeredPsth(data,runningWindow,...
    alignTo,SD,varargin)

raster_params.align_to = 'allExtended';

p = inputParser;
defaultEpoch = 'all';
addOptional(p,'epoch',defaultEpoch);
parse(p,varargin{:})
epoch = p.Results.epoch;

psth = zeros(size(runningWindow));
counter = 0;
for t=1:length(data.trials)
    
    raster = getRaster(data, t, raster_params);
    eventTimes = trialLickEvents(alignTo,data.trials(t),epoch);
    eventTimes = eventTimes(eventTimes > runningWindow(1) & (eventTimes <...
        (length(raster)-runningWindow(end))));
           
    for i=1:length(eventTimes)
        counter = counter+1;
        psth = psth + raster(eventTimes(i)+runningWindow)';
    end
end

psth = (psth/counter)*1000;
psth = gaussSmooth(psth,SD);


