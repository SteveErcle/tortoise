% Tyler Start Here

clc; close all; clear all;


td = TurtleData;
ta = TurtleAuto;


% Heres how you pull intraday data 

stockNum = [1,3,10,11];
%Set stockNum to a between 1-79, see listOfStock.xlsx
%You can get multiple at once

lenOfData = '5d'
%Number of days of intraday data, max is usally 50, if you over shoot it will just pull as much as it can

durationOfCandle = '600' 
%Each "candle" represents a high, low, open and close of a given time interval
%I generally use 600 seconds (10 minutes) but you
%can change that to whatever you want


allData = td.pullData(stockNum, lenOfData, durationOfCandle);
%This will pull all the intraday data for the chosen stockNum as well as
%the S&P500. If the chosen stock data is not the same length as the S&P500
%data it throws an exception. This can happen because Google Finance doesnt
%always get all the data for every stock. I try to only use the stocks that
%Google can provide all the data for. 


disp('Here you will see some fail because the length is not equal to the SPY data')


% Here is how you iterate through the struct easily
fields = fieldnames(allData);

range = 1:length(allData.SPY.close);

for i = 1:length(fields)
    
    stock = fields{i}

    %This isnt necessary but it organizes the data for you
    ta.organizeDataGoog(allData.(stock), allData.SPY, range);
    
    window_size = 12;
    ma.STOCK = tsmovavg(ta.cl.STOCK,'e',window_size,1);
    ma.INDX = tsmovavg(ta.cl.INDX,'e',window_size,1);

    %Here is how you plot candles
    figure(i)
    subplot(2,1,1)
    hold on
    candle(ta.hi.STOCK, ta.lo.STOCK, ta.cl.STOCK, ta.op.STOCK, 'blue');
    plot(ma.STOCK)
    title(strcat(stock, ' Candles'))
    
    subplot(2,1,2)
    hold on
    candle(ta.hi.INDX, ta.lo.INDX, ta.cl.INDX, ta.op.INDX, 'red');
    plot(ma.INDX, 'r')
    title('S&P500 Candles')
    

end

pause


% This is how you pull daily data
% I dont do too much with daily data so this isnt wrapped up as nicely
% Yahoo if very forgiving with the dates, it will just choose the closest market date

close all;

stockNum = [4,5,20];
fromDate = '01/05/2016';
toDate   = '04/27/2016';

as1 = ['A',num2str(1)];
as2 = ['A',num2str(400)];
[~,allStocks] = xlsread('listOfStocks', [as1, ':', as2]);
allStocks = allStocks(stockNum);


c = yahoo;

for i = 1:length(allStocks)
    
    stock = allStocks{i};
    
    dAll.(stock) = fetch(c, stock, fromDate, toDate, 'd');
    %Pull from yahoo
    [hi, lo, cl, op, da, vo] = td.getOHLCDarray(dAll.(stock));
    %Organize data
    window_size = 12;
    ma.STOCK = tsmovavg(cl,'e',window_size,1);
    %Calc 'e' expontial moving average, 's' for simple MA
    
    figure(i)
    hold on;
    candle(hi, lo, cl, op, 'blue');
    plot(ma.STOCK)
    
end

close(c)

 
 
 