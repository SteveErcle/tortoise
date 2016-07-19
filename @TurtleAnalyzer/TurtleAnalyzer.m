classdef TurtleAnalyzer < handle
    
    properties
        
        tf = TurtleFun;
        
    end
    
    methods
        
        function beta = calcBeta(obj, dAll ,dAvg)
            
            cl = dAll(:,7);
            clD = dAvg(:,7);
            
            perCl = [];
            perClD = [];
            
            for i = 1:size(cl)-1
                perCl = [perCl; (cl(i) - cl(i+1)) / cl(i+1)*100];
                perClD = [perClD; (clD(i) - clD(i+1)) / clD(i+1)*100];
            end
            
            beta = cov(perCl, perClD) / var(perClD);
            beta = beta(1,2);
            
        end
        
        function [ScbS, SioS, SroS] = getMovingAvgs(obj, stockData, avgData, window_size, beta)
            
            Idx = avgData(:,2:5);
            Scb = stockData(:,2:5);
            
            per = [];
            
            for i = size(Idx,1) - 1 : -1 : 1
                per = [per; beta * ((Idx(i,:) - Idx(i+1,:)) ./ Idx(i+1,:))];
            end
            per = flipud(per);
            
            Sio = zeros(size(Scb));
            Sio(end,:) = Scb(end,:);
            
            for i = size(Idx,1) - 1 : -1 : 1
                Sio(i,:) = Sio(i+1,:).*(per(i,:)+1);
            end
            
            Sro = Scb(end) + (Scb - Sio);
            
            ScbS = flipud(tsmovavg(flipud(Scb(:,4)),'e',window_size,1));
            SioS = flipud(tsmovavg(flipud(Sio(:,4)),'e',window_size,1));
            SroS = flipud(tsmovavg(flipud(Sro(:,4)),'e',window_size,1));
            
            
        end
        
        function [RSI, RSIma] = getRSI(obj, stockData, avgData, window_size)
            
            cl = stockData(:,5);
            clD = avgData(:,5);
            
            RSI = (cl./clD)*100;
            RSI = (RSI - min(RSI)) ./ range(RSI);
            RSIma = flipud(tsmovavg(flipud(RSI),'e',window_size,1));
            
        end
        
        function [stockStandardCl, avgStandardCl, rawStandardCl] = getStandardized(obj, stockData, avgData, window_size)
            
            stockStandardCl = (stockData(:,5) - mean(stockData(:,5))) ./ std(stockData(:,5));
            avgStandardCl = (avgData(:,5) - mean(avgData(:,5))) ./ std(avgData(:,5));
            %             rawStandardCl = stockStandardCl(end) + (stockStandardCl - avgStandardCl);
            
            stockStandardCl = flipud(tsmovavg(flipud(stockStandardCl),'e',window_size,1));
            avgStandardCl = flipud(tsmovavg(flipud(avgStandardCl),'e',window_size,1));
            %             rawStandardCl = flipud(tsmovavg(flipud(rawStandardCl),'e',window_size,1));
            
            cl = stockData(:,5);
            clD = avgData(:,5);
            
            rawStandardCl = (cl./clD)*100;
            rawStandardCl = (rawStandardCl - mean(rawStandardCl)) ./ std(rawStandardCl);
            rawStandardCl = flipud(tsmovavg(flipud(rawStandardCl),'e',window_size,1));
            
        end
        
        function [R] = getCorr(obj, stockData, avgData, window_size)
            
            len = window_size;
            
            cl = stockData(:,5);
            clD = avgData(:,5);
            
            R = [];
            
            clx = flipud(cl);
            clDy = flipud(clD);
            for  i = 1:length(cl)
                if i-len+1 >= 1
                    x = clx(i-len+1:i);
                    y = clDy(i-len+1:i);
                    cc =  corrcoef(x,y);
                    R = [R; cc(1,2)];
                else
                    R = [R; NaN];
                end
            end
            
            %             R = padarray(R, length(cl) - length(R), 'post');
            %             R(R == 0) = NaN;
            R = flipud(R);
            
            R(1:end-len+1) = (R(1:end-len+1) - min(R(1:end-len+1))) ./ range(R(1:end-len+1));
        end
        
        function [dateOnPlot] = getDate(obj)
            
            h = gcf;
            axesObjs = get(h, 'Children');
            axesObjs = findobj(axesObjs, 'type', 'axes');
            dataTips = findall(axesObjs, 'Type', 'hggroup', 'HandleVisibility', 'off');
            
            if length(dataTips) > 0
                cursor = datacursormode(gcf);
                dateOnPlot = cursor.CurrentDataCursor.getCursorInfo.Position(1)
                value = cursor.CurrentDataCursor.getCursorInfo.Position(2)
                
                delete(dataTips);
            end
            
        end
        
        function [clSma, clAma, clRma] = getMovingStandard(obj, stockData, avgData, window_size, isFlip)
            
            if size(stockData, 2) > 1
                stockData = stockData(:, 5);
                avgData  = avgData(:, 5);
            end 
            
            cap = min([length(stockData), length(avgData)]);
            stockData = stockData(1:cap);
            avgData = avgData(1:cap);
            
            clSs = (stockData - mean(stockData)) ./ std(stockData);
            clAs = (avgData - mean(avgData)) ./ std(avgData);
            %             clRs = clSs + (clSs - clAs);
            
            clRs = clSs - clAs;
