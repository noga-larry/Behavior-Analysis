function eventTimes = trialLickEvents(alignTo,trial,epoch)    
  
THRESHOLD = 5000;
MIN_DIST_BETWEEN_LICKS = 200;

if ~exist('epoch','var')
    epoch = 'full';
end
lick = trial.lick>THRESHOLD;

    switch alignTo
        case 'onset'
            eventOnsets = diff(lick)==1;
        case 'offset'
            eventOnsets = diff(lick)==-1;
    end
    
    eventTimes = find(eventOnsets);
    
    duplicates = find(diff(eventTimes)<MIN_DIST_BETWEEN_LICKS)+1;
    eventTimes(duplicates) = [];
    switch epoch
        case 'full'
            % No need to do anything
        case 'cue'
            cueTime = trial.extended_trial_begin +trial.cue_onset;
            motionTime = trial.extended_trial_begin +...
                trial.movement_onset;
            eventTimes = eventTimes(eventTimes>cueTime ...
                & eventTimes<motionTime);  
            
        case 'targetMovementOset'
            motionTime = trial.extended_trial_begin +...
                trial.movement_onset;
            rewardTime = trial.rwd_time_in_extended;
            eventTimes = eventTimes(eventTimes>motionTime...
                & eventTimes<rewardTime);
            
        case 'reward'
            rewardTime = trial.rwd_time_in_extended;         
            trial.movement_onset;
            eventTimes = eventTimes(eventTimes>rewardTime); 
    end