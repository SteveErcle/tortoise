% testTurtleOptimizer

clc; close all; clear all; 

addpath('tortoise\')
to = TurtleOptimizer;

tol = 1e-4;
%% Test 1

opt = @(x)((x-3).^2 + 100);
nvars = 1;
lb = -100;
ub = 100;
x = to.solve(opt,nvars,lb,ub);

assert(abs(x-3)<= tol, 'Solver not solving')

