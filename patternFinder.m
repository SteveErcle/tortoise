clc; close all; clear all;

td = TurtleData;
ta = TurtleAuto;
tz = TurtleAnalyzer;
to = TurtleOptimizer;

stockNum = [11];
lenOfData = '35d';
durationOfCandle = '600';


allData = td.pullData(stockNum, lenOfData, durationOfCandle);

fields = fieldnames(allData);
range = 1:length(allData.SPY.close);

stock = fields{2};

ta.organizeDataGoog(allData.(stock), allData.SPY, range);

window_size = 54;
ma.STOCK = tsmovavg(ta.cl.STOCK,'e',window_size,1);
ma.INDX = tsmovavg(ta.cl.INDX,'e',window_size,1);

% subplot(2,1,1)
hold on
candle(ta.hi.STOCK, ta.lo.STOCK, ta.cl.STOCK, ta.op.STOCK, 'blue');
title(strcat(stock, ' Candles'))

% subplot(2,1,2)
% hold on
% candle(ta.hi.INDX, ta.lo.INDX, ta.cl.INDX, ta.op.INDX, 'red');
% plot(ma.INDX, 'r')
% title('S&P500 Candles')

candleStart = 50;
candleEnd   = 1200;

opt = @(x)(to.lcv_WhiteSpace(ta, candleStart, candleEnd, x));
nvars = 3;
lb = [0,  0,  7];
ub = [10, 5, 78];



options = optimoptions('particleswarm','SwarmSize',20,'HybridFcn',@fmincon);
x = particleswarm(opt,nvars,lb,ub, options);

disp(x)

[roi, inMarket] = to.lc_WhiteSpace(ta, candleStart, candleEnd, x);
disp([sum(roi), size(inMarket.BULL,1)])

[roi, inMarket] = to.lc_WhiteSpace(ta, candleEnd+1, length(ta.cl.STOCK), x);
disp([sum(roi), size(inMarket.BULL,1)])
disp([mean(roi), std(roi)]);


window_size = floor(x(3))
ma.STOCK = tsmovavg(ta.cl.STOCK,'e',window_size,1);

plot(ma.STOCK)
plot(inMarket.BULL(:,1), ta.cl.STOCK(inMarket.BULL(:,1)), 'go');
plot(inMarket.BULL(:,2), ta.cl.STOCK(inMarket.BULL(:,2)), 'ro');


