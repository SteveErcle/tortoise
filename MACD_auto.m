
% MACD testing

clc; close all; clear all;



as1 = ['A',num2str(1)];%1
as2 = ['A',num2str(400)];%400

[~,allStocks] = xlsread('listOfStocks', [as1, ':', as2]);

% load('equalLengthStocks');
% allStocks = equalLengthStocks;
load('equalLengthNasDaq');
allStocks = equalLengthNasDaq;
% load('roiAll')
% allStocks = allStocks(roiAll(1:80,3));
% allStocks = {'TSLA'} %allStocks(1) %{'NUGT'} % QQQ ABX

% preRange = 1000:1900;

roiCong = [];
trackTrades = [];
for k = 1:length(allStocks)
    
    stock = allStocks{k}
    
    try
        
        tf = TurtleFun;
        td = TurtleData;
        ta = TurtleAuto;
        
        ta.slPercentFirst = 0.75;
        ta.slPercentSecond = 0.25;
        
        numPlots = 5;

        
        indx = 'SPY';
        exchange = 'NASDAQ';
        
        
        INTRA = 1;
        DAILY = 0;
        
        past = now - 90;
        pres = now;
        
        
        
        if DAILY
            c = yahoo;
            
            dAll = flipud(fetch(c,stock,past, now, 'd'));
            avgAll = flipud(fetch(c,indx,past, now, 'd'));
            
            [hiD, loD, clD, opD, daD, voD] = tf.returnOHLCDarray(dAll);
            ta.hi.STOCK = hiD;
            ta.lo.STOCK = loD;
            ta.op.STOCK = opD;
            ta.cl.STOCK = clD;
            ta.vo.STOCK = voD;
            ta.da.STOCK = daD;
            [hiA, loA, clA, opA, daA, voA] = tf.returnOHLCDarray(avgAll);
            ta.hi.INDX = hiA;
            ta.lo.INDX = loA;
            ta.op.INDX = opA;
            ta.cl.INDX = clA;
            ta.vo.INDX = voA;
            ta.da.INDX = daA;
            isFlip = 1;
            len = length(clD)-1;
        end
        
        
        if INTRA
            iAll.STOCK = IntraDayStockData(stock,exchange,'600','5d');
            
            iAll.INDX = IntraDayStockData(indx,exchange,'600', '5d');
            
            for i_d = 1:length(iAll.INDX.date)
                if iAll.STOCK.date(i_d) ~= iAll.INDX.date(i_d)
                    iAll.STOCK.close = [iAll.STOCK.close(1:i_d-1); NaN; iAll.STOCK.close(i_d:end)];
                    iAll.STOCK.high = [iAll.STOCK.high(1:i_d-1); NaN; iAll.STOCK.high(i_d:end)];
                    iAll.STOCK.low = [iAll.STOCK.low(1:i_d-1); NaN; iAll.STOCK.low(i_d:end)];
                    iAll.STOCK.volume = [iAll.STOCK.volume(1:i_d-1); NaN; iAll.STOCK.volume(i_d:end)];
                    iAll.STOCK.datestring = [iAll.STOCK.datestring(1:i_d-1); NaN; iAll.STOCK.datestring(i_d:end)];
                    iAll.STOCK.date = [iAll.STOCK.date(1:i_d-1); NaN; iAll.STOCK.date(i_d:end)];
                end
            end
            
            iAll.STOCK = td.getAdjustedIntra(iAll.STOCK);
            
            iAll.INDX = td.getAdjustedIntra(iAll.INDX);
            
            if length(iAll.STOCK.close) ~= length(iAll.INDX.close)
                disp('Length Error')
                %                 break
                %                 return
            end
            
            
            for i_set_preRange = 1:1
                
                preRange = 1:length(iAll.STOCK.close);
                
                iAll.STOCK.high = iAll.STOCK.high(preRange);
                iAll.STOCK.low = iAll.STOCK.low(preRange);
                iAll.STOCK.open = iAll.STOCK.open(preRange);
                iAll.STOCK.close = iAll.STOCK.close(preRange);
                iAll.STOCK.volume = iAll.STOCK.volume(preRange);
                iAll.STOCK.date = iAll.STOCK.date(preRange);
                
                
                iAll.INDX.high = iAll.INDX.high(preRange);
                iAll.INDX.low = iAll.INDX.low(preRange);
                iAll.INDX.open = iAll.INDX.open(preRange);
                iAll.INDX.close = iAll.INDX.close(preRange);
                iAll.INDX.volume = iAll.INDX.volume(preRange);
                iAll.INDX.date = iAll.INDX.date(preRange);
                
                
            end
            
            for i_set_range = 1:1
                range = 1:length(iAll.STOCK.close);
                ta.hi.STOCK = iAll.STOCK.high(range);
                ta.lo.STOCK = iAll.STOCK.low(range);
                ta.op.STOCK = iAll.STOCK.open(range);
                ta.cl.STOCK = iAll.STOCK.close(range);
                ta.vo.STOCK = iAll.STOCK.volume(range);
                ta.da.STOCK = iAll.STOCK.date(range);
                
                ta.cl.INDX = iAll.INDX.close(range);
                ta.vo.INDX = iAll.INDX.volume(range);
               
            end
            
            isFlip = 0;
            len = length(iAll.STOCK.close)-1;
        end
        
    
        ta.calculateData(isFlip);
        
        ta.ind = 50-1;
        
        while ta.ind <= len
            
            ta.ind = ta.ind + 1;
            range = 1:ta.ind;
            
            for organize_data = 1:1
                
                if INTRA
                  
                    %%THIS DATA MAYBE BE INACCURATE OR GIVING FUTURE KNOWLEDGE
                    ta.hi.STOCK = iAll.STOCK.high(range);
                    ta.lo.STOCK = iAll.STOCK.low(range);
                    ta.op.STOCK = iAll.STOCK.open(range);
                    ta.cl.STOCK = iAll.STOCK.close(range);
                    ta.vo.STOCK = iAll.STOCK.volume(range);
                    ta.da.STOCK = iAll.STOCK.date(range);
                    
                    ta.hi.INDX = iAll.INDX.high(range);
                    ta.lo.INDX = iAll.INDX.low(range);
                    ta.op.INDX = iAll.INDX.open(range);
                    ta.cl.INDX = iAll.INDX.close(range);
                    ta.vo.INDX = iAll.INDX.volume(range);
                    ta.da.INDX = iAll.INDX.date(range);
                end
                
                if DAILY
                    ta.hi.STOCK = hiD(range);
                    ta.lo.STOCK = loD(range);
                    ta.op.STOCK = opD(range);
                    ta.cl.STOCK = clD(range);
                    ta.vo.STOCK = voD(range);
                    ta.da.STOCK = daD(range);
                    
                    ta.hi.INDX = hiA(range);
                    ta.lo.INDX = loA(range);
                    ta.op.INDX = opA(range);
                    ta.cl.INDX = clA(range);
                    ta.vo.INDX = voA(range);
                    ta.da.INDX = daA(range);  
                end
                
            end
            
            
            %ta.calculateData(isFlip);
            
            ta.setStopLoss();
            
            ta.checkConditionsUsingInd();
            
            ta.executeBullTrade();
            
            ta.executeBearTrade();
            
            
        end
        
        roiLong = (ta.trades.BULL(:,2) - ta.trades.BULL(:,1)) ./ ta.trades.BULL(:,1) * 100;
        sL = sum(roiLong(~isnan(roiLong)));
        
        roiShort = (ta.trades.BEAR(:,1) - ta.trades.BEAR(:,2)) ./ ta.trades.BEAR(:,1) * 100;
        sS = sum(roiShort(~isnan(roiShort)));
        
        disp([sL, sS, length(ta.trades.BULL) + length(ta.trades.BEAR)])
        
        trackTrades = [trackTrades; ta.trades.BULL, roiLong; ta.trades.BEAR, roiShort];
        
        disp([sum(ta.trades.BULL(:,3) - ta.trades.BULL(:,4) == 0),...
            sum(ta.trades.BEAR(:,3) - ta.trades.BEAR(:,4) == 0)])
        
        
        %         figure(1)
        %         hold on;
        %         plot([trackTrades.(stock)(:,3), trackTrades.(stock)(:,4)], [k,k])
        
        observePrice = ta.cl.STOCK(end);
        
    catch
        sL = 0;
        sS = 0;
        observePrice = 0;
    end
    
    sList = [sL, sS];
    roiCong = [roiCong; sList, k, observePrice];
    
