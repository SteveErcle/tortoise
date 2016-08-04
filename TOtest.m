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


%% Test 2

A  = sortrows([1, 2]');
P  = sortrows([97]');
O  = sortrows([pi/8, pi/2]');
t = 0:199;

y = to.genWave(A,P,O,t);


assert(isempty(y));


%% Test 3

A  = sortrows([1,2]');
P  = sortrows([17, 97]');
O  = sortrows([pi/8, pi/2]');
t = 0:199;

y = to.genWave(A,P,O,t);

opt = @(x)(sum(abs(y - to.genWave(x(1:2),x(3:4),x(5:6),t))));

options = optimoptions('particleswarm','SwarmSize',50,'HybridFcn',@fmincon);

nvars = 6; 
lb = [ 0,  0,  10,  70, -pi, -pi];
ub = [10, 10,  30, 120,  pi,  pi];

x = particleswarm(opt,nvars,lb,ub, options);

A_ = sortrows([x(1:2)]');
P_ = sortrows([x(3:4)]');
O_ = sortrows([x(5:6)]');

assert(sum(abs(A_ - A)) <= tol, 'Didnt converge onto A');
assert(sum(abs(P_ - P)) <= tol, 'Didnt converge onto P');
assert(sum(abs(O_ - O)) <= tol, 'Didnt converge onto O');




