classdef TurtleAuto < handle
    
    
    properties
        
        hi; lo; op; cl; vo; da;
        
        macdvec;
        nineperma;
        RSIderv
        
        B;
        
        upper;
        
        condition;
        
        ind;
        
        tradeLen;
        enterPrice;
        enterMarket;
        stopLoss;
        trades;
        
        slPercentFirst = 0.75; slPercentSecond = 0.25;
        sgPercent;
        
        tAnalyze = TurtleAnalyzer;
        
        rsi;
        vwap;
        
        clSma; clAma; clRma;
        clSmaLarge; clAmaLarge; clRmaLarge;
        
        stock;
        enteredStock;
        
        voAvg;
        atrAvg;
        atr;
        levelCheck;
        levelPercent = 0.5;
        
        stand;
        
    end
    
    methods
        
        function obj = TurtleAuto()
            
            obj.stopLoss.BULL = NaN;
            obj.tradeLen.BULL = 0;
            obj.enterPrice.BULL = NaN;
            obj.enterMarket.BULL = 0;
            obj.trades.BULL = [];
            obj.condition.Trying_to_Enter.BULL = 0;
            
            
            obj.stopLoss.BEAR = NaN;
            obj.tradeLen.BEAR = 0;
            obj.enterPrice.BEAR = NaN;
            obj.enterMarket.BEAR = 0;
            obj.trades.BEAR = [];
            obj.condition.Trying_to_Enter.BEAR = 0;
            
            
        end
        
        function organizeDataIB(obj, ib_stock, ib_indx)
            
            td = TurtleData;
            [daIB, opIB, hiIB, loIB, clIB, voIB] = td.organizeDataIB(ib_stock);
            obj.hi.STOCK = hiIB;
            obj.lo.STOCK = loIB;
            obj.op.STOCK = opIB;
            obj.cl.STOCK = clIB;
            obj.vo.STOCK = voIB;
            obj.da.STOCK = daIB;
            
            [daIB, opIB, hiIB, loIB, clIB, voIB] = td.organizeDataIB(ib_indx);
            obj.hi.INDX = hiIB;
            obj.lo.INDX = loIB;
            obj.op.INDX = opIB;
            obj.cl.INDX = clIB;
            obj.vo.INDX = voIB;
            obj.da.INDX = daIB;
            
        end
        
        function organizeDataGoog(obj, goog_stock, goog_indx, range)
            
            obj.hi.STOCK = goog_stock.high(range);
            obj.lo.STOCK = goog_stock.low(range);
            obj.op.STOCK = goog_stock.open(range);
            obj.cl.STOCK = goog_stock.close(range);
            obj.vo.STOCK = goog_stock.volume(range);
            obj.da.STOCK = goog_stock.date(range);
            
            obj.hi.INDX = goog_indx.high(range);
            obj.lo.INDX = goog_indx.low(range);
            obj.op.INDX = goog_indx.open(range);
            obj.cl.INDX = goog_indx.close(range);
            obj.vo.INDX = goog_indx.volume(range);
            obj.da.INDX = goog_indx.date(range);
            
        end
        
        function setStock(obj, stock)
            
            obj.stock = stock;
            
        end
        
        function checkConditionsUsingInd(obj)
            
            for i_not_in_use = 1:1
                
                if  obj.nineperma.STOCK(obj.ind) < obj.macdvec.STOCK(obj.ind) && obj.nineperma.INDX(obj.ind) < obj.macdvec.INDX(obj.ind)
                    obj.condition.MACD_bull_cross = 1;
                else
                    obj.condition.MACD_bull_cross = 0;
                end
                
                if  obj.nineperma.STOCK(obj.ind) > obj.macdvec.STOCK(obj.ind) && obj.nineperma.INDX(obj.ind) > obj.macdvec.INDX(obj.ind)
                    obj.condition.MACD_bear_cross = 1;
                else
                    obj.condition.MACD_bear_cross = 0;
                end
                
                
                if obj.enterMarket.BULL == 1 || sign(obj.macdvec.STOCK(obj.ind)) == sign(obj.macdvec.INDX(obj.ind))
                    obj.condition.MACD_Positive.BULL = 1;
                else
                    obj.condition.MACD_Positive.BULL = 0;
                end
                
                if obj.enterMarket.BEAR == 1 || sign(obj.macdvec.STOCK(obj.ind)) == sign(obj.macdvec.INDX(obj.ind))
                    obj.condition.MACD_Negative.BEAR = 1;
                else
                    obj.condition.MACD_Negative.BEAR = 0;
                end
                
                
                if obj.RSIderv(obj.ind) > 0
                    obj.condition.RSI_to_indx.BULL = 1;
                else
                    obj.condition.RSI_to_indx.BULL = 0;
                end
                
                if obj.RSIderv(obj.ind) < 0
                    obj.condition.RSI_to_indx.BEAR = 1;
                else
                    obj.condition.RSI_to_indx.BEAR = 0;
                end
                
                
                if obj.enterMarket.BULL == 1 || obj.rsi.STOCK(obj.ind) <= 50
                    obj.condition.RSI_to_stock.BULL = 1;
                else
                    obj.condition.RSI_to_stock.BULL = 0;
                end
                
                if obj.enterMarket.BEAR == 1 || obj.rsi.STOCK(obj.ind) >= 50
                    obj.condition.RSI_to_stock.BEAR = 1;
                else
                    obj.condition.RSI_to_stock.BEAR = 0;
                end
                
                
                if obj.B.STOCK(obj.ind) >= 0.000 && obj.B.INDX(obj.ind) >= 0.005
                    obj.condition.MACD_bull_derv = 1;
                else
                    obj.condition.MACD_bull_derv = 0;
                end
                
                if obj.B.STOCK(obj.ind) <= -0.000 && obj.B.INDX(obj.ind) <= -0.005
                    obj.condition.MACD_bear_derv = 1;
                else
                    obj.condition.MACD_bear_derv = 0;
                end
                
                if obj.enterMarket.BULL == 1 || obj.cl.STOCK(obj.ind) < obj.vwap(end)
                    obj.condition.vwap.BULL = 1;
                else
                    obj.condition.vwap.BULL = 0;
                end
                
                if obj.enterMarket.BEAR == 1 || obj.cl.STOCK(obj.ind) > obj.vwap(end)
                    obj.condition.vwap.BEAR = 1;
                else
                    obj.condition.vwap.BEAR = 0;
                end
                
                
                
                
                
                if  obj.enterMarket.BULL || ((obj.cl.STOCK(obj.ind) - obj.clSma(obj.ind))/obj.clSma(obj.ind))*100 <= obj.levelPercent...
                        %&& obj.lo.STOCK(obj.ind) >= obj.clSma(obj.ind)
                    obj.condition.No_Cross_MA.BULL = 1;
                else
                    obj.condition.No_Cross_MA.BULL = 0;
                end
                
                if  obj.enterMarket.BEAR || ((obj.cl.STOCK(obj.ind) - obj.clSma(obj.ind))/obj.clSma(obj.ind))*100 <= -obj.levelPercent...
                        %&& obj.hi.STOCK(obj.ind) <= obj.clSma(obj.ind)
                    obj.condition.No_Cross_MA.BEAR = 1;
                else
                    obj.condition.No_Cross_MA.BEAR = 0;
                end
                
                
                %             if ~obj.enterMarket.BULL...
                %                     && (obj.condition.Trying_to_Enter.BULL == 1) %&& obj.levelCheck.currentWithinMA.BULL)
                %                 obj.condition.Allowed_to_Enter.BULL = 1;
                %             else
                %                 obj.condition.Allowed_to_Enter.BULL = 0;
                %             end
                %
                %             if ~obj.enterMarket.BEAR...
                %                     && (obj.condition.Trying_to_Enter.BEAR == 1) %&& obj.levelCheck.currentWithinMA.BEAR)
                %                 obj.condition.Allowed_to_Enter.BEAR = 1;
                %             else
                %                 obj.condition.Allowed_to_Enter.BEAR = 0;
                %             end
                
                
                
            end
            
            if obj.lo.STOCK(obj.ind) <= obj.stopLoss.BULL
                obj.condition.Not_Stopped_Out.BULL = 0;
            else
                obj.condition.Not_Stopped_Out.BULL = 1;
            end
            
            if obj.hi.STOCK(obj.ind) >= obj.stopLoss.BEAR
                obj.condition.Not_Stopped_Out.BEAR = 0;
            else
                obj.condition.Not_Stopped_Out.BEAR = 1;
            end
            
            
            if (obj.enterMarket.BULL == 1 || obj.enterMarket.BEAR) || ...
                    ((obj.vo.STOCK(obj.ind) > 1.0*obj.voAvg.STOCK(obj.ind-1) ||...
                    obj.vo.STOCK(obj.ind-1) > 1.0*obj.voAvg.STOCK(obj.ind-2))...
                    && (obj.vo.INDX(obj.ind) > 1.0*obj.voAvg.INDX(obj.ind-1) ||...
                    obj.vo.INDX(obj.ind-1) > 1.0*obj.voAvg.INDX(obj.ind-2)))...
                    
                obj.condition.Large_Volume = 1;
            else
                obj.condition.Large_Volume = 0;
            end
            
            
            if obj.enterMarket.BULL
                if obj.cl.STOCK(obj.ind) > obj.clSma(obj.ind) && obj.cl.INDX(obj.ind) > obj.clAma(obj.ind)
                    obj.condition.Above_MA.BULL = 1;
                else
                    obj.condition.Above_MA.BULL = 0;
                end
            else
                obj.condition.Above_MA.BULL = 1;
            end
            
            if obj.enterMarket.BEAR
                if  obj.cl.STOCK(obj.ind) < obj.clSma(obj.ind) && obj.cl.INDX(obj.ind) < obj.clAma(obj.ind)
                    obj.condition.Below_MA.BEAR = 1;
                else
                    obj.condition.Below_MA.BEAR = 0;
                end
            else
                obj.condition.Below_MA.BEAR = 1;
            end
            
            
            if ~obj.enterMarket.BULL
                if  obj.cl.STOCK(obj.ind-1) > obj.clSma(obj.ind-1) && obj.cl.INDX(obj.ind-1) > obj.clAma(obj.ind-1)*(1+obj.levelPercent/100)...
                        %&& obj.cl.STOCK(obj.ind) < obj.clSma(obj.ind) && obj.cl.INDX(obj.ind) > obj.clSma(obj.ind)
                    obj.condition.Above_MA_prev.BULL = 1;
                else
                    obj.condition.Above_MA_prev.BULL = 0;
                end
            else
                obj.condition.Above_MA_prev.BULL = 1;
            end
            
            if ~obj.enterMarket.BEAR
                if  obj.cl.STOCK(obj.ind-1) < obj.clSma(obj.ind-1) && obj.cl.INDX(obj.ind-1) < obj.clAma(obj.ind-1)*(1-obj.levelPercent/100)...
                        %&& obj.cl.STOCK(obj.ind) > obj.clSma(obj.ind) && obj.cl.INDX(obj.ind) < obj.clSma(obj.ind)
                    obj.condition.Below_MA_prev.BEAR = 1;
                else
                    obj.condition.Below_MA_prev.BEAR = 0;
                end
            else
                obj.condition.Below_MA_prev.BEAR = 1;
            end
            
            
            
            if ~obj.enterMarket.BULL || ~obj.enterMarket.BEAR
                if  obj.atr.STOCK(obj.ind-1) > 1.0*obj.atrAvg.STOCK(obj.ind-1) %&&  obj.atr.INDX(obj.ind-1) > 1.0*obj.atrAvg.INDX(obj.ind-1)
                    obj.condition.Large_ATR = 1;
                else
                    obj.condition.Large_ATR = 0;
                end
            else
                obj.condition.Large_ATR = 1;
            end
            
            
            
            if obj.enterMarket.BULL || obj.lo.STOCK(obj.ind) <= obj.clSma(obj.ind-1)*(1+obj.levelPercent/100)
                obj.condition.dip_MA.BULL = 1;
            else
                obj.condition.dip_MA.BULL = 0;
            end
            
            if obj.enterMarket.BEAR || obj.hi.STOCK(obj.ind) >= obj.clSma(obj.ind-1)*(1-obj.levelPercent/100)
                obj.condition.dip_MA.BEAR = 1;
            else
                obj.condition.dip_MA.BEAR = 0;
            end
            
            
            if obj.enterMarket.BULL || obj.op.STOCK(obj.ind) > obj.clSma(obj.ind-1)*(1+0.7/100)
                obj.condition.open_MA.BULL = 1;
            else
                obj.condition.open_MA.BULL = 0;
            end
            
            if obj.enterMarket.BEAR || obj.op.STOCK(obj.ind) < obj.clSma(obj.ind-1)*(1-0.7/100)
                obj.condition.open_MA.BEAR = 1;
            else
                obj.condition.open_MA.BEAR = 0;
            end
            
            
            if obj.enterMarket.BULL || obj.cl.STOCK(obj.ind-1) > obj.op.STOCK(obj.ind-1) && obj.cl.INDX(obj.ind-1) > obj.op.INDX(obj.ind-1)
                obj.condition.candle.BULL = 1;
            else
                obj.condition.candle.BULL = 0;
            end
            
            if obj.enterMarket.BULL || obj.cl.STOCK(obj.ind-1) < obj.op.STOCK(obj.ind-1) && obj.cl.INDX(obj.ind-1) < obj.op.INDX(obj.ind-1)
                obj.condition.candle.BEAR = 1;
            else
                obj.condition.candle.BEAR = 0;
            end
            
            
            if obj.enterMarket.BULL...
                    || (obj.levelCheck.checkMA.BULL && obj.levelCheck.withinMA.BULL)
                obj.condition.Within_Level.BULL = 1;
            else
                obj.condition.Within_Level.BULL = 0;
            end
            
            if obj.enterMarket.BEAR...
                    || (obj.levelCheck.checkMA.BEAR && obj.levelCheck.withinMA.BEAR)
                obj.condition.Within_Level.BEAR = 1;
            else
                obj.condition.Within_Level.BEAR = 0;
            end
            
            
            if obj.stand.rebound(obj.ind) > obj.stand.rebound_ma(obj.ind)
                obj.condition.rebound.BULL = 1;
            else
                obj.condition.rebound.BULL = 0;
            end
            
            if obj.stand.rebound(obj.ind) < obj.stand.rebound_ma(obj.ind)
                obj.condition.rebound.BEAR = 1;
            else
                obj.condition.rebound.BEAR = 0;
            end
            
            
            if strcmp(datestr(obj.da.INDX(obj.ind),15), '15:50')
                obj.condition.Not_End_of_Day = 0;
            else
                obj.condition.Not_End_of_Day = 1;
            end
            
            if ~obj.enterMarket.BULL
                    obj.condition.Not_Gained_Out.BULL = 1;
            else
                if obj.hi.STOCK(obj.ind) > obj.enterPrice.BULL*(1.00+obj.sgPercent/100)
                    obj.condition.Not_Gained_Out.BULL = 0;
                else
                    obj.condition.Not_Gained_Out.BULL = 1;
                end
            end
            
            if ~obj.enterMarket.BEAR
                obj.condition.Not_Gained_Out.BEAR = 1;
            else
                if obj.lo.STOCK(obj.ind) < obj.enterPrice.BEAR*(1.00-obj.sgPercent/100)
                    obj.condition.Not_Gained_Out.BEAR = 0;
                else
                    obj.condition.Not_Gained_Out.BEAR = 1;
                end
            end
            
        end
        
        function calculateData(obj, isFlip)
            
            [obj.macdvec.STOCK, obj.nineperma.STOCK] = macd(obj.cl.STOCK);
            [obj.macdvec.INDX, obj.nineperma.INDX] = macd(obj.cl.INDX);
            
            [obj.clSma, obj.clAma, obj.clRma] = obj.tAnalyze.getMovingStandard(obj.cl.STOCK, obj.cl.INDX, 12, isFlip);
            
            %%%%%% TRY ENTER IN ON 26 AND EXIT ON 12
            
            obj.RSIderv = [NaN; diff(obj.clRma)];
            
            obj.B.STOCK = [NaN; diff(obj.macdvec.STOCK)];
            obj.B.INDX  = [NaN; diff(obj.macdvec.INDX)];
            
            obj.rsi.STOCK = rsindex(obj.cl.STOCK);
            
            obj.vwap = getVWAP(obj.cl.STOCK, obj.vo.STOCK, obj.da.STOCK);
            
            [obj.voAvg] = obj.tAnalyze.getVoAvg(obj.vo);
            
            obj.atr.STOCK = indicators([obj.hi.STOCK, obj.lo.STOCK, obj.cl.STOCK],'atr',1);
            obj.atr.INDX  = indicators([obj.hi.INDX, obj.lo.INDX, obj.cl.INDX],'atr',1);
            
            [obj.atrAvg] = obj.tAnalyze.getAtrAvg(obj.atr, obj.hi, obj.lo, obj.cl);
            
            obj.levelCheck.checkMA.BULL = obj.lo.STOCK(obj.ind-1) >= obj.clSma(obj.ind-1)...
                && obj.lo.STOCK(obj.ind-2) >= obj.clSma(obj.ind-2);
            
            obj.levelCheck.withinMA.BULL = ((obj.lo.STOCK(obj.ind-1) - obj.clSma(obj.ind-1))/ obj.clSma(obj.ind-1)) <= (obj.levelPercent/100)...
                || ((obj.lo.STOCK(obj.ind-2) - obj.clSma(obj.ind-2))/ obj.clSma(obj.ind-2)) <= obj.levelPercent/100;
            
            obj.levelCheck.currentWithinMA.BULL = ((obj.lo.STOCK(obj.ind) - obj.clSma(obj.ind-1))/ obj.clSma(obj.ind-1)) <= obj.levelPercent/100;
            
            obj.levelCheck.checkMA.BEAR = obj.hi.STOCK(obj.ind-1) <= obj.clSma(obj.ind-1)...
                && obj.hi.STOCK(obj.ind-2) <= obj.clSma(obj.ind-2);
            
            obj.levelCheck.withinMA.BEAR = (obj.clSma(obj.ind-1) - obj.hi.STOCK(obj.ind-1))/ obj.clSma(obj.ind-1) <= (obj.levelPercent/100)...
                || (obj.clSma(obj.ind-2) - obj.hi.STOCK(obj.ind-2))/ obj.clSma(obj.ind-2) <= obj.levelPercent/100;
            
            obj.levelCheck.currentWithinMA.BEAR = (obj.clSma(obj.ind-1)- obj.hi.STOCK(obj.ind))/ obj.clSma(obj.ind-1) <= obj.levelPercent/100;
            
            obj.stand.STOCK = (obj.cl.STOCK - mean(obj.cl.STOCK)) ./ std(obj.cl.STOCK);
            obj.stand.INDX = (obj.cl.INDX - mean(obj.cl.INDX)) ./ std(obj.cl.INDX);
            
            obj.stand.rebound = obj.stand.STOCK - obj.stand.INDX;
            obj.stand.rebound_ma = tsmovavg(obj.stand.rebound,'e',9,1);
            
        end
        
        function setStopLoss(obj, stopType)
            
            
            if obj.enterMarket.BULL == 1
                obj.tradeLen.BULL = length(obj.cl.STOCK) - obj.trades.BULL(end,3) + 1;
            end
            
            if obj.enterMarket.BEAR == 1
                obj.tradeLen.BEAR = length(obj.cl.STOCK) - obj.trades.BEAR(end,3) + 1;
            end
            
            
            if obj.tradeLen.BULL <= 1
                obj.stopLoss.BULL = obj.enterPrice.BULL*(1.00-obj.slPercentFirst/100);
            elseif obj.tradeLen.BULL == 2
                obj.stopLoss.BULL = obj.enterPrice.BULL*(1.00-obj.slPercentSecond/100);
            else
                
                if obj.lo.STOCK(end-2) > obj.stopLoss.BULL
                    if strcmp(stopType, 'follow')
                        obj.stopLoss.BULL = obj.lo.STOCK(end-2);
                    else
                        obj.stopLoss.BULL = obj.enterPrice.BULL;
                    end
                end
            end
            
            
            if obj.tradeLen.BEAR <= 1
                obj.stopLoss.BEAR = obj.enterPrice.BEAR*(1.00+obj.slPercentFirst/100);
            elseif obj.tradeLen.BEAR == 2
                obj.stopLoss.BEAR = obj.enterPrice.BEAR*(1.00+obj.slPercentSecond/100);
            else
                if  obj.hi.STOCK(end-2) < obj.stopLoss.BEAR
                    if strcmp(stopType, 'follow')
                        obj.stopLoss.BEAR = obj.hi.STOCK(end-2);
                    else
                        obj.stopLoss.BEAR = obj.enterPrice.BEAR;
                    end
                end
            end
            
        end
        
        function executeBullTrade(obj)
            
            if obj.condition.Not_Stopped_Out.BULL...
                    && obj.condition.Not_End_of_Day...
                    && obj.condition.Large_Volume...
                    && obj.condition.Above_MA.BULL...
                    && obj.condition.Above_MA_prev.BULL...
