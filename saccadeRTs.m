function RT = saccadeRTs(data,ind)


minRT = 20; % minimal time between traget movemet and the saccade;
maxRT = 800; % maximal time between traget movemet and the saccade;
minNorm = 4; % minimal norm of saccade

RT = nan(1,length(ind));
for t = 1:length(ind)

 
    saccadeWindowBegin = data.trials(ind(t)).movement_onset +minRT;
    saccadeWindowEnd = data.trials(ind(t)).movement_onset + maxRT;
    saccadeIsTimed = (saccadeWindowBegin < data.trials(ind(t)).beginSaccade)...
        & (saccadeWindowEnd > data.trials(ind(t)).beginSaccade);
    deltaH = data.trials(ind(t)).hPos(data.trials(ind(t)).beginSaccade)...
        - data.trials(ind(t)).hPos(data.trials(ind(t)).endSaccade);
    deltaV = data.trials(ind(t)).vPos(data.trials(ind(t)).beginSaccade)...
        - data.trials(ind(t)).vPos(data.trials(ind(t)).endSaccade);
    saccadeNormIsLarge = (vecnorm([deltaH;deltaV])>minNorm);
  
    saccInd = find (saccadeNormIsLarge & saccadeIsTimed);
    if length(saccInd)==0
        continue
    end
    RT(t) = data.trials(ind(t)).beginSaccade(saccInd(1))-data.trials(ind(t)).movement_onset;

end
