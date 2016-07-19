% auto_goog_testForRealTime

clc; close all; clear all;

as1 = ['A',num2str(1)];%1
as2 = ['A',num2str(400)];%400
[~,allStocks] = xlsread('listOfStocks', [as1, ':', as2]);
allStocks = allStocks(15)

td = TurtleData;
ta = TurtleAuto;

exchange = 'NASDAQ';
lenOfData = '50d';

numPlots = 5;

PULL = 1;
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

% fields = fieldnames(allData);
% stock = fields{10}
% temp.STOCK = allData.(stock);
% temp.INDX = allData.SPY;
% clear allData;
% allData = [];
% allData.SPY = temp.INDX;
% allData.(stock) = temp.STOCK;


preRange = 1:1999;
allData.(stock).high = allData.(stock).high(preRange);
allData.(stock).low = allData.(stock).low(preRange);
allData.(stock).open = allData.(stock).open(preRange);
allData.(stock).close = allData.(stock).close(preRange);
allData.(stock).volume = allData.(stock).volume(preRange);
allData.(stock).date = allData.(stock).date(preRange);

allData.SPY.high = allData.SPY.high(preRange);
allData.SPY.low = allData.SPY.low(preRange);
allData.SPY.open = allData.SPY.open(preRange);
allData.SPY.close = allData.SPY.close(preRange);
allData.SPY.volume = allData.SPY.volume(preRange);
allData.SPY.date = allData.SPY.date(preRange);

range = 1:length(allData.(stock).close);
ta.ind = range(end);
ta.organizeDataGoog(allData.(stock), allData.SPY, range);
ta.setStock(stock);
ta.calculateData(0);

aboves = [];
unders = [];

for i_hide_init = 1:1
    characteristic.aboves.volume = [];
    characteristic.aboves.support= [];
    characteristic.aboves.support_1 = [];
    characteristic.aboves.support_2 = [];
    characteristic.aboves.open = [];
    characteristic.aboves.close = [];
    
    characteristic.aboves.volumeIndx = [];
    characteristic.aboves.supportIndx = [];
    characteristic.aboves.support_1Indx = [];
    characteristic.aboves.support_2Indx = [];
    characteristic.aboves.openIndx = [];
    
    characteristic.unders.volume = [];
    characteristic.unders.support = [];
    characteristic.unders.support_1 = [];
    characteristic.unders.support_2 = [];
    characteristic.unders.open = [];
    characteristic.unders.close = [];
    
    characteristic.unders.volumeIndx = [];
    characteristic.unders.supportIndx = [];
    characteristic.unders.support_1Indx = [];
    characteristic.unders.support_2Indx = [];
    characteristic.unders.openIndx = [];
    
    characteristic.aboves.B = [];
    characteristic.aboves.BIndx = [];
    characteristic.unders.B = [];
    characteristic.unders.BIndx = [];
    
    characteristic.aboves.MACD_abs = [];
    characteristic.aboves.MACD_rel = [];
    characteristic.aboves.MACD_absIndx = [];
    characteristic.aboves.MACD_relIndx = [];
    
    characteristic.unders.MACD_abs = [];
    characteristic.unders.MACD_rel = [];
    characteristic.unders.MACD_absIndx = [];
    characteristic.unders.MACD_relIndx = [];
end 


trackTrades = [];

for i = 100:range(end)
    if  ta.nineperma.STOCK(i-1) < ta.macdvec.STOCK(i-1)...
            && ta.nineperma.INDX(i-1) < ta.macdvec.INDX(i-1)...
            && ~strcmp(datestr(ta.da.STOCK(i),15), '15:50')...
            && ~strcmp(datestr(ta.da.STOCK(i),15), '09:30')...
            && (ta.vo.STOCK(i-1) > mean(ta.vo.STOCK(1:i))...
            || ta.vo.STOCK(i-2) > mean(ta.vo.STOCK(1:i)))...
            && ta.cl.STOCK(i-1) > ta.clSma(i-1)...
            %&& ta.op.STOCK(i) > ta.clSma(i)...
%             && ta.lo.STOCK(i) < ta.clSma(i)...
           
            %&& (((ta.op.STOCK(i) - ta.clSma(i-1))/ ta.clSma(i-1)) * 100) > 0.5...

            trackTrades = [trackTrades; i, ta.op.STOCK(i), ta.cl.STOCK(i)];
       