%                     && obj.condition.Not_Gained_Out.BULL...
            
%             if obj.condition.Not_Stopped_Out.BEAR...
%                     && obj.condition.Not_End_of_Day...
%                     && obj.condition.Large_Volume...
%                     && obj.condition.Below_MA.BEAR...
%                     && obj.condition.Below_MA_prev.BEAR...
                    
                
                
                
                %obj.condition.rebound.BULL...
                %&& obj.condition.dip_MA.BULL...
                %&& obj.condition.open_MA.BULL...
                %&& obj.condition.candle.BULL...
                %&& obj.condition.Large_ATR...
                %&& obj.condition.Within_Level.BULL...
                
                %&& obj.condition.No_Cross_MA.BULL...
                %&& obj.condition.MACD_bull_cross...
                %&& obj.condition.MACD_bull_derv...
                
                obj.upper = [obj.upper; obj.ind];
                
                if ~obj.enterMarket.BULL
                    
                    obj.enterPrice.BULL =  obj.cl.STOCK(end); %obj.clSma(obj.ind-1)*(1+obj.levelPercent/100); %
                    obj.trades.BULL = [obj.trades.BULL; obj.enterPrice.BULL, NaN, length(obj.cl.STOCK), NaN];
%                     obj.ind = obj.ind-1;
                    
                    obj.enterMarket.BULL = 1;
                    obj.enteredStock = obj.stock;
                    %obj.tradeLen.BULL = obj.tradeLen.BULL + 1;
                    %                     obj.tradeLen.BULL = length(obj.cl.STOCK) - obj.trades.BULL(end,3) + 1;
                    %%% CHANGED TRADELEN TRACKING
                end
                
            else
                
                if obj.enterMarket.BULL == 1
                    
                    if obj.condition.Not_Stopped_Out.BULL
