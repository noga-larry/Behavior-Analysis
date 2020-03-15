function [Have,Vave,hPos,vPos] = meanPositions(data,params,ind)

% This function computes the average horizontal and vertical
% Positions of a subset of trials in a session. In the procees it removes 
% saccades and blinks and smoothes the averages using a Gaussian window.
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

% preallocate:
window = -(params.time_before+params.smoothing_margins):...
    (params.time_after+params.smoothing_margins);
vPos = nan(length(ind),length(window));
hPos = nan(length(ind),length(window));
for ii=1:length(ind)
    
    vPos_raw = data.trials(ind(ii)).vPos;
    hPos_raw = data.trials(ind(ii)).hPos;

    
    vPos_raw = removesSaccades(vPos_raw,data.trials(ind(ii)).beginSaccade,data.trials(ind(ii)).endSaccade );
    hPos_raw = removesSaccades(hPos_raw,data.trials(ind(ii)).beginSaccade,data.trials(ind(ii)).endSaccade );
    vPos_raw = removesSaccades(vPos_raw,data.trials(ind(ii)).blinkBegin,data.trials(ind(ii)).blinkEnd);
    hPos_raw = removesSaccades(hPos_raw,data.trials(ind(ii)).blinkBegin,data.trials(ind(ii)).blinkEnd);
    
    ts = data.trials(ind(ii)).movement_onset+window;
    vPos_raw = vPos_raw(ts);
    hPos_raw = hPos_raw(ts);
        
    vPos(ii,:) = vPos_raw;
    hPos(ii,:) = hPos_raw;
    
    
end

Vave_raw = nanmean(vPos,1);
Have_raw = nanmean(hPos,1);

Vave_raw = gaussSmooth(Vave_raw,params.SD);
Have_raw = gaussSmooth(Have_raw,params.SD);

ts = params.smoothing_margins:(params.time_before+params.smoothing_margins+params.time_after);
Vave = Vave_raw(ts); 
Have = Have_raw(ts); 

vPos = vPos(:,ts);
hPos = hPos(:,ts);