%             && ta.B.STOCK(i-1) >= 0.003...
%             && ta.cl.INDX(i-1) > ta.clAma(i-1)...

        
                
%             && (ta.vo.INDX(i-1) > mean(ta.vo.INDX(1:i))...
%             && ta.vo.INDX(i-2) > mean(ta.vo.INDX(1:i)))...
%             && ta.vo.STOCK(i-1) < 2*mean(ta.vo.STOCK(1:i))...
%             && ta.vo.STOCK(i-2) < 2*mean(ta.vo.STOCK(1:i))...
           

            
        if ta.cl.STOCK(i) >= ta.clSma(i)
            aboves = [aboves; i, ta.hi.STOCK(i)*1.001];
            
            characteristic.aboves.volume(end+1) = ta.vo.STOCK(i-1)/mean(ta.vo.STOCK(1:i));
            characteristic.aboves.volumeIndx(end+1) = ta.vo.INDX(i-1)/mean(ta.vo.INDX(1:i));
            
            characteristic.aboves.support(end+1) =  (ta.lo.STOCK(i) - ta.clSma(i))/ ta.clSma(i) * 100;
            characteristic.aboves.support_1(end+1) =  (ta.lo.STOCK(i-1) - ta.clSma(i-1))/ ta.clSma(i-1) * 100;
            characteristic.aboves.support_2(end+1) =  (ta.lo.STOCK(i-2) - ta.clSma(i-2))/ ta.clSma(i-2) * 100;
            
            characteristic.aboves.supportIndx(end+1) =  (ta.lo.INDX(i) - ta.clAma(i))/ ta.clAma(i) * 100;
            characteristic.aboves.support_1Indx(end+1) =  (ta.lo.INDX(i-1) - ta.clAma(i-1))/ ta.clAma(i-1) * 100;
            characteristic.aboves.support_2Indx(end+1) =  (ta.lo.INDX(i-2) - ta.clAma(i-2))/ ta.clAma(i-2) * 100;
            
            characteristic.aboves.open(end+1) =   abs(ta.op.STOCK(i) - ta.clSma(i-1))/ ta.clSma(i-1) * 100;
            characteristic.aboves.openIndx(end+1) =   abs(ta.op.INDX(i) - ta.clAma(i-1))/ ta.clAma(i-1) * 100;
            
            characteristic.aboves.close(end+1) = (ta.cl.STOCK(i) - ta.clSma(i))/ ta.clSma(i) * 100;
            
            characteristic.aboves.B(end+1) = (ta.B.STOCK(i-1));
            characteristic.aboves.BIndx(end+1) = (ta.B.INDX(i-1));
            
            characteristic.aboves.MACD_abs(end+1) = ta.macdvec.STOCK(i-1);
            characteristic.aboves.MACD_rel(end+1) = (ta.macdvec.STOCK(i-1) - ta.nineperma.STOCK(i-1))/ ta.nineperma.STOCK(i-1) * 100;
            
            characteristic.aboves.MACD_absIndx(end+1) = ta.macdvec.INDX(i-1);
            characteristic.aboves.MACD_relIndx(end+1) = (ta.macdvec.INDX(i-1) - ta.nineperma.INDX(i-1))/ ta.nineperma.INDX(i-1) * 100;
           
            
        else
            unders = [unders; i, ta.hi.STOCK(i)*1.001];
            characteristic.unders.volume(end+1) = ta.vo.STOCK(i-1)/mean(ta.vo.STOCK(1:i));
            characteristic.unders.volumeIndx(end+1) = ta.vo.INDX(i-1)/mean(ta.vo.INDX(1:i));
            
            characteristic.unders.support(end+1) =  (ta.lo.STOCK(i) - ta.clSma(i))/ ta.clSma(i) * 100;
            characteristic.unders.support_1(end+1) =  (ta.lo.STOCK(i-1) - ta.clSma(i-1))/ ta.clSma(i-1) * 100;
            characteristic.unders.support_2(end+1) =  (ta.lo.STOCK(i-2) - ta.clSma(i-2))/ ta.clSma(i-2) * 100;
            
            characteristic.unders.supportIndx(end+1) =  (ta.lo.INDX(i) - ta.clAma(i))/ ta.clAma(i) * 100;
            characteristic.unders.support_1Indx(end+1) =  (ta.lo.INDX(i-1) - ta.clAma(i-1))/ ta.clAma(i-1) * 100;
            characteristic.unders.support_2Indx(end+1) =  (ta.lo.INDX(i-2) - ta.clAma(i-2))/ ta.clAma(i-2) * 100;
            
            characteristic.unders.open(end+1) =   (ta.op.STOCK(i) - ta.clSma(i-1))/ ta.clSma(i-1) * 100;
            characteristic.unders.openIndx(end+1) =   (ta.op.INDX(i) - ta.clAma(i-1))/ ta.clAma(i-1) * 100;
            
            characteristic.unders.close(end+1) = (ta.cl.STOCK(i) - ta.clSma(i))/ ta.clSma(i) * 100;
            
            characteristic.unders.B(end+1) = (ta.B.STOCK(i-1));
            characteristic.unders.BIndx(end+1) = (ta.B.INDX(i-1));
            
            characteristic.unders.MACD_abs(end+1) = ta.macdvec.STOCK(i-1);
            characteristic.unders.MACD_rel(end+1) = (ta.macdvec.STOCK(i-1) - ta.nineperma.STOCK(i-1))/ ta.nineperma.STOCK(i-1) * 100;
            
            characteristic.unders.MACD_absIndx(end+1) = ta.macdvec.INDX(i-1);
            characteristic.unders.MACD_relIndx(end+1) = (ta.macdvec.INDX(i-1) - ta.nineperma.INDX(i-1))/ ta.nineperma.INDX(i-1) * 100;
            
        end
        
        
    end
