clc; close all; clear all;

td = TurtleData;
ta = TurtleAuto;

stockNum = [11];
lenOfData = '50d';
durationOfCandle = '600';


allData = td.pullData(stockNum, lenOfData, durationOfCandle);


fields = fieldnames(allData);
range = 1:length(allData.SPY.close);

stock = fields{2};

ta.organizeDataGoog(allData.(stock), allData.SPY, range);

window_size = 12;
ma.STOCK = tsmovavg(ta.cl.STOCK,'e',window_size,1);
ma.INDX = tsmovavg(ta.cl.INDX,'e',window_size,1);

% subplot(2,1,1)
hold on
candle(ta.hi.STOCK, ta.lo.STOCK, ta.cl.STOCK, ta.op.STOCK, 'blue');
plot(ma.STOCK)
title(strcat(stock, ' Candles'))

% subplot(2,1,2)
% hold on
% candle(ta.hi.INDX, ta.lo.INDX, ta.cl.INDX, ta.op.INDX, 'red');
% plot(ma.INDX, 'r')
% title('S&P500 Candles')

to = TurtleOptimizer;

% x = [0.25 0.5, 40, 110, 0, pi]
t = range(12:300);

opt = @(x)(sum(abs(ma.STOCK(12:300) - to.genWave(x(1:2),x(3:4),x(5:6),t, mean(ta.cl.STOCK)))));
options = optimoptions('particleswarm','SwarmSize',200,'HybridFcn',@fmincon);


nvars = 6;
lb = [0, 0, 37,  90, -pi, -pi];
ub = [2, 5, 53, 130,  pi,  pi];

x = particleswarm(opt,nvars,lb,ub, options)

t = 12:1999;
y = to.genWave(x(1:2),x(3:4),x(5:6),t, mean(ta.cl.STOCK));
plot(t,y,'k')


By  = [nan; diff(y)];
Bma = [nan; diff(ma.STOCK(12:1999))];
ByBin  = By  > 0;
BmaBin = Bma > 0;
Bside = ByBin == BmaBin;
BsideUpper = ByBin(find(Bside) > 0);
upper = find(ByBin(find(Bside)) > 0);

setterUpper = [];
x = BsideUpper;
z = find(x == 1);
setterUpper = [];
for i = 1:length(z)-1
    setterUpper = [setterUpper; z(i), z(i+1)-1+1];
end 

return

t = 12:300;
y = to.genWave(x(1:2),x(3:4),x(5:6),t, mean(ta.cl.STOCK));
plot(t,y,'c')

for i = 1:length(Bside)
    if Bside(i) == 1
        if ByBin(i) > 0
            color = 'gx';
        else
            color = 'rx';
        end
        
        plot(i+12, ta.cl.STOCK(i+12), color)
        
    end
end





