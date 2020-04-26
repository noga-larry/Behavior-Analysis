
function [gain, latency, init_time ,rotateAngle]  = fitTimingDirectionAndGain(V,H)
LEN  = 175;
BASELINE_LEN =50;
FIRST_INX = 25;
NUM_ITER = 2; % number of iterations

numTrials = size(H,1);
velocity(1,:,:) = H;
velocity(2,:,:) = V;

avg_vel = squeeze(nanmean(velocity,2));

%remove basline velocity
base_vel = nanmean(avg_vel(:,1:BASELINE_LEN),2);
velocity = bsxfun(@minus, velocity, base_vel);
avg_vel =  bsxfun(@minus, avg_vel, base_vel);

last_inx = min(FIRST_INX+LEN-1, length(V));
template(1,:) = avg_vel(1, FIRST_INX:last_inx);
template(2,:) = avg_vel(2, FIRST_INX:last_inx);

% rotate behavior so that template will be in  45 deg
angle = atan2d(template(2,end),template(1,end)); % use end of template to define direction 
rotateAngle = -(angle-45); % rotate to 45;
 
[template(1,:),template(2,:)] = rotateEyeMovement(template(1,:),template(2,:),rotateAngle);
[velocity(1,:,:),velocity(2,:,:)] = ...
    rotateEyeMovement(squeeze(velocity(1,:,:)),squeeze(velocity(2,:,:)),rotateAngle);

all_template =[];%%% 
all_vaf = [];%%%
all_init = [];%%%
 
for k =1:NUM_ITER
    if(k~=1)
        % recalculate template
         velocityShifted  = nan(2,numTrials,LEN);
        for i=1:numTrials
            sizeOfShift = all_init(k-1,i);
            if(isnan(sizeOfShift))
                continue
            else
                f= sizeOfShift-BASELINE_LEN;
                l = sizeOfShift-BASELINE_LEN+LEN-1;
                velocityShifted(:,i,:) = velocity(:,i,f:l);
            end
        end
        template = nanmean(velocityShifted,2);
    end
    all_template(k,:,:) = template;
    
    
    if( length(template) <  LEN)
        warning('not enough data for matching template');
        warning([ 'use only ' num2str(last_inx-FIRST_INX) ' out of ' num2str(LEN)]);
        LEN = length(template);
    end
     
    varTemplate = var(template(:)); % for frac of  explained variance
    maxExplainedVar = nan(1,size(velocity,2));
    slopeBest = nan(2,size(velocity,2));
    latencyBest = nan(1,size(velocity,2));
    for i=1:numTrials
        trialVel = squeeze(velocity(:,i,:));
        if(any(isnan(trialVel(:)))) % if there are saccades in the trial, ignore it. 
            slopeBest(:,i) = [NaN NaN];
            latenacyBest(i) = NaN;
            vaf_best(i) = NaN;
            continue;
        end
        
        SumSquaresShifted = zeros(2, size(trialVel,2) - LEN);
        xVelShifted = zeros(LEN, size(trialVel,2) - LEN);
        yVelShifted = zeros(LEN, size(trialVel,2) - LEN);
        
        sq_trial = trialVel.^2;
        % sum of squares will be use for calculation of the regression slope (== gain)
        
         % shift behavior by j ms and fit template to the shifted trace
        for j=1:size(trialVel,2) - LEN
            
            xVelShifted(:,j) = trialVel(1,j:j+LEN-1);
            SumSquaresShifted(:,j) = sum(sq_trial(:,j:j+LEN-1),2);
            yVelShifted(:,j) = trialVel(2,j:j+LEN-1);

        end

        % fit to template -  faster this way 
        % formula for regresson b, over all shifts together: 
        ShiftedSlopes(1,:) = (template(1,:)*xVelShifted)./SumSquaresShifted(1,:);
        ShiftedSlopes(2,:) = (template(2,:)*yVelShifted)./SumSquaresShifted(2,:);
        
        % preddict velocity - used to find the best fit latency
        predX = bsxfun(@times, ShiftedSlopes(1,:), xVelShifted);
        predY = bsxfun(@times, ShiftedSlopes(2,:), yVelShifted);
        
        errX = bsxfun(@minus, predX, template(1,:)');
        errY = bsxfun(@minus, predY, template(2,:)');
        errTotal = mean(errX.^2 + errY.^2)/2;
        explainedVar = 1-errTotal/varTemplate;
        
        % Fond the shift that is most similar to the template
        [maxExplainedVar(i), maxShift ] = max(explainedVar);
        slopeBest(:,i) = ShiftedSlopes(:,maxShift);
        latenacyBest(i) = maxShift + BASELINE_LEN;
    end
    
    
    %figure; hist(vaf,30);title(num2str(nanmean(vaf)));
    init_time  = FIRST_INX+BASELINE_LEN;
    all_vaf(k,:) = maxExplainedVar;
    all_init(k,:) = latenacyBest;
    all_gain(k,:,:) =  1./slopeBest;
end
[tot_max_vaf, max_inx] = max(nanmean(all_vaf,2));
 
gain = squeeze(all_gain(max_inx,:,:));
latency =  all_init(max_inx,:);


if mean(isnan(latency))>0.2
    disp(['A lot of NaNs in latency : ' num2str(mean(isnan(latency)))] )
end
% ---  plot some templates
% figure;
% col = {'b', 'r', 'g', 'k', 'm'};
% for i=1:size(all_template,1)
%     c = mod(i, length(col));
%     if(c==0); c = length(col); end;
%     subplot(2,2,1);
%     plot(squeeze(all_template(i,1,:))', 'color', col{c}); hold on;
%     subplot(2,2,2);
%     plot(squeeze(all_template(i,2,:))', 'color', col{c}); hold on;
% 
% 
% end
 
 


