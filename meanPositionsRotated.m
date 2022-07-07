function [Have,Vave,H,V] = ...
    meanPositionsRotated(data,params,ind,varargin)

% This function computes the average horizontal and vertical
% velocities of a subset of trials in a session, rotated to the same angle 
% of 0 deg.In the procees it removes saccades and blinks and smoothes the
% averages using a Gaussian window.
% Inputs: data           A data structure containing trial information, as 
%                        created by get_data
%         params         A data struture that contains different parameter
%                        for behavior analysis:
%          .time_before  How much time to display before target movement
%                        (ms)
%          .time_after   How much time to display after target movement
%                        (ms)
%          .params.smoothing_margins
%                        Size of margins to prevent end effect in smoothing
%                        (ms)
%           .SD          Strandard deviation for Gaussian smoothing window 
%        ind             Indices of trials to average (should be in same 
%                        direction)
% Outputs:  Have         Average horizontal velocity
%           Vave         Average vertical velocity


[Have,Vave,H,V] = meanRotatedBehavior(data,params,ind,...
    'pos', varargin{:});