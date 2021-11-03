function [direction,amplitude] = correctiveSaccadesParams(data,ind)

params.SD = 2;
params.time_before = -50;
params.time_after = 800;
params.smoothing_margins = 20;


[beginInds,endInds] = findTimes(data,params,ind);

[~,~,Vpos,Hpos] = meanPositions(data,params,ind,'smoothIndividualTrials',true,...
    'removeSaccades',false);

amplitude = nan(1,length(ind));
direction = nan(1,length(ind));

for t = 1:length(ind)
    if isnan(beginInds(t))
        continue
    end
    amplitude(t) =  sqrt((Vpos(t,beginInds(t))-Vpos(t,endInds(t)))^2 + ...        
                    (Hpos(t,beginInds(t))-Hpos(t,endInds(t)))^2);
    direction(t) = angleWithPositiveXAxis(Hpos(t,endInds(t)) - Hpos(t,beginInds(t)),....
        Vpos(t,endInds(t)) - Vpos(t,beginInds(t)));
end
    
    
end


function [beginIndVec,endIndVec] = findTimes(data,params,ind)

ACC_THRESH = 750; % deg/ms^2
MARGIN = 10; % ms
GAP_DURATION =  60; % ms
VEL_THRSHOLD = 50; % velocity threshold


[~,~,Vvel,Hvel] = meanVelocities (data,params,ind,'smoothIndividualTrials',true,...
    'removeSaccades',false);

Vacc = diff(Vvel,1,2)*1000; Hacc = diff(Hvel,1,2)*1000;
absAcc = sqrt(Vacc.^2+Hacc.^2);
accThresholdCrossings = diff(absAcc>ACC_THRESH,1,2);

absVel = sqrt(Vvel(:,2:end).^2+Hvel(:,2:end).^2);
velThresholdCrossings = diff(absVel>VEL_THRSHOLD,1,2);

beginIndVec = nan(1,length(ind));
endIndVec = nan(1,length(ind));

for t = 1:length(ind)
    indBegin = find(accThresholdCrossings(t,:)==1 | velThresholdCrossings(t,:)==1);
    indEnd = find(accThresholdCrossings(t,:)==-1 | velThresholdCrossings(t,:)==-1);   
    
    if isempty(indBegin) | isempty(indEnd) 
        continue
    end
    
    indEnd(indEnd<indBegin(1)) = [];
    indBegin(indBegin>indEnd(end)) = [];
        
    indDuplicate = find(diff(indBegin)<GAP_DURATION);
    indBegin(indDuplicate+1) =[];
    indDuplicate = find(diff(indEnd)<GAP_DURATION);
    indEnd(indDuplicate) = [];
   
    if length(indEnd)~=length(indBegin)
        indDuplicate = [];
        for i = 1:length(indBegin)-1
            if ~any(ismember(indEnd,indBegin(i):indBegin(i+1)))
                indDuplicate = [indDuplicate i];
            end            
        end
        indBegin(indDuplicate+1) =[];
        indDuplicate = [];
        for i = 1:length(indEnd)-1
            if ~any(ismember(indBegin,indEnd(i):indEnd(i+1)))
                indDuplicate = [indDuplicate i];
            end
            
        end
        indEnd(indDuplicate) =[];
    end
          
    if length(indBegin)==0 
        continue
    end
    
    % If there are still 2 saccades - take the first
    if length(indBegin)~= 1
        
        indBegin = indBegin(1);
        indEnd = indEnd(1);
    end
    
    if indBegin-MARGIN < 1 || indEnd+MARGIN> (params.time_before+params.time_after)
        continue
    end
    
    beginIndVec(t) = indBegin - MARGIN;
    endIndVec(t) = indEnd + MARGIN;
    
        cla
        ts = -params.time_before:params.time_after;
        plot(ts,Vvel(t,:)); hold on; plot(ts,Hvel(t,:))
        plot(ts(indBegin),Vvel(t,indBegin),'*k')
        plot(ts(indBegin),Hvel(t,indBegin),'*k')
        plot(ts(indEnd),Vvel(t,indEnd),'*g')
        plot(ts(indEnd),Hvel(t,indEnd),'*g')
        
end
end
