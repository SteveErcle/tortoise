function data = IntraDayStockData(symbol, stockexchange, interval, prevdays)
%% IntraDayStockData pulls intraday stock price from Google.
%
% Input:
%       symbol - stock symbol
%       stockexchange - the market that the stock is traded in
%       interval - (optional) frequency of the data in seconds, for example:
%                       '60' - for 60 seconds (default).
%                      '120' - for 120 seconds.
%       prevdays - (optional) range of the data, for example:
%                        '1d' - for 1 day
%                        '15d' - for 15 days (default)
%       see the references for more info on the inputs.
%
% Output:
%       data.close
%       data.high
%       data.low
%       data.volume
%       data.date
%       data.datestring
%
% Example:
%       %getting stock data of last trading day
%       jpm = IntraDayStockData('JPM','NYSE','60','1d');
%
%       %plot stock price
%       plot(jpm.date,jpm.close,'b-'); hold on;
%       plot(jpm.date,jpm.high,'r-'); hold on;
%       plot(jpm.date,jpm.low,'g-');
%
%       %replace x-axis of stock price plot with "hh:mm AM/PM" tick format
%       datetick('x',16);
%


%initialize elements of the call url
stockexchange = 'NYSE';
data.symbol = upper(symbol);
data.stockexchange = upper(stockexchange);
if nargin < 3,
    data.interval = '60';
    data.prevdays = '15d';
else
    data.interval = interval;
    data.prevdays = prevdays;
end
data.field = 'd,c,h,l,v';

%build and call url then save data in a temporary csv file.

catchFlag = 0;

try
    f = urlwrite(['http://www.google.com/finance/getprices?q=',data.symbol,'&x=',...
        data.stockexchange,'&i=',data.interval,'&p=',data.prevdays,'&f=',data.field],'tempStockPrice.csv');
    googledata = importdata(f);
    data.close = googledata.data(:,1);
catch
    catchFlag = 1;
    data.stockexchange = 'NASDAQ';
end

if catchFlag == 1
    try
        f = urlwrite(['http://www.google.com/finance/getprices?q=',data.symbol,'&x=',...
            data.stockexchange,'&i=',data.interval,'&p=',data.prevdays,'&f=',data.field],'tempStockPrice.csv');
        googledata = importdata(f);
        data.close = googledata.data(:,1);
    catch
        catchFlag = 2;
        data.stockexchange = 'NYSEMKT';
    end
end

if catchFlag == 2
    try
        f = urlwrite(['http://www.google.com/finance/getprices?q=',data.symbol,'&x=',...
            data.stockexchange,'&i=',data.interval,'&p=',data.prevdays,'&f=',data.field],'tempStockPrice.csv');
        googledata = importdata(f);
        data.close = googledata.data(:,1);
    catch
        catchFlag = 3;
        data.stockexchange = 'NYSEARCA';
    end
end

if catchFlag == 3
    try
        f = urlwrite(['http://www.google.com/finance/getprices?q=',data.symbol,'&x=',...
            data.stockexchange,'&i=',data.interval,'&p=',data.prevdays,'&f=',data.field],'tempStockPrice.csv');
        googledata = importdata(f);
        data.close = googledata.data(:,1);
    catch
    end
end




%import data from csv file
googledata = importdata(f);
data.close = googledata.data(:,1);
data.high = googledata.data(:,2);
data.low = googledata.data(:,3);
data.volume = googledata.data(:,4);

%get unix time
unixtime=googledata.textdata(8:end);

%convert unix to date strings
data.datestring = cell([numel(unixtime),1]);
for i = 1:numel(unixtime),
    temp = cell2mat(unixtime(i));
    if strcmp(temp(1),'a'),
        absolutetime = str2double(temp(2:end));
        data.datestring(i) = {epoch2date(absolutetime)};
    else
        data.datestring(i) = {epoch2date(absolutetime + str2double(temp)*str2double(data.interval))};
    end
end

%convert date strings to datenums
data.date = datenum(data.datestring,'mm/dd/yyyy HH:MM:SS');

%delete csv file
delete('tempStockPrice.csv');

function [date_str] = epoch2date(epochTime)
% converts unix time to familiar date string
% import java classes
import java.lang.System;
import java.text.SimpleDateFormat;
import java.util.Date;
% convert current system time if no input arguments
if (~exist('epochTime','var'))
    epochTime = System.currentTimeMillis/1000;
end
% convert epoch time (Date requires milliseconds)
jdate = Date(epochTime*1000);
% format text and convert to cell array
sdf = SimpleDateFormat('MM/dd/yyyy HH:mm:ss');
date_str = sdf.format(jdate);
date_str = char(cell(date_str));
