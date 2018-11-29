function [Have,Vave] = meanVelocitys(data,params,ind);

% This function recieves computes the average horizontal and vertical
% velocities of a sunset of trials in a session.
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

window = -(params.time_before+params.smoothing_margins):...
    (params.time_after+params.smoothing_margins);
for ii=1:length(ind)
    ts = data.trials(ind(ii)).movement_onset+window;
    vVel_raw = data.trials(ind(ii)).vVel(ts);
    hVel_raw = data.trials(ind(ii)).hVel(ts);
    
    vVel_raw
    
    
    vVel(ii,:) = data.trials(ind(ii)).vVel(ts);
    hVel(ii,:) = data.trials(ind(ii)).hVel(ts);
    
    
end
