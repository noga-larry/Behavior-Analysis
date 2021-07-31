function [Have,Vave,hVel,vVel] = meanVelocitiesRotated(data,params,ind)

% This function computes the average horizontal and vertical
% velocities of a subset of trials in a session, rotated to the same angle 
% of 0 deg.In the procees it removes saccades and blinks and smoothes the
% averages using a Gaussian window.
% Inputs: data           A data structure containing trial information, as 
%                        created by get_data
%         params         A data struture that contains different parameter
%                        for behavior analysis:
%          .time_before  How much time to display before target movement
%                        (ms)
%          .time_after   How much time to display after target movement
%                        (ms)
%          .params.smoothing_margins
%                        Size of margins to prevent end effect in smoothing
%                        (ms)
%           .SD          Strandard deviation for Gaussian smoothing window 
%        ind             Indices of trials to average (should be in same 
%                        direction)
% Outputs:  Have         Average horizontal velocity
%           Vave         Average vertical velocity

CHOICE_ANGLE = -45; % the angle to which to align choice trials

data.trials = data.trials(ind);
[~,match_d] = getDirections (data);

for ii=1:length(data.trials)
    traceH = data.trials(ii).hVel;
    traceV = data.trials(ii).vVel;
    
    if size(match_d,1)==2
        theta = -data.trials(ii).screen_rotation + CHOICE_ANGLE;
    else
        theta = -data.trials(ii).screen_rotation - match_d(ii);
    end
    
    [rotatedTraceH,rotatedTraceV] = rotateEyeMovement(traceH, traceV, theta);
    data.trials(ii).hVel = rotatedTraceH;
    data.trials(ii).vVel = rotatedTraceV;
    
end

[Have,Vave,hVel,vVel] = meanVelocities(data,params,1:length(data.trials));