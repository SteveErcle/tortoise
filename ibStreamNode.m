% ibStream
clc; close all; clear all;

ib = ibtws('',7497);
pause(1)

tc = TurtleCall;
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

% load('equalLengthNasDaq');
% allStocks = equalLengthNasDaq(1:5);
% 
% contracts = [];
% for k = 1:length(allStocks)
%     
%     stock = allStocks{k};
% 
% ibContract.(stock) = ib.Handle.createContract;
% ibContract.(stock).symbol = stock;
% ibContract.(stock).secType = 'STK';
% ibContract.(stock).exchange = 'SMART';
% ibContract.(stock).currency = 'USD';
% 
% if k == 1
%     contracts = [contracts; ibContract.(stock)]
% else
%     contracts = {contracts; ibContract.(stock)}
% end
% 
% 
% 
% 
% end 


load('equalLengthNasDaq');
allStocks = equalLengthNasDaq(1);

stock = 'TSLA';
contracts = [];
ibContract.(stock) = ib.Handle.createContract;
ibContract.(stock).symbol = 'TSLA';
ibContract.(stock).secType = 'STK';
ibContract.(stock).exchange = 'SMART';
ibContract.(stock).primaryExchange = 'NASDAQ';
ibContract.(stock).currency = 'USD';

contracts = [contracts; ibContract.(stock)]


ibContract2 = ib.Handle.createContract;
ibContract2.symbol = 'SPY';
ibContract2.secType = 'STK';
ibContract2.exchange = 'SMART';
ibContract2.primaryExchange = 'NASDAQ';
ibContract2.currency = 'USD';

contracts = {contracts; ibContract2}

ibContract3 = ib.Handle.createContract;
ibContract3.symbol = 'FB';
ibContract3.secType = 'STK';
ibContract3.exchange = 'SMART';
ibContract3.primaryExchange = 'NASDAQ';
ibContract3.currency = 'USD';


contracts = [contracts; ibContract3]
% contracts = {ibContract.(stock);ibContract2;ibContract3};
return
f = '233';

tickerID = realtime(ib,contracts,f,...
    @(varargin)tc.ibStreamer(varargin{:}));


while(true)
    
    if ~isempty(tc.data)
        tc.data(:,1)
    end
    
   
    pause(1)
    
end


