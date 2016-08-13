clc; close all; clear all;

td = TurtleData;
ta = TurtleAuto;
tz = TurtleAnalyzer;
to = TurtleOptimizer;

stockNum = [23];
lenOfData = '40d';
durationOfCandle = '600';


allData = td.pullData(stockNum, lenOfData, durationOfCandle);
% SERIOUSLY, FIX PULLING DATA 1550? 1600?

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



trainLen = 700;
valLen   = 598;
roiAll = [];

for i = 0:0
    
    candleStart = 50+i*valLen;
    candleStart = 50;
    candleStart;
    candleEnd   = candleStart+trainLen;
    candleEnd+1;
    candleEnd+valLen;
    
    opt = @(x)(to.lcv_WhiteSpace(ta, candleStart, candleEnd, x));
    nvars = 2;
    lb = [0,  7];
    ub = [10, 78];
    
    options = optimoptions('particleswarm','SwarmSize',20,'HybridFcn',@fmincon);
    x = particleswarm(opt,nvars,lb,ub, options);
    
    disp(x)
    
    [roi, inMarket] = to.lc_WhiteSpace(ta, candleStart, candleEnd, x);
    disp([sum(roi), size(inMarket.BULL,1)])
    
    [roiV, inMarketV] = to.lc_WhiteSpace(ta, candleEnd+1, candleEnd+valLen, x);
    disp([sum(roiV), size(inMarketV.BULL,1)])
    disp([mean(roiV), std(roiV)]);
    
    roiAll = [roiAll; sum(roi)];
    
end

% return



window_size = floor(x(2))
ma.STOCK = tsmovavg(ta.cl.STOCK,'e',window_size,1);

plot(ma.STOCK)
plot(inMarket.BULL(:,1), ta.cl.STOCK(inMarket.BULL(:,1)), 'go');
plot(inMarket.BULL(:,2), ta.cl.STOCK(inMarket.BULL(:,2)), 'ro');