end

try
disp([length(aboves),length(unders)])
catch
end

clSort = sortrows(characteristic.aboves.close',-1);

found = [];
for i = 1:20
    found(end+1) = find(clSort(i) == characteristic.aboves.close');
end




field = fieldnames(characteristic.aboves);

for j = 1:length(field)
    
    figure(j)
    hold on;
    
    plot(1,characteristic.aboves.(field{j}), 'go')
    plot(1,mean(characteristic.aboves.(field{j})), 'bx')
    plot(1,mean(characteristic.aboves.(field{j})(found)), 'bo')
    text(1,mean(characteristic.aboves.(field{j})), num2str(mean(characteristic.aboves.(field{j}))))
    text(1,mean(characteristic.aboves.(field{j})(found)), num2str(mean(characteristic.aboves.(field{j})(found))))
    
    plot(2,characteristic.unders.(field{j}), 'ro')
    plot(2,mean(characteristic.unders.(field{j})(~isnan(characteristic.unders.(field{j})))), 'bx')
    text(2,mean(characteristic.unders.(field{j})), num2str(mean(characteristic.unders.(field{j}))))
    
    xlim([0,3])
    title(field(j))
    
    
end


figure(j+1)


subplot(numPlots,1,[1:2])
cla
candle(ta.hi.STOCK, ta.lo.STOCK, ta.cl.STOCK, ta.op.STOCK, 'blue');
hold on
plot(ta.clSma,'b')
plot(aboves(:,1), aboves(:,2),'gx')
plot(unders(:,1), unders(:,2),'rx')
plot(aboves(found,1), aboves(found,2), 'cx')

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
hold on
plot(ta.nineperma.STOCK,'r')
plot(ta.macdvec.STOCK, 'b')
% bar(ta.vo.INDX)
% hold on
% plot(xlim, [mean(ta.vo.INDX), mean(ta.vo.INDX)])



trackTradesB = [[diff(trackTrades(:,1));nan], trackTrades(:,1)];
trackTradesB = [trackTradesB, trackTradesB(:,1) == 1];


store = [];
for i = 2:size(trackTradesB,1)-1
    
    if trackTradesB(i,3) == 1 &&  trackTradesB(i-1,3) == 0
        store = [store; trackTrades(i,2), nan];
    end
    
    if trackTradesB(i,3) == 0 && trackTradesB(i-1,3) == 1
        store(end,2) = trackTrades(i,3);
    end 
    
    
end
% store = [nan; store; nan];

store(:,3) = (store(:,2) - store(:,1)) ./ store(:,1) * 100;
sum(store(~isnan(store(:,3)),3))


if VIEW == 0
    return
end

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
    hold on
    plot(ta.nineperma.STOCK,'r')
    plot(ta.macdvec.STOCK, 'b')
    
%     subplot(numPlots,1,5)
%     cla
%     bar(ta.vo.INDX)

%     hold on
%     plot(xlim, [mean(ta.vo.INDX), mean(ta.vo.INDX)])
    
    
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
        
    end 
    
    pause(10/100);
    
end













