function [rotatedTraceH,rotatedTraceV] = rotateEyeMovement(traceH, traceV, theta)

% This function rotates the eyemovement by an angle of theta;
%Input:     traceH          Horizontal vellocity/position trace
%           traceV          Vertical vellocity/position trace
%           theta           Rotation angle in degrees.
%Output:    rotatedTraceH   Horizonal velocity of rotaed trace.
%           rotatedTraceV   Vertical velocity of rotaed trace.

assert(size(traceH,1)==size(traceV,1),...
    'Diffrent number of vertical and horizontal traces')

numTrials = size(traceH,1);
% create rotation matrix
Rot = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
% rotate trace

for i=1:numTrials
    trace = [traceH(i,:); traceV(i,:)];
    rotatedTrace = Rot*trace;
    
    % take only the projection on the axis of the requested direction
    rotatedTraceH(i,:) = rotatedTrace(1,:);
    rotatedTraceV(i,:) = rotatedTrace(2,:);
    
end

