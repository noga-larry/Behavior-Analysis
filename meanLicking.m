function aveLicking = meanLicking(data,params,ind)

% This function computes the average licking rate in a subset of trials in
% a session.
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
% Outputs:  aveLick      The mean licking rate

THRESHOLD = 1000;
display_time = params.time_before + params.time_after+1;

licking = nan (display_time+2*params.smoothing_margins,length(ind));
event_window = (-(params.time_before+params.smoothing_margins):...
    (params.time_after+params.smoothing_margins));

for f = 1:length(ind)
    
    switch params.align_to
        case 'cue'
            ts = data.trials(ind(f)).extended_trial_begin + data.trials(ind(f)).cue_onset + event_window;
        case 'targetMovementOnset'
            ts = data.trials(ind(f)).extended_trial_begin + data.trials(ind(f)).movement_onset + event_window
        case 'reward'
            ts = data.trials(ind(f)).rwd_time_in_extended + event_window;
    end
    
    if max(ts) > length(data.trials(ind(f)).lick) |...
        min(ts) < 1
        continue
    end
        
    licking (:,f) = data.trials(ind(f)).lick(ts)>THRESHOLD;
end

if isfield(params,'SD') & isnan(params.SD)
    aveLicking = nanmean(licking,2);
    return
end

aveLicking = raster2psth(licking,params)/1000;