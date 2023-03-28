function [rate,mat] = eventRate(data,eventFeild,alignTo,ind,eventWindow,SD) 

alignmentTimes = alignmentTimesFactory(data,ind,alignTo);

mat = nan(length(ind),length(eventWindow));

for t=1:length(ind)
    eventTimes = data.trials(ind(t)).(eventFeild);
    mat(t,:) = times2Binary(eventTimes,alignmentTimes(t),eventWindow);
end

if ~isempty(SD)
    params.SD=SD;
    params.smoothing_margins = 0;
    rate=raster2psth(mat',params);
else
    rate = mean(mat,1);
end