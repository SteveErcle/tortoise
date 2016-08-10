clc; close all; clear all;

td = TurtleData;
ta = TurtleAuto;

stockNum = [25];
lenOfData = '20d';
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
% candle(ta.hi.STOCK, ta.lo.STOCK, ta.cl.STOCK, ta.op.STOCK, 'blue');
plot(ta.cl.STOCK,'b')
plot(ma.STOCK)
title(strcat(stock, ' Candles'))

% subplot(2,1,2)
% hold on
% candle(ta.hi.INDX, ta.lo.INDX, ta.cl.INDX, ta.op.INDX, 'red');
% plot(ma.INDX, 'r')
% title('S&P500 Candles')

to = TurtleOptimizer;

x = [0.25 0.5, window_size, 30, 0, pi];

modelStop = 500;

t = range(window_size:modelStop);

for i = 1:3
    
    if i == 1
        nvars = 3;
        lb = [0,  30,  -pi];
        ub = [2,  100,  pi];
        opt = @(x)(sum(abs(ma.STOCK(window_size:modelStop) - to.genWave(x(1),x(2),x(3),t, mean(ta.cl.STOCK)))));
        
    end
    
    if i == 2
        nvars = 3;
        lb = [0,  100,  -pi];
        ub = [2,  200,  pi];
        opt = @(x)(sum(abs(ma.STOCK(window_size:modelStop) - to.genWave(x(1),x(2),x(3),t, mean(ta.cl.STOCK)))));
        
    end
    
    if i == 3
        nvars = 6;
        lb = [0, 0, first*.75,  second*.75,  -pi, -pi];
        ub = [2, 5, first*1.25, second*1.25,  pi,  pi];
        opt = @(x)(sum(abs(ma.STOCK(window_size:modelStop) - to.genWave(x(1:2),x(3:4),x(5:6),t, mean(ta.cl.STOCK)))));
        
    end
    
    
    options = optimoptions('particleswarm','SwarmSize',500,'HybridFcn',@fmincon);
    
    x = particleswarm(opt,nvars,lb,ub, options)
    
    if i == 1
        first = x(2)
    elseif i == 2
        second = x(2)
    end
    
end


foundParams = x

t = window_size:length(ta.cl.STOCK);
y = to.genWave(x(1:2),x(3:4),x(5:6),t, mean(ta.cl.STOCK));
plot(t,y,'k')


Bma = [nan; diff(ma.STOCK(window_size:end))];
Bma = [nan(window_size-1,1); Bma];

By  = [nan; diff(y)];
By = [nan(window_size-1,1); By];

t = window_size:modelStop;
y = to.genWave(x(1:2),x(3:4),x(5:6),t, mean(ta.cl.STOCK));
plot(t,y,'c')



inMarket.BULL = [];
inMarket.BEAR = [];
enter.BULL = 0;
enter.BEAR = 0;
examine.BULL = 1;
examine.BEAR = 1;

thres = 0.0;

for i = modelStop+1:length(ta.cl.STOCK)-1
    
    if examine.BULL == 1
        if Bma(i) > max(Bma)*0 && By(i) > max(By)*thres
            if enter.BULL == 0
                inMarket.BULL = [inMarket.BULL; i, nan];
            end
            enter.BULL = 1;
        else
            if enter.BULL == 1
                inMarket.BULL(end,2) = i;
            end
            enter.BULL = 0;
        end
    end
    
    if examine.BEAR == 1
        if Bma(i) < max(Bma)*0 && By(i) < min(By)*thres
            if enter.BEAR == 0
                inMarket.BEAR = [inMarket.BEAR; i, nan];
            end
            enter.BEAR = 1;
        else
            if enter.BEAR == 1
                inMarket.BEAR(end,2) = i;
            end
            enter.BEAR = 0;
        end
    end
    
    
end

if ~isempty(inMarket.BULL), inMarket.BULL(end,:) = []; end
if ~isempty(inMarket.BEAR), inMarket.BEAR(end,:) = []; end

tz = TurtleAnalyzer;

if examine.BULL == 1
    roiPos = tz.percentDifference(ta.cl.STOCK(inMarket.BULL(:,1)), ta.cl.STOCK(inMarket.BULL(:,2)));
    disp([sum(roiPos), length(roiPos)]);
end

if examine.BEAR == 1
    roiNeg = -tz.percentDifference(ta.cl.STOCK(inMarket.BEAR(:,1)), ta.cl.STOCK(inMarket.BEAR(:,2)));
    disp([sum(roiNeg), length(roiNeg)]);
end




% delete(slider);
% handles = guihandles(slider);
%
% len = length(ta.cl.INDX);
% set(handles.axisView, 'Max', len, 'Min', 0);
% set(handles.axisView, 'SliderStep', [1/len, 10/len]);
% set(handles.axisView, 'Value', 0);
% set(handles.axisLen, 'Max', len, 'Min', 20);
% set(handles.axisLen, 'SliderStep', [1/len, 10/len]);
% set(handles.axisLen, 'Value', 100);

yLimits = ylim(gca);
yLo = yLimits(1);
yHi = yLimits(2);

for i = 1:length(inMarket.BULL)
    
    xLo = inMarket.BULL(i,1);
    xHi = inMarket.BULL(i,2);
    
    x = [xLo xHi xHi xLo];
    y = [yLo yLo yHi yHi];
    
    color = [0.7, 1, .7];
    
    hp = patch(x,y, color, 'FaceAlpha', 0.25);
    
end

for i = 1:length(inMarket.BEAR)
    
    xLo = inMarket.BEAR(i,1);
    xHi = inMarket.BEAR(i,2);
    
    x = [xLo xHi xHi xLo];
    y = [yLo yLo yHi yHi];
    
    color = [1, .7, .7];
    
    hp = patch(x,y, color, 'FaceAlpha', 0.25);
    
end
%
% while(true)
%
%     axisView = get(handles.axisView, 'Value');
%     axisLen  = get(handles.axisLen, 'Value');
%     xlim(gca, [0+axisView, axisLen+axisView]);
%     yLimits = ylim(gca);
%     yLo = yLimits(1);
%     yHi = yLimits(2);
%
%     pause(10/100);
%
% end





