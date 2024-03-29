function [beginSaccade, endSaccade] = getSaccades( Hvel, Vvel, blinks, targetOnset, targetOffset )

% 2023/03/22: BLINKS REMOVED!

% This function finds saccades in the behavioral data. It is
% based on an old function of Mati's and is therefore a little messy. 
% Inputs   Hvel      Horizontal vellocity trace
%          Vvel      Vertical vellocity trace
%          blinks    Maestro's matrix of blinks (data.blinks), beginning   
%                    and end points.
%          targetOnset   
%                    Time of traget movement onset
%          targetOffset  
%                    Time of traget movement offset
% Outputs: beginSaccade 
%                    Time point of saccades beginnings
%          endSaccade 
%                    Time point of saccades endings


% constants 
SD_SMOOTH = 5; % parameter for smoothing
ACC_THRSHOLD = 1000;
VEL_THRSHOLD_DURING_MOVE = 50; % velocity threshold for movement 
VEL_THRSHOLD_PRE_MOVE = 10; % velocity threshold for fixation 
PRE_SAC = 0; % time before threshold crossing
POST_SAC = 20; % time after threshold crossing
MERGE_SAC = 50; % merge saccades in case they are closer than merge value
MIN_BLINK_LENGTH = 50; % minimal length for a blink

% when target off use very strict criteria
REACT_TIME = 60;
MOVE_RELAX = 250; % est. time from the end of the movement to relaxation

raw_speed = sqrt(Hvel.^2+Vvel.^2);
% smooth
speed = gaussSmooth(raw_speed,SD_SMOOTH);
 
% each componenet seperatly
v_smooth = [];
v_smooth(1,:) = gaussSmooth(Hvel, SD_SMOOTH);
v_smooth(2,:) = gaussSmooth(Vvel, SD_SMOOTH);
acc = diff(v_smooth')*1000;
abs_acc = sqrt(sum(acc.^2,2));

abs_acc = [0 abs_acc']; % dummy
len = length(abs_acc);
sacc_bool = zeros(1,len);
in_sac = 0;

 for k=1:len
    if(isempty(targetOnset) || k<targetOnset+REACT_TIME || k> targetOffset+ MOVE_RELAX)
        c_vel_thr = VEL_THRSHOLD_PRE_MOVE;
    else
        c_vel_thr = VEL_THRSHOLD_DURING_MOVE;
    end
                
    if(abs_acc(k) > ACC_THRSHOLD || speed(k) > c_vel_thr) 
        if(~in_sac)
            in_sac =1;
        end
    else
        if(in_sac) % mark end of saccade
            in_sac = 0;
        end
    end
    sacc_bool(k) = in_sac;
 end
 


% convert to markers
    
% the purpose of the added 0s is that if the trial begins or end in a
% saccade the saccade in the beging will be maked as if it began on 1
% and in the end in the last bin. 
beginSaccade_raw = find(diff([0, sacc_bool, 0]) == 1) -1;
endSaccade_raw = find(diff([0, sacc_bool, 0]) == - 1) -1;

% stretch saccade by PRE and POST  saccade parameters
beginSaccade_raw = beginSaccade_raw - PRE_SAC;
endSaccade_raw = endSaccade_raw + POST_SAC;

% deal with edge
beginSaccade_raw(beginSaccade_raw <= 0) =1;
endSaccade_raw(endSaccade_raw >= len) = length(Hvel)-1;

% combine close threshold crossing

if ~isempty(beginSaccade_raw)
    beginSaccade = [];
    beginSaccade(1) = beginSaccade_raw(1);
    endSaccade =[];

    for k= 2:length(beginSaccade_raw)
        if(beginSaccade_raw(k) - MERGE_SAC <endSaccade_raw(k-1))
            continue;
        else % saccade do not overlap
            beginSaccade(end+1) = beginSaccade_raw(k);
            endSaccade(end+1) = endSaccade_raw(k-1);
        end
    end
    endSaccade(end+1) = endSaccade_raw(end);
else
    beginSaccade = beginSaccade_raw;
    endSaccade = endSaccade_raw;
    
end

blinkBegin = blinks(1:2:end);
blinkEnd = blinks(2:2:end);

blinkInx =[];
for i = 1:length(blinkBegin)
    blinkInx =  [blinkInx blinkBegin(i):blinkEnd(i)];
end
overlap_indices = [];

for i = 1:length(beginSaccade)
    % Check if there is an overlap 
    if ~isempty(intersect(blinkInx, beginSaccade(i):endSaccade(i)))
        % If there is an overlap, add the index to the overlap_indices vector
        overlap_indices(end+1) = i;
    end
end

endSaccade(overlap_indices) = [];
beginSaccade(overlap_indices) = [];

% plot(Vvel);
% hold on;
% plot(Hvel);
% plot (beginSaccade,zeros(length(beginSaccade),1),'or');
% plot (endSaccade,zeros(length(endSaccade),1),'og')

% try to make sure any saccade that begins also ends
assert (length(beginSaccade)==length(endSaccade))

       

end

