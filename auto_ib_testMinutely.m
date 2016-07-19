% auto_ib_testMinutely

clc; close all; clear all;

WATCH = 0;

as1 = ['A',num2str(1)];%1
as2 = ['A',num2str(400)];%400
[~,allStocks] = xlsread('listOfStocks', [as1, ':', as2]);

allStocks = allStocks([50]);
% allStocks = {'HALO'}

ta = TurtleAutoRealTime;
td = TurtleData;

numPlots = 5;

ib = ibtws('',7497);
pause(1)
ibBuiltInErrMsg

ibContract = ib.Handle.createContract;
ibContract.secType = 'STK';
ibContract.exchange = 'SMART';
ibContract.currency = 'USD';


load('tenTimes')
load('weeklyDates')
startDate = weeklyDates(end-3)-4;
endDate   = weeklyDates(end-3)

for k = 0:length(allStocks)
    
    pause(1)
    
    if k == 0
        stock = 'SPY'
        ibContract.symbol = stock;
        
        allData.SPY = timeseries(ib, ibContract, startDate, endDate, '1 min' , '', true);
        
        if ~isnumeric(allData.SPY(1))
            disp('Service Error')
            return
        end
    else
        stock = allStocks{k}
        ibContract.symbol = stock;
        
        allData.(stock) = timeseries(ib, ibContract, startDate, endDate, '1 min', '', true);
        
        if length(allData.(stock)) ~= length(allData.SPY)
            disp('Length Error')
            return
        end
    end
    
    ten.(stock).Hi = nan;
    ten.(stock).Lo = nan;
    ten.(stock).Op = nan;
    ten.(stock).Cl = nan;
    ten.(stock).Vo = 0;
    ten.(stock).data = [];
    
end


delete(watchConditions);
handles = guihandles(watchConditions);


for i = 1:length(allData.SPY)
    
    ten.SPY = td.genTen(ten.SPY, allData.SPY, i, tenTimes);
    ten.(stock) = td.genTen(ten.(stock), allData.(stock), i, tenTimes);
    
    if size(ten.SPY.data,1) == 113
        ta.lastTradeTime
    end 
    
    if size(ten.SPY.data,1) >= 50
        
        ta.organizeDataIB(ten.SPY.data, 'indx');
        ta.organizeDataIB(ten.(stock).data, 'stock');
        ten.SPY.data(end,1);
        ten.(stock).data(end,1);
        
        ta.setStock(stock);
        ta.calculateData(0);
        ta.setStopLoss();
        ta.checkConditions();
        ta.executeBullTrade();
        ta.executeBearTrade();
        
        
        conditions = [ta.condition.Not_Stopped_Out.BULL,...
            ta.condition.Large_Volume,...
            ta.condition.Not_End_of_Day,...
            ta.condition.Not_Same_Candle_Trade...
            ta.condition.Above_MA.BULL,...
            ta.condition.Below_MA.BEAR,...
            ta.condition.Trying_to_Enter.BULL,...
            ta.condition.Trying_to_Enter.BEAR];
        
        set(handles.enterMarketBull, 'String', num2str(ta.enterMarket.BULL))
        set(handles.enterMarketBear, 'String', num2str(ta.enterMarket.BEAR))
        set(handles.stopLossBull, 'String', num2str(ta.stopLoss.BULL))
        set(handles.stopLossBear, 'String', num2str(ta.stopLoss.BEAR))
        set(handles.conditions, 'String', num2str(conditions))
        set(handles.index, 'String', num2str(i))
        set(handles.time, 'String', num2str(ten.SPY.data(end,1)))
        
        
        if ta.condition.Trying_to_Enter.BULL || ta.condition.Trying_to_Enter.BULL
            set(handles.watch, 'Value', WATCH);
        end
        
        if get(handles.watch, 'Value')
            
            subplot(numPlots,1,[1:2])
            cla
            candle(ta.hi.STOCK, ta.lo.STOCK, ta.cl.STOCK, ta.op.STOCK, 'blue');
            hold on
            plot(ta.clSma,'b')
            for jj = 1:size(ta.trades.BULL,1)
                plot(ta.trades.BULL(jj,3), ta.trades.BULL(jj,1), 'go')
                plot(ta.trades.BULL(jj,4), ta.trades.BULL(jj,2), 'ko')
            end
            for jj = 1:size(ta.trades.BEAR,1)
                plot(ta.trades.BEAR(jj,3), ta.trades.BEAR(jj,1), 'ro')
                plot(ta.trades.BEAR(jj,4), ta.trades.BEAR(jj,2), 'ko')
            end
            
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
            
            pause
        end
        
    end
    
end



try
    roiLong = (ta.trades.BULL(:,2) - ta.trades.BULL(:,1)) ./ ta.trades.BULL(:,1) * 100;
    sL = sum(roiLong);
catch
    roiLong = 0;
    sL = 0;
end

try
    roiShort = (ta.trades.BEAR(:,1) - ta.trades.BEAR(:,2)) ./ ta.trades.BEAR(:,1) * 100;
    sS = sum(roiShort);
catch
    roiShort = 0;
    sS = 0;
end

disp([sL, sS, size(ta.trades.BULL,1) + size(ta.trades.BEAR,1)])

principal = 20000;
principal = principal*(1+(sL+sS)/100) - (size(ta.trades.BULL,1) + size(ta.trades.BEAR,1))*20;

disp(principal)

% return


% stock = 'ACHN'
% ibContract.symbol = stock;
% data.(stock) = timeseries(ib, ibContract, startDate, endDate, '10 mins', '', true);
% [da, op, hi, lo, cl, vo] = td.organizeDataIB(data.(stock));
% disp([op, ten.(stock).data(:,2), op == ten.(stock).data(:,2)])
% disp([hi, ten.(stock).data(:,3), hi == ten.(stock).data(:,3)])
% disp([lo, ten.(stock).data(:,4), lo == ten.(stock).data(:,4)])
% disp([cl, ten.(stock).data(:,5), cl == ten.(stock).data(:,5)])
% disp([vo, ten.(stock).data(:,6), vo == ten.(stock).data(:,6)])










delete(slider);
handles = guihandles(slider);


len = length(ta.cl.INDX);
set(handles.axisView, 'Max', len, 'Min', 0);
set(handles.axisView, 'SliderStep', [1/len, 10/len]);
set(handles.axisView, 'Value', 0);

figure

while(true)
    
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
    
    pause(10/100);
    
end

return;




