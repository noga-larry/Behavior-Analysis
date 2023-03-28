function [RT,Len,OverShoot,Vel] = saccadeRTs(data,ind,corrective)


MIN_RT = 20; % minimal time between traget movemet and the saccade;
MAX_RT = 800; % maximal time between traget movemet and the saccade;
MIN_NORM = 4; % minimal norm of saccade

if exist('corrective','var')
    MIN_RT = 130; % minimal time between traget movemet and the saccade;
    maxRT = 800; % maximal time between traget movemet and the saccade;
    MIN_NORM = 0.5;
end

RT = nan(1,length(ind));
Len = nan(1,length(ind));
OverShoot = nan(1,length(ind));
Vel = nan(1,length(ind));

[~,match_d] = getDirections(data,ind);
for t = 1:length(ind)
 
    saccadeWindowBegin = data.trials(ind(t)).movement_onset +MIN_RT;
    saccadeWindowEnd = data.trials(ind(t)).movement_onset + MAX_RT;
    saccadeIsTimed = (saccadeWindowBegin < data.trials(ind(t)).beginSaccade)...
        & (saccadeWindowEnd > data.trials(ind(t)).beginSaccade);
    deltaH = data.trials(ind(t)).hPos(data.trials(ind(t)).endSaccade)...
        - data.trials(ind(t)).hPos(data.trials(ind(t)).beginSaccade);
    deltaV = data.trials(ind(t)).vPos(data.trials(ind(t)).endSaccade)...
        - data.trials(ind(t)).vPos(data.trials(ind(t)).beginSaccade);
    saccadeNormIsLarge = (vecnorm([deltaH;deltaV])>MIN_NORM);
  
    saccInd = find (saccadeNormIsLarge & saccadeIsTimed,1);
    if length(saccInd)==0
        continue
    end
    
    posChangeInTargetDirection = rotateEyeMovement(deltaH(saccInd(1)),deltaV(saccInd(1)),...
        -match_d(t)-data.trials(ind(t)).screen_rotation);
    RT(t) = data.trials(ind(t)).beginSaccade(saccInd(1))-data.trials(ind(t)).movement_onset;
    Len(t) = data.trials(ind(t)).endSaccade(saccInd(1))-data.trials(ind(t)).beginSaccade(saccInd(1));
    Vel(t) = (posChangeInTargetDirection/Len(t))*1000;
    OverShoot(t) = rotateEyeMovement(data.trials(ind(t)).hPos(data.trials(ind(t)).endSaccade(saccInd(1)))...
        ,data.trials(ind(t)).vPos(data.trials(ind(t)).endSaccade(saccInd(1))),...
        -match_d(t)-data.trials(ind(t)).screen_rotation);
%     if ~isnan (RT(t))
%         cla
%         hold on
% 
%         plot(data.trials(ind(t)).hVel);plot(data.trials(ind(t)).vVel)
%         xline(data.trials(ind(t)).beginSaccade(saccInd));
%         xline(data.trials(ind(t)).endSaccade(saccInd));
%         xline(data.trials(ind(t)).movement_onset,'r');
%         a=5;
%     end

end
