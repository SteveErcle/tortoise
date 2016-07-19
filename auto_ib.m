% auto_ib

clc; close all; clear all;

PULL = 1;

as1 = ['A',num2str(1)];%1
as2 = ['A',num2str(400)];%400
[~,allStocks] = xlsread('listOfStocks', [as1, ':', as2]);

% load('equalLengthNasDaq');
% allStocks = equalLengthNasDaq;

addpath('\\psf\Home\Documents\turtles\intraData');
load('intraGOOG');
load('intraSPY');

if PULL == 1
    ib = ibtws('',7497);
    pause(1)
    ibBuiltInErrMsg

    ibContract.STOCK = ib.Handle.createContract;
    ibContract.STOCK.secType = 'STK';
    ibContract.STOCK.exchange = 'SMART';
    ibContract.STOCK.currency = 'USD';
    
    ibContract.INDX = ib.Handle.createContract;
    ibContract.INDX.symbol = 'SPY';
    ibContract.INDX.secType = 'STK';
    ibContract.INDX.exchange = 'SMART';
    ibContract.INDX.currency = 'USD';
    
    ib_indx = timeseries(ib, ibContract.INDX, now-7, now, '10 mins' , '', true);
    pause(1)
    
end

roiCong = [];
trackTrades = [];
for k = 1:length(allStocks)
    
    stock = allStocks{k}
    k
    
    try
        
        tf = TurtleFun;
        td = TurtleData;
        ta = TurtleAuto;
        
        ta.slPercentFirst = 0.75;
        ta.slPercentSecond = 0.25;
        
        numPlots = 5;
        
        if  PULL == 1
            ibContract.STOCK.symbol = stock;
            
            ib_stock = timeseries(ib, ibContract.STOCK, now-7, now, '10 mins' , '', true);
            if ib_stock(1) == 'H'
                ib_stock
                disp('Service Error')
                break
            end
            pause(1)
            ta.organizeDataIB(ib_stock, ib_indx);
        else
            
            intraPreStock = ib_intra;
            
            dailyDates = unique(floor(intraSPY(:,1)));
            intraSTOCK = [];
            intraINDX = [];
            
            for i = 1:length(dailyDates)
                
                found = find(floor(intraPreStock(:,1)) == dailyDates(i));
                
                if ~isempty(found)
                    intraSTOCK = [intraSTOCK; intraPreStock(found,:)];
                    
                    found = find(floor(intraSPY(:,1)) == dailyDates(i));
                    intraINDX = [intraINDX; intraSPY(found,:)];
                    
                end
                
            end
            
            mean(intraINDX(:,1) == intraSTOCK(:,1))
            ib_stock = intraSTOCK;
            ib_indx = intraINDX;
        end
        
        isFlip = 0;
        ta.organizeDataIB(ib_stock, ib_indx);
        ta.calculateData(isFlip);
        
        ta.ind = 50-1;
        len = length(ta.cl.STOCK)-1;
        
        while ta.ind <= len
            
            ta.ind = ta.ind + 1;
            range = 1:ta.ind;
            
            ta.organizeDataIB(ib_stock(range,:), ib_indx(range,:));
            
            %ta.calculateData(isFlip);
            
            ta.setStopLoss();
            
            ta.checkConditionsUsingInd();
            %END OF DAY SET TO CHECK 15:50
            
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
        
        observePrice = ta.cl.STOCK(end);
        
    catch
        sL = 0;
        sS = 0;
        observePrice = 0;
    end
    
    sList = [sL, sS];
    roiCong = [roiCong; sList, k, observePrice];
    
end

%         candle(ta.hi.STOCK, ta.lo.STOCK, ta.cl.STOCK, ta.op.STOCK, 'blue');
%         figure
%         candle(ta.hi.INDX, ta.lo.INDX, ta.cl.INDX, ta.op.INDX, 'blue');
        

roiA = [sum(roiCong(:,1:2),2), roiCong(:,3:4)];
save('roiA', 'roiA');


trackTrades = sortrows(trackTrades, 3);

for ii = 2:size(trackTrades,1)
    
    
    lastTrade = trackTrades(ii-1,4);
    
    trackNanArr = trackTrades(:,3) <= lastTrade;
    trackNanArr = find(trackNanArr == 1);
    
    trackNanArr(trackNanArr < ii) = [];
    
    trackTrades(trackNanArr,:) = NaN;

    
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
disp(lengther/ length(ta.cl.INDX))
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