end


roiA = [sum(roiCong(:,1:2),2), roiCong(:,3:4)];
save('roiA', 'roiA');


trackTrades = sortrows(trackTrades, 3);

for ii = 2:size(trackTrades,1)
    
    
    lastTrade = trackTrades(ii-1,4);
    
    trackNanArr = trackTrades(:,3) <= lastTrade;
    trackNanArr = find(trackNanArr == 1);
    
    trackNanArr(trackNanArr < ii) = [];
    
    trackTrades(trackNanArr,:) = NaN;
    %     jj = ii;
    %
    %     lastTrade = trackTrades(jj-1,4)+1;
    %
    %     while trackTrades(jj,3) <= lastTrade
    % %     if trackTrades(ii,3) <= trackTrades(ii-1,4)
    %         trackTrades(jj,:) = NaN;
    %         jj = jj + 1;
    %     end
    
end
trackB = trackTrades;
trackB(isnan(trackTrades(:,2)),:) = [];

sum(trackB(:,5));
length(trackB);

lengther = 0;
principal = 30000;
startingCap = principal;

equityCurve = [principal];

commision = 20;

for ii = 1:length(trackB)
    
    lengther = lengther + trackB(ii,4) - trackB(ii,3);
    principal = principal*(1+(trackB(ii,5)/100)) - commision;
    equityCurve = [equityCurve; principal];
    
