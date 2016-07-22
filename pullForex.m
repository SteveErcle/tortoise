try
    close(ib)
catch
end

clc; close all; clear all;


data = csvread('EURUSD.csv',0,2);

op = data(:,1);
hi = data(:,2);
lo = data(:,3);
cl = data(:,4);


interval = 10;
tenly.open = [];
tenly.high = [];
tenly.low = [];
tenly.close = [];

for i = 1:10:length(cl)-10
    
    range =  i:i+interval-1;
    
    tenly.open = [tenly.open; op(range(1))];
    tenly.high = [tenly.high; max(hi(range))];
    tenly.low = [tenly.low; min(lo(range))];
    tenly.close = [tenly.close; cl(range(end))];
    
    
end
        
tenly.date = zeros(length(tenly.close),1);
tenly.volume = zeros(length(tenly.close),1);

figure(i)
hold on;
candle(tenly.high, tenly.low, tenly.close, tenly.open, 'blue');



return
% ib = ibtws('',7497);
% pause(1)
% ibBuiltInErrMsg
% 
% 
% load('weeklyDates')
% startDate = weeklyDates(end-3)-4
% endDate   = weeklyDates(end-3)
% 
% 
% ibContract = ib.Handle.createContract;
% 
% ibContract.symbol = 'EUR';
% ibContract.secType = 'CASH';
% ibContract.exchange = 'IDEALPRO';
% ibContract.currency = 'USD';
% 
% % ibContract.secType = 'STK';
% % ibContract.exchange = 'SMART';
% % ibContract.currency = 'USD';
% % ibContract.symbol = 'SPY';
% 
% 
% data = history(ib, ibContract, startDate, endDate, '', '1 day')%, '30 mins' , '', true)
% % data(end-40:end)
% % if ~isnumeric(data.SPY(1))
% %     disp('Service Error')
% %     return
% % end

