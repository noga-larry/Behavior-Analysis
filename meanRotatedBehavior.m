function [Have,Vave,H,V] = meanRotatedBehavior(data,params,ind,...
    behavior_type, varargin)

CHOICE_ANGLE = 0; % the angle to which to align choice trials

data.trials = data.trials(ind);
[~,match_d] = getDirections (data);

if strcmp(behavior_type,'vel')
    flds = {'hVel','vVel'};
elseif strcmp(behavior_type,'pos')
    flds = {'hPos','vPos'};
end

for ii=1:length(data.trials)
    
    if size(match_d,2)==2
        theta = -data.trials(ii).screen_rotation + CHOICE_ANGLE;
    else
        theta = -data.trials(ii).screen_rotation - match_d(ii);
    end
    
    
    % velocity
    traceH = data.trials(ii).(flds{1});
    traceV = data.trials(ii).(flds{2});
    
    [rotatedTraceH,rotatedTraceV] = rotateEyeMovement(traceH, traceV, theta);
    data.trials(ii).(flds{1}) = rotatedTraceH;
    data.trials(ii).(flds{2}) = rotatedTraceV;
    
end

[Have,Vave,H,V] =...
    meanBehavior(data,params,1:length(data.trials),behavior_type,varargin{:});