function [avePupil,pupil] = meanPupilSize(data,ind,params)

LEN = params.time_before + params.time_after+1;
pupil = nan(LEN,length(ind));


switch params.align_to
    case 'cue'
        
        pupil = zeros (LEN,length(ind));
        
        for f = 1:length(ind)
            ts = data.trials(ind(f)).cue_onset + ((-params.time_before):params.time_after);
            pupil_t = data.trials(ind(f)).pupil(ts);
            pupil (:,f) = pupil_t;
        end
        
    case 'targetMovementOnset'
        for f = 1:length(ind)
            ts = data.trials(ind(f)).movement_onset +((-params.time_before):params.time_after);
            pupil_t = data.trials(ind(f)).pupil(ts);
            pupil (:,f) = pupil_t;
        end       

end

avePupil = mean(pupil,2);