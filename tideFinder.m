clc; close all; clear all;

% td = TurtleData;
% ta = TurtleAuto;
% 
% stockNum = [11];
% lenOfData = '50d';
% durationOfCandle = '600';
% 
% 
% allData = td.pullData(stockNum, lenOfData, durationOfCandle);
% 
% 
% fields = fieldnames(allData);
% range = 1:length(allData.SPY.close);
% 
% stock = fields{2};
% 
% ta.organizeDataGoog(allData.(stock), allData.SPY, range);
% 
% window_size = 12;
% ma.STOCK = tsmovavg(ta.cl.STOCK,'e',window_size,1);
% ma.INDX = tsmovavg(ta.cl.INDX,'e',window_size,1);
% 
% subplot(2,1,1)
% hold on
% candle(ta.hi.STOCK, ta.lo.STOCK, ta.cl.STOCK, ta.op.STOCK, 'blue');
% plot(ma.STOCK)
% title(strcat(stock, ' Candles'))
% 
% subplot(2,1,2)
% hold on
% candle(ta.hi.INDX, ta.lo.INDX, ta.cl.INDX, ta.op.INDX, 'red');
% plot(ma.INDX, 'r')
% title('S&P500 Candles')

to = TurtleOptimizer;


A = [1,2];
P = [17, 97];
O  = [pi/8, pi/2];
t = 0:199;


y = to.genWave(A,P,O,t);


opt = @(x)(sum(abs(y - to.genWave(x(1:2),x(3:4),x(5:6),t))));

options = optimoptions('particleswarm','SwarmSize',200,'HybridFcn',@fmincon);


nvars = 6; 
lb = [ 0,  0,  10,  10, -pi, -pi];
ub = [10, 10, 200, 200,  pi,  pi];

x = particleswarm(opt,nvars,lb,ub, options)
                        
% x = to.solve(opt,nvars,lb,ub)


