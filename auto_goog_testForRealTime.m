% auto_goog_testForRealTime

clc; close all; clear all;


delete(watchConditions);
handles = guihandles(watchConditions);

data_from_file = 'EURUSD_APRIL';

tAnalyzer = TurtleAnalyzer;

WATCH = 0;
VIEW  = 1;
PULL  = 1;

stocki = [1,25:36];
stocki = 11

roiStock = [];
perStockRoiAll = [];

for i = stocki
    
    stockNum = [i]
    
    try
        ta = TurtleAuto;
        td = TurtleData;
        
        stopType = 'follow';
        ta.slPercentFirst = nan;%0.75;
        ta.slPercentSecond = nan;%0.25;
        
        numPlots = 7;
        lenOfData = '50d'
        durationOfCandle = '600';
        
        
        if PULL == 1
            allData = td.pullData(stockNum, lenOfData, durationOfCandle);
        else
            load(data_from_file);
        end
        
        
%         allData.FX = tenlyFX;
%         allData.SPY = tenlyFX;
%         allStocks = {'FX'};
%         allData.SPY = allData.(stock);
        allStocks = fieldnames(allData); allStocks = allStocks(2:end);
        stock = allStocks{1};

        
        len = size(allData.SPY.close,1)-1;
        ta.ind = 50-1;
        
        ta.organizeDataGoog(allData.(stock), allData.SPY, 1:length(allData.SPY.close));
        ta.calculateData(0);
        
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
                %         ta.calculateData(0);
                ta.setStopLoss(stopType);
                ta.checkConditionsUsingInd();
                ta.executeBullTrade();
                ta.executeBearTrade();
                
                
                if ta.enterMarket.BULL || ta.enterMarket.BEAR
                    break
                end
                
            end
            
          
            
        end
        
        
        
        try
            roiLong = (ta.trades.BULL(:,2) - ta.trades.BULL(:,1)) ./ ta.trades.BULL(:,1) * 100;
            sL = sum(roiLong(~isnan(roiLong)));
            roiLong = [roiLong, ta.trades.BULL(:,3)];
        catch
            roiLong = 0;
            sL = 0;
        end
        
        try
            roiShort = (ta.trades.BEAR(:,1) - ta.trades.BEAR(:,2)) ./ ta.trades.BEAR(:,1) * 100;
            sS = sum(roiShort(~isnan(roiShort)));
            roiShort = [roiShort, ta.trades.BEAR(:,3)];
        catch
            roiShort = 0;
            sS = 0;
        end
        
        disp([sL, sS, size(ta.trades.BULL,1) + size(ta.trades.BEAR,1)])
        
        disp([(sL + sS) / (size(ta.trades.BULL,1) + size(ta.trades.BEAR,1))])
        
        roiAll = sortrows([roiLong; roiShort] , 2);
        
        
        principal = 20000;
        for i = 1:size(roiAll,1)-1
            principal = principal*(1+roiAll(i,1)/100) - 20;
            
        end
        
        sprintf('%0.2f',principal)
        roiStock = [roiStock; sL, sS];
        
        
    catch
    end
    
    perStockRoiAll = [perStockRoiAll; roiAll];
    
    
end

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

numBack = 12;

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

backer(isnan(backer(:,2)),2) = 0;
backerMA = tsmovavg(backer(:,2),'e',12,1);
BbackerMA = [nan; diff(backerMA)];


delete(slider);
handles = guihandles(slider);


len = length(ta.cl.INDX);
set(handles.axisView, 'Max', len, 'Min', 0);
set(handles.axisView, 'SliderStep', [1/len, 10/len]);
set(handles.axisView, 'Value', 0);
set(handles.axisLen, 'Max', len, 'Min', 20);
set(handles.axisLen, 'SliderStep', [1/len, 10/len]);
set(handles.axisLen, 'Value', 100);


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
hold on
plot(backerMA, 'r')
plot(BbackerMA*10, 'c')

subplot(numPlots,1,7)
cla
bar(roiAll(:,2), roiAll(:,1), 'b')% 'Marker', '.');
title('Trade')



for j = 2:numPlots
    
    if j == 2
        subIndx = [1:2];
    else
        subIndx = j;
    end
    
    subplot(numPlots,1,subIndx)
    hold on
    
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
        
        if roiShort(i,1) < 0
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
        
        if roiLong(i,1) < 0
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
        axisLen  = get(handles.axisLen, 'Value');
        xlim(gca, [0+axisView, axisLen+axisView])
        
    end
    
    pause(10/100)
    
end




return;







