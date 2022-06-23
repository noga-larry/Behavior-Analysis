function [Have,Vave,H,V] = meanBehavior(data,params,ind,behavior_type,varargin)



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


if strcmp(behavior_type,'vel')
    flds = {'hVel','vVel'};
elseif strcmp(behavior_type,'pos')
    flds = {'hPos','vPos'};
end

% preallocate:
window = -(params.time_before+params.smoothing_margins):...
    (params.time_after+params.smoothing_margins);
V = nan(length(ind),length(window));
H = nan(length(ind),length(window));

alignmentTimes = alignmentTimesFactory(data,ind,alignTo);

for ii=1:length(ind)
    
    h_raw = data.trials(ind(ii)).(flds{1});
    v_raw = data.trials(ind(ii)).(flds{2});
    
    if removeSaccades
        v_raw = removesSaccades(v_raw,data.trials(ind(ii)).beginSaccade,data.trials(ind(ii)).endSaccade );
        h_raw = removesSaccades(h_raw,data.trials(ind(ii)).beginSaccade,data.trials(ind(ii)).endSaccade );
        v_raw = removesSaccades(v_raw,data.trials(ind(ii)).blinkBegin,data.trials(ind(ii)).blinkEnd);
        h_raw = removesSaccades(h_raw,data.trials(ind(ii)).blinkBegin,data.trials(ind(ii)).blinkEnd);
    end
    
    if strcmp(alignTo,'pursuitLatency') && isnan(alignmentTimes(ii))
        continue
    end
        
    ts = alignmentTimes(ii)+window;     
        
    v_raw = v_raw(ts);
    h_raw = h_raw(ts);
        
    V(ii,:) = v_raw;
    H(ii,:) = h_raw;
    
    
end

Vave_raw = nanmean(V,1);
Have_raw = nanmean(H,1);

Vave_raw = gaussSmooth(Vave_raw,params.SD);
Have_raw = gaussSmooth(Have_raw,params.SD);

ts = params.smoothing_margins:(params.time_before+params.smoothing_margins+params.time_after);
Vave = Vave_raw(ts); 
Have = Have_raw(ts); 

if smoothIndividualTrials
    for ii=1:size(H,1)
        
        H(ii,:) = gaussSmooth(H(ii,:),params.SD);
        V(ii,:) = gaussSmooth(V(ii,:),params.SD);
        
    end
end

V = V(:,ts);
H = H(:,ts);
