function [Have,Vave,hPos,vPos] = meanPositions(data,params,ind,varargin)

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


p = inputParser;
defaultSmoothIndividualTrials = false;
defaultAlignTo = 'targetMovementOnset';
defaultRemoveSaccades = true; % remove saccades and blinks

addOptional(p,'smoothIndividualTrials',defaultSmoothIndividualTrials,@islogical);
addOptional(p,'alignTo',defaultAlignTo,@ischar);
addOptional(p,'removeSaccades',defaultRemoveSaccades,@islogical);

parse(p,varargin{:});
smoothIndividualTrials = p.Results.smoothIndividualTrials;
alignTo = p.Results.alignTo;
removeSaccades = p.Results.removeSaccades;

% preallocate:
window = -(params.time_before+params.smoothing_margins):...
    (params.time_after+params.smoothing_margins);
vPos = nan(length(ind),length(window));
hPos = nan(length(ind),length(window));

for ii=1:length(ind)
    
    vPos_raw = data.trials(ind(ii)).vPos;
    hPos_raw = data.trials(ind(ii)).hPos;

    if removeSaccades
        vPos_raw = removesSaccades(vPos_raw,data.trials(ind(ii)).beginSaccade,data.trials(ind(ii)).endSaccade );
        hPos_raw = removesSaccades(hPos_raw,data.trials(ind(ii)).beginSaccade,data.trials(ind(ii)).endSaccade );
        vPos_raw = removesSaccades(vPos_raw,data.trials(ind(ii)).blinkBegin,data.trials(ind(ii)).blinkEnd);
        hPos_raw = removesSaccades(hPos_raw,data.trials(ind(ii)).blinkBegin,data.trials(ind(ii)).blinkEnd);
    end
    
    switch alignTo
        case 'targetMovementOnset'
            ts = data.trials(ind(ii)).movement_onset+window;
        case 'cue'
            ts = data.trials(ind(ii)).cue_onset+window;
    end
    
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

if smoothIndividualTrials
    for ii=1:size(hPos,1)
        
        hPos(ii,:) = gaussSmooth(hPos(ii,:),params.SD);
        vPos(ii,:) = gaussSmooth(vPos(ii,:),params.SD);
        
    end
end

vPos = vPos(:,ts);
hPos = hPos(:,ts);



