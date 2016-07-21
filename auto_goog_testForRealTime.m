% auto_goog_testForRealTime

clc; close all; clear all;

WATCH = 0;
VIEW  = 1;
PULL  = 1;x
stockNum = [22:36]

delete(watchConditions);
handles = guihandles(watchConditions);

ta = TurtleAuto;
td = TurtleData;

stopType = 'follow';
% ta.slPercentFirst = nan;%0.75;
% ta.slPercentSecond = nan;%0.25;
ta.sgPercent = 0.50;
ta.levelPercent = 0.0;

numPlots = 6;
lenOfData = '15d'
durationOfCandle = '600';

if PULL == 1
    allData = td.pullData(stockNum, lenOfData, durationOfCandle);
else
    load('allData')
end

allStocks = fieldnames(allData); allStocks = allStocks(2:end);
stock = allStocks{1};

len = size(allData.SPY.close,1)-1;
ta.ind = 50-1;

% ta.organizeDataGoog(allData.(stock), allData.SPY, 1:length(allData.SPY.close));
% ta.calculateData(0);

while ta.ind <= len
    
    ta.ind = ta.ind + 1;
    range = 1:ta.ind;
    
    disp(ta.ind)
    
    
    for k = 1:length(allStocks)
        
        if ta.enterMarket.BULL || ta.enterMarket.BEAR
            stock = ta.enteredStock;
        else
            stock = allStocks{k};
        end
        
        ta.organizeDataGoog(allData.(stock), allData.SPY, range);
        
        ta.setStock(stock);
        ta.calculateData(0);
        ta.setStopLoss(stopType);
        ta.checkConditionsUsingInd();
        ta.executeBullTrade();
        ta.executeBearTrade();
        
        
        if ta.enterMarket.BULL || ta.enterMarket.BEAR
            break
        end
        
    end
    
    %     conditions = [ta.condition.Not_Stopped_Out.BULL,...
    %         ta.condition.Not_End_of_Day,...
    %         ta.condition.Large_Volume,...
    %         ta.condition.Above_MA.BULL,...
    %         ta.condition.Above_MA_prev.BULL,...
    %         ta.condition.dip_MA.BULL,...
    %         ta.condition.Below_MA.BEAR,...
    %         ta.condition.dip_MA.BEAR,...
    %         ta.condition.Below_MA_prev.BEAR];
    %
    %     %         ta.condition.Within_Level.BULL,...
    %     %         ta.condition.Within_Level.BEAR,...
    %
    %
    %     set(handles.enterMarketBull, 'String', num2str(ta.enterMarket.BULL))
    %     set(handles.enterMarketBear, 'String', num2str(ta.enterMarket.BEAR))
    %     set(handles.stopLossBull, 'String', num2str(ta.stopLoss.BULL))
    %     set(handles.stopLossBear, 'String', num2str(ta.stopLoss.BEAR))
    %     set(handles.conditions, 'String', num2str(conditions))
    %
    %     if ta.condition.Trying_to_Enter.BULL || ta.condition.Trying_to_Enter.BULL
    %         set(handles.watch, 'Value', WATCH);
    %     end
    %
    %
    %      set(handles.watch, 'Value', WATCH);
    %     if get(handles.watch, 'Value')
    %
    %         subplot(numPlots,1,[1:2])
    %         cla
    %         candle(ta.hi.STOCK, ta.lo.STOCK, ta.cl.STOCK, ta.op.STOCK, 'blue');
    %         hold on
    %         plot(ta.clSma,'b')
    %         xlim(gca, [0, 200])
    %         for jj = 1:size(ta.trades.BULL,1)
    %             plot(ta.trades.BULL(jj,3), ta.trades.BULL(jj,1), 'go')
    %             plot(ta.trades.BULL(jj,4), ta.trades.BULL(jj,2), 'ko')
    %         end
    %         for jj = 1:size(ta.trades.BEAR,1)
    %             plot(ta.trades.BEAR(jj,3), ta.trades.BEAR(jj,1), 'ro')
    %             plot(ta.trades.BEAR(jj,4), ta.trades.BEAR(jj,2), 'ko')
    %         end
    %
    %         subplot(numPlots,1,3)
    %         cla
    %         candle(ta.hi.INDX, ta.lo.INDX, ta.cl.INDX, ta.op.INDX, 'red');
    %         hold on
    %         plot(ta.clAma,'r')
    %         xlim(gca, [0, 200])
    %
    %         subplot(numPlots,1,4)
    %         cla
    %         bar(ta.vo.STOCK)
    %         hold on
    %         plot(xlim, [mean(ta.vo.STOCK), mean(ta.vo.STOCK)])
    %         xlim(gca, [0, 200])
    %
    %         subplot(numPlots,1,5)
    %         cla
    %         bar(ta.vo.INDX)
    %         hold on
    %         plot(xlim, [mean(ta.vo.INDX), mean(ta.vo.INDX)])
    %         xlim(gca, [0, 200])
    %
    %         pause
    %
    %     end
    
end