%                         if ~obj.condition.Not_Gained_Out.BULL
%                             obj.trades.BULL(end,2) = obj.enterPrice.BULL*(1.00+obj.sgPercent/100);
%                         else 
%                             obj.trades.BULL(end,2) = obj.cl.STOCK(end);
%                         end 
                            
                        obj.trades.BULL(end,2) = obj.cl.STOCK(end);
                    else
                        if obj.op.STOCK(end) > obj.stopLoss.BULL
                            obj.trades.BULL(end,2) = obj.stopLoss.BULL;
                        else
                            obj.trades.BULL(end,2) = obj.op.STOCK(end);
                        end
                    end
                    
                    obj.trades.BULL(end,4) = length(obj.cl.STOCK);
                    
                    %obj.ind = obj.ind-1;
                    %%% ^^ DOES THIS ADD FUTUE KNOWLEDGE? ^^
                    
%                     obj.ind = obj.ind+1;
                end
                
                obj.enterMarket.BULL = 0;
                obj.enterPrice.BULL = NaN;
                obj.tradeLen.BULL = 0;
                obj.stopLoss.BULL = NaN;
                
                if ~obj.enterMarket.BEAR && ~obj.enterMarket.BULL
                    obj.enteredStock = [];
                end
                
            end
            
        end
        
        function executeBearTrade(obj)
            
            if obj.condition.Not_Stopped_Out.BEAR...
                    && obj.condition.Not_End_of_Day...
                    && obj.condition.Large_Volume...
                    && obj.condition.Below_MA.BEAR...
                    && obj.condition.Below_MA_prev.BEAR...
