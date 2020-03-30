function [rotatedTraceH,rotatedTraceV] = rotateEyeMovement(traceH, traceV, theta)

% This function rotates the eyemovement by an angle of theta;
%Input:     traceH          Horizontal vellocity/position trace 
%           traceV          Vertical vellocity/position trace 
%           theta           Rotation angle in degrees.
%Output:    rotatedTraceH   Horizonal velocity of rotaed trace.
%           rotatedTraceV   Vertical velocity of rotaed trace.

trace = [traceH; traceV];
% create rotation matrix
Rot = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
% rotate trace
rotatedTrace = Rot*trace;

% take only the projection on the axis of the requested direction
rotatedTraceH = rotatedTrace(1,:);
rotatedTraceV = rotatedTrace(2,:);

end

