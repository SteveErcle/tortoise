clc; close all; clear all;


load('roiA')
load('roiB')


roiAll = [roiB(:,1), roiA];
roiAll = sortrows(roiAll, -1)
% roiA = sortrows(roiA, -1)
% roiB = sortrows(roiB, -1)

sum(roiAll(1:30,2))
sum(roiAll(end-29:end,2))

save('roiAll', 'roiAll')

return



as1 = ['A',num2str(1)];%1
as2 = ['A',num2str(2000)];%400

[~,allStocks] = xlsread('listOfNASDAQ', [as1, ':', as2]);

indx = 'SPY';
exchange = 'NASDAQ';

iAll.INDX = IntraDayStockData(indx,exchange,'600', '50d');

goodLengthStocks = [];

parfor k = 1:length(allStocks)
    k
    stock = allStocks{k};
    try
        stockData = IntraDayStockData(stock,exchange,'600','50d');
        
        if length(stockData.close) == length(iAll.INDX.close)
            stock
            goodLengthStocks = [goodLengthStocks; k];
        end
        
    catch
    end
    
    
end

goodies = {};
for i = goodLengthStocks
goodies = [goodies, {allStocks{i}}]
end 

goodies = goodies';

equalLengthNasDaq = goodies;

save('equalLengthNasDaq', 'equalLengthNasDaq');


