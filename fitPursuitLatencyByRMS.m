function latency = fitPursuitLatencyByRMS(data,ind)

THRESHOLD_FACTOR = 10; 

params.time_before = 200;
params.time_after = -50;
params.SD = 15;
params.smoothing_margins = params.SD*5;

[~,~,V,H] = meanVelocities(data,params,ind,'smoothIndividualTrials',true);
base_line_velocity = sqrt(V.^2+H.^2);
RMS = nanstd(base_line_velocity(:));

params.time_before = 25;
params.time_after = 250;
params.SD = 15;
params.smoothing_margins = params.SD*5;

[~,~,V,H] = meanVelocities(data,params,ind,'smoothIndividualTrials',true);
velocity = sqrt(V.^2+H.^2);
[~,latency] = max(velocity>RMS*THRESHOLD_FACTOR,[],2);

end