end

drawDown = [];
for j = 5:100
    for i = 1:length(equityCurve)-j
        drawDown = [drawDown; (equityCurve(i+j) - equityCurve(i)) / equityCurve(i) * 100, j];
    end
end

winPercent = sum(trackB(:,5) >= 0) / length(trackB(:,5));
averageLoss = mean(trackB((trackB(:,5) < 0), 5));
averageGain = mean(trackB((trackB(:,5) >= 0), 5));

disp('   ')
disp('Achieved noncompounded ROI')
disp(sum(trackB(:,5)))
disp('Achieved compounded ROI')
disp((principal - startingCap) / startingCap * 100)
disp('Principal')
disp(principal)
disp('Number of trades')
disp(length(trackB))
disp('Time in Market')
disp(lengther)
disp('Percentage of Time in Market')
disp(lengther/ length(ta.cl.STOCK))
disp('Max Draw Down')
disp(min(drawDown))
disp('Percentage of Winning Trades')
disp(winPercent)
disp('Average Loss')
disp(averageLoss)
disp('Average Gain')
disp(averageGain)
disp('Achieved Risk Reward Ratio')
sprintf('%0.2f to 1', (averageGain/-averageLoss))
disp('Total ROI of System')
disp(sum(sum(roiCong(:,1:2))))

figure
plot(equityCurve)

% return

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
    
    %     for i = 1:length(ta.savedStops)
    %         plot([ta.savedStops(i,1), ta.savedStops(i,2)])
    %     end
    
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
    
    %     subplot(numPlots,1,3)
    %     cla
    %     bp = bar(ta.B.STOCK,'k');
    %     set(get(bp,'Children'),'FaceAlpha',0.2);
    %     hold on
    %     plot(ta.macdvec.STOCK)
    %     plot(ta.nineperma.STOCK,'r')
    
    %     subplot(numPlots,1,4)
    %     cla
    %     bp = bar(ta.B.INDX,'k');
    %     set(get(bp,'Children'),'FaceAlpha',0.2);
    %     hold on
    %     plot(ta.macdvec.INDX)
    %     plot(ta.nineperma.INDX,'r')
    
    
    
    %     subplot(numPlots,1,7)
    %     cla
    %     plot(ta.rsi.STOCK)
    %     hold on
    %     plot(xlim, [50,50])
    %     plot(xlim, [70,70])
    %     plot(xlim, [30,30])
    
    
    %     subplot(numPlots,1,8)
    %     cla
    %     hold on
    %     plot(ta.clSma,'b')
    %     plot(ta.clAma, 'r')
    %     plot(ta.clRma, 'k')
    
    
    
    
    
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