%             clRs = ((stockData)./avgData)*100;
%             clRs = (clRs - mean(clRs)) ./ std(clRs);
            
            
            
            clS = stockData;
            clA = avgData;
%             clA = clAs.*std(clS)+mean(clS);
            clR = clRs.*std(clS)+mean(clS);
            
            clR = stockData./avgData;
            
            if isFlip
                clSma = flipud(tsmovavg(flipud(clS),'e',window_size,1));
                clAma = flipud(tsmovavg(flipud(clA),'e',window_size,1));
                clRma = flipud(tsmovavg(flipud(clR),'e',window_size,1));
            else
                clSma = tsmovavg(clS,'e',window_size,1);
                clAma = tsmovavg(clA,'e',window_size,1);
                clRma = tsmovavg(clR,'e',window_size,1);
            end
            
            
        end
        
        function prelimLevels = getLevels(obj, stockData)
            
            stockData = stockData(~isnan(stockData));
            per = std(stockData)/mean(stockData)/100;
            perP = 1 + per;
            perN = 1 - per;
            bester = [];
            
            for yline = min(stockData) : range(stockData)/25 : max(stockData)
                
                storeR = [];
                storeS = [];
                
                for i = 2:length(stockData)-1
                    
                    if stockData(i-1) <= yline*perP & stockData(i) <= yline*perP & stockData(i+1) <= yline*perP...
                            & stockData(i) >= yline*perN
                        storeR = [storeR; i];
                    end
                    
                    if stockData(i-1) >= yline*perN & stockData(i) >= yline*perN & stockData(i+1) >= yline*perN...
                            & stockData(i) <= yline*perP
                        storeS = [storeS; i];
                    end
                    
                end
                
                bester = [bester; length(storeR) + length(storeS), yline];
                
            end
            
            bester = sortrows(bester,-1)
            prelimLevels = bester(1:3,2);
            
            %             [hiD.(stock), loD.(stock), clD.(stock), opD.(stock), daD.(stock)] = obj.tf.returnOHLCDarray(dAll.(stock)(2:end,:));
            %             candle(hiD.(stock), loD.(stock), clD.(stock), opD.(stock), 'blue', daD.(stock));
            %             title({stock});
            %
            %
            %             hold on
            %             xlimit = xlim;
            %             for i = 1:3
            %                 plot([xlimit(1), xlimit(2)], [bester(i,2), bester(i,2)]);
            %             end
            %
            %             return
            %             % % % %
            
        end
        
        function voAvg = getVoAvg(obj, vo)
            
            voAvg = [];
            voAvg.STOCK = [];
            voAvg.INDX = [];
            
            for i = 1:length(vo.STOCK)
                
                voAvg.STOCK = [voAvg.STOCK; mean(vo.STOCK(~isnan(vo.STOCK(1:i))))];
                voAvg.INDX = [voAvg.INDX; mean(vo.INDX(~isnan(vo.INDX(1:i))))];
                
            end 
     
        end
        
        function atrAvg = getAtrAvg(obj, atr, hi, lo, cl)
            
            atrAvg = [];
            atrAvg.STOCK = [];
            atrAvg.INDX = [];
            
            for i = 1:length(cl.STOCK)
                
                atrAvg.STOCK = [atrAvg.STOCK; mean(atr.STOCK(1:i))];
                atrAvg.INDX = [atrAvg.INDX; mean(atr.INDX(1:i))];
                
            end
 
        end
        
        function percentDiff = percentDifference(obj, first, second)
            
            percentDiff =  (second - first) ./ first * 100;
            
        end
        
        
        
    end
    
end
