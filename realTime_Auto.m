% realTime_Auto

clc; close all; clear all;

ib = ibtws('',7497);
pause(1);
ibContract = ib.Handle.createContract;


stock = 'TSLA';
indx = 'SPY';
exchange = 'NASDAQ';

ibContract.symbol = 'TSLA';
ibContract.secType = 'STK';
ibContract.exchange = 'SMART';
ibContract.primaryExchange = 'NASDAQ';
ibContract.currency = 'USD';

tf = TurtleFun;
td = TurtleData;
ta = TurtleAutoRealTime;
isFlip = 0;

ta.slPercentFirst = 0.75;
ta.slPercentSecond = 0.25;

numPlots = 5;

ta.organizeDataIB(data.SPY, 'indx');

figure()
while(true)
    
    %     try
    
    %     catch
    %     end
    for k = 1:length(allStocks)
        
        if ~ta.enterMarket.BULL || ~ta.enterMarket.BEAR
            stock = allStocks{k};
        else
            stock = ta.enteredStock;
        end
        
        ta.organizeDataIB(data.(stock), 'stock');
        
        ta.setStock(stock);
        ta.calculateData(isFlip);
        ta.setStopLoss();
        ta.checkConditions();
        ta.executeBullTrade();
        ta.executeBearTrade();
        
    end
 
    pause(1)
end











