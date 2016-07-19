% auto_goog_testForRealTime

clc; close all; clear all;

as1 = ['A',num2str(1)];%1
as2 = ['A',num2str(400)];%400
[~,allStocks] = xlsread('listOfStocks', [as1, ':', as2]);
allStocks = allStocks(1)

td = TurtleData;
ta = TurtleAuto;

exchange = 'NASDAQ';
lenOfData = '50d';

numPlots = 5;

PULL = 0;
VIEW = 0;

if PULL == 1
    for k = 0:length(allStocks)
        
        pause(1)
        
        if k == 0
            stock = 'SPY'
            allData.SPY = IntraDayStockData(stock,exchange,'600',lenOfData);
            allData.SPY = td.getAdjustedIntra(allData.SPY);
            
        else
            stock = allStocks{k}
            try
                temp = IntraDayStockData(stock,exchange,'600',lenOfData);
                
                %         for i_d = 1:length(iAll.INDX.date)
                %             if iAll.STOCK.date(i_d) ~= iAll.INDX.date(i_d)
                %                 iAll.STOCK.close = [iAll.STOCK.close(1:i_d-1); NaN; iAll.STOCK.close(i_d:end)];
                %                 iAll.STOCK.high = [iAll.STOCK.high(1:i_d-1); NaN; iAll.STOCK.high(i_d:end)];
                %                 iAll.STOCK.low = [iAll.STOCK.low(1:i_d-1); NaN; iAll.STOCK.low(i_d:end)];
                %                 iAll.STOCK.volume = [iAll.STOCK.volume(1:i_d-1); NaN; iAll.STOCK.volume(i_d:end)];
                %                 iAll.STOCK.datestring = [iAll.STOCK.datestring(1:i_d-1); NaN; iAll.STOCK.datestring(i_d:end)];
                %                 iAll.STOCK.date = [iAll.STOCK.date(1:i_d-1); NaN; iAll.STOCK.date(i_d:end)];
                %             end
                %         end
                
                temp = td.getAdjustedIntra(temp);
                
                if length(temp.close) ~= length(allData.SPY.close)
                    disp('Length Error')
                else
                    allData.(stock) = temp;
                end
                
            catch
                disp('Failed to pull stock data')
            end
        end
    end
else
    load('allData')
end

fields = fieldnames(allData);
stock = fields{2}
temp.STOCK = allData.(stock);
temp.INDX = allData.SPY;
clear allData;
allData = [];
allData.SPY = temp.INDX;
allData.(stock) = temp.STOCK;


tc = TurtleCharacteristic;
taz = TurtleAnalyzer;

point = tc.makePointAtoB(allData, 20);

tc.getCharacterGoog(allData, stock, 'SPY');

first = allData.SPY.close(point.A);
second = allData.SPY.close(point.B);
roi = [point.A, point.B, taz.percentDifference(first, second)];
sortedRoi = sortrows(roi,-3);

bestNum = 40;

bestA = sortedRoi(1:bestNum, 1);
bestB = sortedRoi(1:bestNum, 2);
worstA = sortedRoi(end-bestNum+1:end, 1);
worstB = sortedRoi(end-bestNum+1:end, 2);





fields = fieldnames(tc.character);

for j = 1:length(fields)
    
    figure(j)
    hold on
    
    field = fields{j}
    
    tc.plotMeanAndStd(1, 'b', tc.character.(field).STOCK(bestA))
    tc.plotMeanAndStd(2, 'k', tc.character.(field).STOCK)
    tc.plotMeanAndStd(3, 'b', tc.character.(field).STOCK(worstA))
    
    
    xlim([0,4])
    
    title(field)
    
    
end






