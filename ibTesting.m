clc; close all; clear all;

% addpath('\\psf\Home\Documents\turtles\intraData')
% load('intraTSLA')
% load('intraSPY')
% 
% intraPreStock = ib_intra;
% 
% dailyDates = unique(floor(intraSPY(:,1)));
% intraSTOCK = [];
% intraINDX = [];
% 
% for i = 1:length(dailyDates)
%     
%     found = find(floor(intraPreStock(:,1)) == dailyDates(i));
%     
%     if ~isempty(found)
%         intraSTOCK = [intraSTOCK; intraPreStock(found,:)];
%         
%         found = find(floor(intraSPY(:,1)) == dailyDates(i));
%         intraINDX = [intraINDX; intraSPY(found,:)];
%         
%     end
%     
% end
% 
% mean(intraINDX(:,1) == intraSTOCK(:,1))
% 
% return
% 
% 
% 
% load('intraHBAN')
% datestr(ib_intra(1,1))
% datestr(ib_intra(end,1))
% length(ib_intra)
% 
% load('intraHYGS')
% datestr(ib_intra(1,1))
% datestr(ib_intra(end,1))
% length(ib_intra)
% 
% load('intraINFN')
% datestr(ib_intra(1,1))
% datestr(ib_intra(end,1))
% length(ib_intra)
% 
% load('intraTSLA')
% datestr(ib_intra(1,1))
% datestr(ib_intra(end,1))
% length(ib_intra)
% 
% 
% return

ib = ibtws('',7497);

pause(1)

ibBuiltInErrMsg

load('equalLengthNasDaq');
stock = equalLengthNasDaq{27};
stock = 'GOOG';

ibContract = ib.Handle.createContract;
ibContract.symbol = 'SPY';
ibContract.secType = 'STK';
ibContract.exchange = 'SMART';
ibContract.currency = 'USD';

startDateNum = now-300;
endDateNum   = now;

ib_day = timeseries(ib, ibContract, now-250, now-5, '1 day' , '', true);

% Convert date strings to date numbers

ib_day(:,1) = num2cell(datenum(ib_day(:,1),'yyyymmdd'));
ib_day = cell2mat(ib_day);

% Remove dates outside of request range
i = (ib_day(:,1) < min([startDateNum endDateNum]));
ib_day(i,:) = [];
i = (ib_day(:,1) > max([startDateNum endDateNum]));
ib_day(i,:) = [];

dailyDates = ib_day(:,1);

ibContract.symbol = stock;
ib_intra = [];
for i = 1:5:length(ib_day(:,1))
    
    ib_intra = [ib_intra; timeseries(ib, ibContract, dailyDates(i), dailyDates(i+4), '10 mins' , '', true)];
    datestr(dailyDates(i))
    datestr(dailyDates(i+4))
    pause(1)
end


fileName = strcat('intra',ibContract.symbol);
save(fileName,'ib_intra');


% tc = TurtleCall;
%
% f = findobj('Tag','IBStreamingDataWorkflow');
% if isempty(f)
%     f = figure('Tag','IBStreamingDataWorkflow','MenuBar','none',...
%         'NumberTitle','off')
%     pos = f.Position;
%     f.Position = [pos(1) pos(2) pos(3)+370 1090];
%     colnames = {'Trade','Size','Bid','BidSize','Ask','AskSize',...
%         'Total Volume'};
%     rownames = {'AAA','BBB','DDDD'};
%     data = cell(3,6);
%     streamer = uitable(f,'Data',data,'RowName',rownames,'ColumnName',colnames,...
%         'Position',[10 30 800 760],'Tag','SecurityDataTable')
%     uicontrol('Style','text','Position',[10 5 497 20],'Tag','IBMessage')
%     uicontrol('Style','pushbutton','String','Close',...
%         'Callback',...
%         'evalin(''base'',''close(ib);close(findobj(''''Tag'''',''''IBStreamingDataWorkflow''''));'')',...
%         'Position',[512 5 80 20])
% end
%
%
% ibContract1 = ib.Handle.createContract;
% ibContract1.symbol = 'TSLA';
% ibContract1.secType = 'STK';
% ibContract1.exchange = 'SMART';
% ibContract1.primaryExchange = 'NASDAQ';
% ibContract1.currency = 'USD';
%
%
% ibContract2 = ib.Handle.createContract;
% ibContract2.symbol = 'MSFT';
% ibContract2.secType = 'STK';
% ibContract2.exchange = 'SMART';
% ibContract2.primaryExchange = 'NASDAQ';
% ibContract2.currency = 'USD';
%
% ibContract3 = ib.Handle.createContract;
% ibContract3.symbol = 'FB';
% ibContract3.secType = 'STK';
% ibContract3.exchange = 'SMART';
% ibContract3.primaryExchange = 'NASDAQ';
% ibContract3.currency = 'USD';


% contracts = {ibContract1;ibContract2;ibContract3};
% f = '100';
%
% tickerID = realtime(ib,contracts,f,...
%                     @(varargin)tc.ibStreamer(varargin{:}));

% close(ib)




% return


% pause(1)
% %
% ibContract = ib.Handle.createContract;
%
%
% % ibContract.symbol = 'EUR';
% % ibContract.secType = 'CASH';
% % ibContract.exchange = 'IDEALPRO';
% % ibContract.currency = 'GBP';
%
% ibContract.symbol = 'TSLA';
% ibContract.secType = 'STK';
% ibContract.exchange = 'SMART';
% ibContract.primaryExchange = 'NASDAQ';
% ibContract.currency = 'USD';
%
%
% % f = '233';
% %
% % d = getdata(ib,ibContract)
% %
% % tickerid = realtime(ib,ibContract,f)
% %
% % pause(1)
% %
% %
% % ibBuiltInRealtimeData
%
%
% startdate = now-20;
% enddate = now;
% period = '20 mins';
% tickType = '';
%
%
% d = history(ib,ibContract,startdate,enddate,period,tickType,true)
