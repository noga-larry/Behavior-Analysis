function [Have,Vave,hPos,vPos] = meanPositions(data,params,ind,varargin)

% This function computes the average horizontal and vertical
% Positions of a subset of trials in a session. In the procees it removes 
% saccades and blinks and smoothes the averages using a Gaussian window.
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
% Outputs:  Have         Average horizontal position
%           Vave         Average vertical position


[Have,Vave,hPos,vPos] = meanBehavior(data,params,ind,'pos',varargin);



