clc; close all; clear all;

td = TurtleData;
ta = TurtleAuto;

stockNum = [11];
lenOfData = '10d';
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

% t = range(12:300);
% 
% opt = @(x)(sum(abs(ma.STOCK(12:300) - to.genWave(x(1:2),x(3:4),x(5:6),t, mean(ta.cl.STOCK)))));
% options = optimoptions('particleswarm','SwarmSize',200,'HybridFcn',@fmincon);
% 
% 
% nvars = 6;
% lb = [0, 0, 37,  90, -pi, -pi];
% ub = [2, 5, 53, 130,  pi,  pi];
% 
% x = particleswarm(opt,nvars,lb,ub, options)
% 
% t = 12:1999;
% y = to.genWave(x(1:2),x(3:4),x(5:6),t, mean(ta.cl.STOCK));
% plot(t,y,'k')


% By  = [nan; diff(y)];
% Bma = [nan; diff(ma.STOCK(12:1999))];
% ByBin  = By  > 0;
% BmaBin = Bma > 0;
% Bside = ByBin == BmaBin;
% BsideUpper = ByBin(find(Bside) > 0);
% upper = find(ByBin(find(Bside)) > 0);

% setterUpper = [];
% x = BsideUpper;
% z = find(x == 1);
% setterUpper = [];
% for i = 1:length(z)-1
%     setterUpper = [setterUpper; z(i), z(i+1)-1+1];
% end


% t = 12:300;
% y = to.genWave(x(1:2),x(3:4),x(5:6),t, mean(ta.cl.STOCK));
% plot(t,y,'c')


%
% BmaPos = [nan; diff(Bma > 0)];
% oner    = find(BmaPos == 1);
% negOner = find(BmaPos == -1);
% allPos = [oner, negOner+1];
%
% BmaNeg = [nan; diff(Bma <= 0)];
% oner    = find(BmaNeg == 1);
% negOner = find(BmaNeg == -1);
% oner(end) = [];
% allNeg = [oner, negOner+1];

Bma = [nan; diff(ma.STOCK(12:end))];
Bma = [nan(11,1); Bma];

inMarket.BULL = [];
enter = 0;
for i = 50:length(ta.cl.STOCK)
    
    if Bma(i) > 0
        
        if enter == 0
            inMarket.BULL = [inMarket.BULL; i, nan];
        end
        
        enter = 1;
        
    else
        
        if enter == 1
            inMarket.BULL(end,2) = i;
        end
        
        enter = 0;
        
    end
end




tz = TurtleAnalyzer;

roiPos = tz.percentDifference(ta.cl.STOCK(inMarket.BULL(:,1)), ta.cl.STOCK(inMarket.BULL(:,2)));
sum(roiPos)
% 
% roiNeg = -tz.percentDifference(ta.cl.STOCK(allNeg(:,1)), ta.cl.STOCK(allNeg(:,2)));
% sum(roiNeg)


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

% for i = 1:length(allNeg)
%     
%     xLo = allNeg(i,1);
%     xHi = allNeg(i,2);
%     
%     x = [xLo xHi xHi xLo];
%     y = [yLo yLo yHi yHi];
%     
%     color = [1, .7, .7];
%     
%     hp = patch(x,y, color, 'FaceAlpha', 0.25);
%     
% end
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





