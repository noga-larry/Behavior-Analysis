function [Have,Vave,hVel,vVel] = meanVelocities(data,params,ind, varargin)

% This function computes the average horizontal and vertical
% velocities of a subset of trials in a session. In the procees it removes 
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


p = inputParser;
defaultSmoothIndividualTrials = false;
defaultAlignTo = 'targetMovementOnset';
addOptional(p,'smoothIndividualTrials',defaultSmoothIndividualTrials,@islogical);
addOptional(p,'alignTo',defaultAlignTo,@ischar);

parse(p,varargin{:});
smoothIndividualTrials = p.Results.smoothIndividualTrials;
alignTo = p.Results.alignTo;


% preallocate:
window = -(params.time_before+params.smoothing_margins):...
    (params.time_after+params.smoothing_margins);
vVel = nan(length(ind),length(window));
hVel = nan(length(ind),length(window));
for ii=1:length(ind)
    
    vVel_raw = data.trials(ind(ii)).vVel;
    hVel_raw = data.trials(ind(ii)).hVel;
    
    vVel_raw = removesSaccades(vVel_raw,data.trials(ind(ii)).beginSaccade,data.trials(ind(ii)).endSaccade );
    hVel_raw = removesSaccades(hVel_raw,data.trials(ind(ii)).beginSaccade,data.trials(ind(ii)).endSaccade );
    vVel_raw = removesSaccades(vVel_raw,data.trials(ind(ii)).blinkBegin,data.trials(ind(ii)).blinkEnd);
    hVel_raw = removesSaccades(hVel_raw,data.trials(ind(ii)).blinkBegin,data.trials(ind(ii)).blinkEnd);
    
    switch alignTo
        case 'targetMovementOnset'
            ts = data.trials(ind(ii)).movement_onset+window;
        case 'cue'
            ts = data.trials(ind(ii)).cue_onset+window;
    end
    
    vVel_raw = vVel_raw(ts);
    hVel_raw = hVel_raw(ts);
        
    vVel(ii,:) = vVel_raw;
    hVel(ii,:) = hVel_raw;
    
    
end

Vave_raw = nanmean(vVel,1);
Have_raw = nanmean(hVel,1);

Vave_raw = gaussSmooth(Vave_raw,params.SD);
Have_raw = gaussSmooth(Have_raw,params.SD);

ts = params.smoothing_margins:(params.time_before+params.smoothing_margins+params.time_after);
Vave = Vave_raw(ts); 
Have = Have_raw(ts); 

if smoothIndividualTrials
    for ii=1:size(hVel,1)
        
        hVel(ii,:) = gaussSmooth(hVel(ii,:),params.SD);
        vVel(ii,:) = gaussSmooth(vVel(ii,:),params.SD);
        
    end
end

vVel = vVel(:,ts);
hVel = hVel(:,ts);



