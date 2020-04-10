function boolSaccade = isTrailWIthSaccade(data,align_to, tb, te)

% This function returns a boolian vector, indicating if a trial has a
% saccade in it or not, at a time range before and after a
% trial event.
% Inputs: data                A data structer containing data on this
%                             specific cell.
%         allign_to           The trial event around which saccdes are
%                             looked for.
%         tb                  Time before the event (in ms).
%         te                  Time after the event.
% Output:  boolSaccade        boolSccade(i)==1 iff there is a saccade or
%                             blink in trial i in the specified time range.

boolSaccade = nan(1,length(data.trials));
for t=1:length(data.trials)
    switch align_to
        case 'targetMovementOnset'
            tb_in_trial = data.trials(t).movement_onset - tb;
            te_in_trial = data.trials(t).movement_onset + te;
        case 'cue'
            tb_in_trial = data.trials(t).cue_onset - tb;
            te_in_trial = data.trials(t).cue_onset + te;
    end
    
    saccade_before_range = (data.trials(t).beginSaccade <= tb_in_trial) & ...
        (data.trials(t).endSaccade >= tb_in_trial);
     saccade_begins_in_range = (data.trials(t).beginSaccade >= tb_in_trial) & ...
        (data.trials(t).beginSaccade <= te_in_trial);
    boolSaccade(t) = any(saccade_before_range | saccade_begins_in_range);
end
    
end






