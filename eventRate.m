function rate = eventRate(data,eventFeild,alignTo,ind,eventWindow) 

alignmentTimes = alignmentTimesFactory(data,ind,alignTo);

mat = nan(length(ind),length(eventWindow));

for t=1:length(ind)
    eventTimes = data.trials(ind(t)).(eventFeild);
    mat(t,:) = times2Binary(eventTimes,alignmentTimes(t),eventWindow);
end

rate=mean(mat,1)*1000;