try
    roiLong = (ta.trades.BULL(:,2) - ta.trades.BULL(:,1)) ./ ta.trades.BULL(:,1) * 100;
    sL = sum(roiLong(~isnan(roiLong)));
catch
    roiLong = 0;
    sL = 0;
end

try
    roiShort = (ta.trades.BEAR(:,1) - ta.trades.BEAR(:,2)) ./ ta.trades.BEAR(:,1) * 100;
    sS = sum(roiShort(~isnan(roiShort)));
catch
    roiShort = 0;
    sS = 0;
end

disp([sL, sS, size(ta.trades.BULL,1) + size(ta.trades.BEAR,1)])

disp([(sL + sS) / (size(ta.trades.BULL,1) + size(ta.trades.BEAR,1))])

principal = 20000;
principal = principal*(1+(sL+sS)/100) - (size(ta.trades.BULL,1) + size(ta.trades.BEAR,1))*20;

disp(principal)

if VIEW == 0
    return
end



above = [];
below = [];
for i = 1:length(ta.cl.STOCK)
    if ta.cl.STOCK(i) > ta.clSma(i)
        above = [above; i];
    else
        below = [below; i];
    end
end


B = [nan; diff(below)];
y = below(find( B ~= 1 ));

B = [nan; diff(above)];
x = above(find( B ~= 1 ));

x(1) = []; y(1) = [];

z = sortrows([x;y]);

% plot(ta.cl.STOCK)
% hold on
% plot(ta.clSma,'r')
% plot(x, ta.clSma(x), 'go')
% plot(y, ta.clSma(y), 'ro')

length(z)

numBack = 50;

backer = nan(numBack-1,2);
for ind = numBack:length(ta.cl.STOCK)
    numFound = 0;
    for i = ind-numBack+1:ind
        if ~isempty(find(z == i))
            numFound = numFound + 1;
        end
    end
    backer = [backer; ind, numFound];
    
end


delete(slider);
handles = guihandles(slider);


len = length(ta.cl.INDX);
set(handles.axisView, 'Max', len, 'Min', 0);
set(handles.axisView, 'SliderStep', [1/len, 10/len]);
set(handles.axisView, 'Value', 0);

figure


subplot(numPlots,1,[1:2])
cla
candle(ta.hi.STOCK, ta.lo.STOCK, ta.cl.STOCK, ta.op.STOCK, 'blue');
hold on
plot(ta.clSma,'b')

subplot(numPlots,1,3)
cla
candle(ta.hi.INDX, ta.lo.INDX, ta.cl.INDX, ta.op.INDX, 'red');
hold on
plot(ta.clAma,'r')

subplot(numPlots,1,4)
cla
bar(ta.vo.STOCK)
hold on
plot(xlim, [mean(ta.vo.STOCK), mean(ta.vo.STOCK)])

subplot(numPlots,1,5)
cla
bar(ta.vo.INDX)
hold on
plot(xlim, [mean(ta.vo.INDX), mean(ta.vo.INDX)])

subplot(numPlots,1,6)
cla
bar(backer(:,1), backer(:,2))


for j = 2:numPlots
    
    if j == 2
        subIndx = [1:2];
    else
        subIndx = j;
    end
    
    subplot(numPlots,1,subIndx)
    
    hold on
    axisView = get(handles.axisView, 'Value');
    xlim(gca, [0+axisView, 100+axisView])
    
    yLimits = ylim(gca);
    yLo = yLimits(1);
    yHi = yLimits(2);
    
    for i = 1:size(ta.trades.BEAR,1)
        xLo = ta.trades.BEAR(i,3);
        xHi = ta.trades.BEAR(i,4);
        
        if j == 2
            yLo = min(ta.trades.BEAR(i,1:2));
            yHi = max(ta.trades.BEAR(i,1:2));
        end
        
        xLong = [xLo xHi xHi xLo];
        yLong = [yLo yLo yHi yHi];
        
        if roiShort(i) < 0
            color = [1, .7, .7];
        else
            color = [0.7, 1, .7];
        end
        
        hp = patch(xLong,yLong, color, 'FaceAlpha', 0.25);
        
    end
    
    for i = 1:size(ta.trades.BULL,1)
        xLo = ta.trades.BULL(i,3);
        xHi = ta.trades.BULL(i,4);
        
        if j == 2
            yLo = min(ta.trades.BULL(i,1:2));
            yHi = max(ta.trades.BULL(i,1:2));
        end
        
        xLong = [xLo xHi xHi xLo];
        yLong = [yLo yLo yHi yHi];
        
        if roiLong(i) < 0
            color = [1, .7, .7];
        else
            color = [0.7, 1, .7];
        end
        
        hp = patch(xLong,yLong, color, 'FaceAlpha', 0.25);
    end
    
end

while(true)
    
    
    for j = 2:numPlots
        
        if j == 2
            subIndx = [1:2];
        else
            subIndx = j;
        end
        
        subplot(numPlots,1,subIndx)
        
        axisView = get(handles.axisView, 'Value');
        xlim(gca, [0+axisView, 100+axisView])
        
        
    end
    
pause(10/100)
    
end




return;







