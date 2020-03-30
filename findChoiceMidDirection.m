function [phi] = findChoiceMidDirection(h1,v1,h2,v2,plot_flag)
% This function computes the angle that represents the middle axis
% between the behavior in two choice conditions. Using the mean behavior in
% the end 10 ms of the inputed vectors. 
% Inputs:
%       h1  Horizontal behavior in the first condition.
%       v1  Vertical behavior in the first condition.
%       h2  Horizontal behavior in the second condition.
%       v2  Vertical behavior in the second condition.
% Output:
%       phi The angle of the mid direction

c1 = [mean(h1(end-10:end)) mean(v1(end-10:end))]; % end point of condition 1
c2 = [mean(h2(end-10:end)) mean(v2(end-10:end))]; % end point of condition 2
meanV = [mean([c1(1), c2(1)]),mean([c1(2), c2(2)])]; % mean end point
phi = atan2d( meanV(2), meanV(1));
phi = phi + 360*(phi<0);