%                     && obj.condition.Not_Gained_Out.BEAR...
            
            
%             if obj.condition.Not_Stopped_Out.BULL...
%                     && obj.condition.Not_End_of_Day...
%                     && obj.condition.Large_Volume...
%                     && obj.condition.Above_MA.BULL...
%                     && obj.condition.Above_MA_prev.BULL...
                    
                
                %obj.condition.rebound.BEAR...
                %                     && obj.condition.dip_MA.BEAR...
                %                     && obj.condition.open_MA.BEAR...
                %                     && obj.condition.candle.BEAR...
                %&& obj.condition.Large_ATR...
                %&& obj.condition.Within_Level.BEAR...
                
                
                %&& obj.condition.MACD_bear_cross...
                %&& obj.condition.MACD_bear_derv...
                
                %&& obj.condition.No_Cross_MA.BEAR...
                
                
                if ~obj.enterMarket.BEAR
                    
                    obj.enterPrice.BEAR =  obj.cl.STOCK(end); %obj.clSma(obj.ind-1)*(1-obj.levelPercent/100);  %
                    obj.trades.BEAR = [obj.trades.BEAR; obj.enterPrice.BEAR, NaN, length(obj.cl.STOCK), NaN];
%                     obj.ind = obj.ind-1;
                    obj.enterMarket.BEAR = 1;
                    obj.enteredStock = obj.stock;
                    %obj.tradeLen.BEAR = obj.tradeLen.BEAR + 1;
                    %                    obj.tradeLen.BEAR = length(obj.cl.STOCK) - obj.trades.BEAR(end,3) + 1;
                    
                end
                
            else
                
                if obj.enterMarket.BEAR == 1
                    
                    if obj.condition.Not_Stopped_Out.BEAR
%                         if ~obj.condition.Not_Gained_Out.BEAR
%                             obj.trades.BEAR(end,2) = obj.enterPrice.BEAR*(1.00-obj.sgPercent/100);
%                         else
%                             obj.trades.BEAR(end,2) = obj.cl.STOCK(end);
%                         end 
                        obj.trades.BEAR(end,2) = obj.cl.STOCK(end);
                    else
                        if obj.op.STOCK(end) < obj.stopLoss.BEAR
                            obj.trades.BEAR(end,2) = obj.stopLoss.BEAR;
                        else
                            obj.trades.BEAR(end,2) = obj.op.STOCK(end);
                        end
                    end
                    
                    obj.trades.BEAR(end,4) = length(obj.cl.STOCK);
                    
                    %                     obj.ind = obj.ind-1;
%                     obj.ind = obj.ind+1;
                end
                
                obj.enterMarket.BEAR = 0;
                obj.enterPrice.BEAR = NaN;
                obj.tradeLen.BEAR = 0;
                obj.stopLoss.BEAR = NaN;
                
                if ~obj.enterMarket.BEAR && ~obj.enterMarket.BULL
                    obj.enteredStock = [];
                end
                
            end
            
        end
        
    end
    
end
