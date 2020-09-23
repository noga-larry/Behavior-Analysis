function [avePupil,pupil] = meanPupilSize(data,ind,params)

LEN = params.time_before + params.time_after+1;
pupil = nan(LEN,length(ind));

for f = 1:length(ind)
    
    pupil_t = data.trials(ind(f)).pupil;
    
    pupil_t = removesSaccades(pupil_t,data.trials(ind(f)).beginSaccade,data.trials(ind(f)).endSaccade );
    pupil_t = removesSaccades(pupil_t,data.trials(ind(f)).blinkBegin,data.trials(ind(f)).blinkEnd);
    
    switch params.align_to        
        case 'cue'
            ts = data.trials(ind(f)).cue_onset + ((-params.time_before):params.time_after);
        case 'targetMovementOnset'
            ts = data.trials(ind(f)).movement_onset +((-params.time_before):params.time_after);            
    end
   
    pupil_t = pupil_t(ts);
    pupil (:,f) = pupil_t;
            
end

avePupil = nanmean(pupil,2);
avePupil = gaussSmooth(avePupil,params.SD);