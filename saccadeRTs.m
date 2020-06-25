function [RT,Len,OverShoot,Vel] = saccadeRTs(data,ind)


minRT = 20; % minimal time between traget movemet and the saccade;
maxRT = 800; % maximal time between traget movemet and the saccade;
minNorm = 4; % minimal norm of saccade

RT = nan(1,length(ind));
Len = nan(1,length(ind));
OverShoot = nan(1,length(ind));
Vel = nan(1,length(ind));

[~,match_d] = getDirections(data);
for t = 1:length(ind)

 
    saccadeWindowBegin = data.trials(ind(t)).movement_onset +minRT;
    saccadeWindowEnd = data.trials(ind(t)).movement_onset + maxRT;
    saccadeIsTimed = (saccadeWindowBegin < data.trials(ind(t)).beginSaccade)...
        & (saccadeWindowEnd > data.trials(ind(t)).beginSaccade);
    deltaH = data.trials(ind(t)).hPos(data.trials(ind(t)).endSaccade)...
        - data.trials(ind(t)).hPos(data.trials(ind(t)).beginSaccade);
    deltaV = data.trials(ind(t)).vPos(data.trials(ind(t)).endSaccade)...
        - data.trials(ind(t)).vPos(data.trials(ind(t)).beginSaccade);
    saccadeNormIsLarge = (vecnorm([deltaH;deltaV])>minNorm);
  
    saccInd = find (saccadeNormIsLarge & saccadeIsTimed);
    if length(saccInd)==0
        continue
    end
    
    posChangeInTargetDirection = rotateEyeMovement(deltaH(saccInd(1)),deltaV(saccInd(1)),...
        -match_d(ind(t))-data.trials(ind(t)).screen_rotation);
    RT(t) = data.trials(ind(t)).beginSaccade(saccInd(1))-data.trials(ind(t)).movement_onset;
    Len(t) = data.trials(ind(t)).endSaccade(saccInd(1))-data.trials(ind(t)).beginSaccade(saccInd(1));
    Vel(t) = (posChangeInTargetDirection/Len(t))*1000;
    OverShoot(t) = rotateEyeMovement(data.trials(ind(t)).hPos(data.trials(ind(t)).endSaccade(saccInd(1)))...
        ,data.trials(ind(t)).vPos(data.trials(ind(t)).endSaccade(saccInd(1))),...
        -match_d(ind(t))-data.trials(ind(t)).screen_rotation);
end
