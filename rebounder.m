clc; close all; clear all;




td = TurtleData;
ta = TurtleAuto;
tAn = TurtleAnalyzer;

allData = td.pullData(23, '10d', '600');


% STANDARDIZE IN REAL TIME

field = fieldnames(allData);

allData.STOCK = allData.(field{2});


ta.ind = 50-1;
len = length(allData.STOCK.close)-1;

upper =[];
lower = [];

while ta.ind <= len
    
    ta.ind = ta.ind + 1;
    range = 1:ta.ind;
    
    ta.organizeDataGoog(allData.STOCK, allData.SPY, range);
    ta.calculateData(0);
    ta.checkConditionsUsingInd();
    
    window_size = 12;
    
    %     ma.STOCK = tsmovavg(ta.stand.STOCK,'e',window_size,1);
    %     ma.SPY = tsmovavg(ta.stand.INDX,'e',window_size,1);
    
    %     rebound = ta.stand.STOCK - ta.stand.INDX;
    %     ma.REBD = tsmovavg(rebound,'e',9,1);
    
    %     if rebound(ta.ind) > ma.REBD(ta.ind)
    if ta.condition.rebound.BULL
        upper = [upper; ta.ind];
    elseif ta.condition.rebound.BEAR
        lower  = [lower; ta.ind];
    end
    
end



B = [nan; diff(upper)];
setterUpper = [];
x = B;
z = find(x~= 1);
setterUpper = [];
for i = 1:length(z)-1
    setterUpper = [setterUpper; upper(z(i)), upper(z(i+1)-1)+1];
end 

B = [nan; diff(lower)];
setterLower = [];
x = B;
z = find(x~= 1);
setterLower = [];
for i = 1:length(z)-1
    setterLower = [setterLower; lower(z(i)), lower(z(i+1)-1)+1];
end 

figure
subplot(2,1,1)
hold 
candle(allData.STOCK.high, allData.STOCK.low, allData.STOCK.close, allData.STOCK.open, 'blue');

subplot(2,1,2)
hold on
plot(ta.stand.rebound, 'c')
plot(ta.stand.rebound_ma, 'k')


subplot(2,1,1)

for i = 1:size(setterUpper,1)
    
    xLo = setterUpper(i,1);
    xHi = setterUpper(i,2);
    ylimits = ylim;
    yLo = allData.STOCK.close(xLo);
    yHi = allData.STOCK.close(xHi);
    
    xShort = [xLo xHi xHi xLo];
    yShort = [yLo yLo yHi yHi];
    
    hp = patch(xShort,yShort, 'c', 'FaceAlpha', 0.05);
    
end

for i = 1:size(setterLower,1)
    
    xLo = setterLower(i,1);
    xHi = setterLower(i,2);
    ylimits = ylim;
    yLo = allData.STOCK.close(xLo);
    yHi = allData.STOCK.close(xHi);
    
    xShort = [xLo xHi xHi xLo];
    yShort = [yLo yLo yHi yHi];
    
    hp = patch(xShort,yShort, 'm', 'FaceAlpha', 0.05);
    
end


roi.BULL = [];
for i = 1:size(setterUpper,1)
    
    
    first = allData.STOCK.close(setterUpper(i,1));
    second = allData.STOCK.close(setterUpper(i,2));
    
    if first == nan || second == nan
        i
    end 
    
    roi.BULL = [roi.BULL; -tAn.percentDifference(first, second)];
    
end 

roi.BEAR = [];
for i = 1:size(setterLower,1)
    
    
    first = allData.STOCK.close(setterLower(i,1));
    second = allData.STOCK.close(setterLower(i,2));
    
     if first == nan || second == nan
        i
    end 
    
    
    roi.BEAR = [roi.BEAR; tAn.percentDifference(first, second)];
    
end

disp([sum(roi.BULL), sum(roi.BEAR)])
    
    

apple_sauce = [54,57;63,65;66,69;73,80;81,96;97,102;106,108;110,113;115,119;129,135;136,154;178,180;187,189;192,198;201,204;206,209;214,216;235,241;271,273;274,281;282,284;299,301;314,316;322,324;332,340;341,346;350,352;353,355;356,358;359,364;372,376;378,380;381,383;390,394;396,398]
            
            
            
            
            