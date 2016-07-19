classdef TurtleAutoRealTime < handle
    
    
    properties
        
        hi; lo; op; cl; vo; da;
        
        macdvec;
        nineperma;
        RSIderv
        
        B;
        
        condition;
        
        ind;
        
        tradeLen;
        enterPrice;
        enterMarket;
        stopLoss;
        trades;
        
        slPercentFirst = 0.75;
        slPercentSecond = 0.25;
        
        tAnalyze = TurtleAnalyzer;
        
        rsi;
        vwap;
        
        clSma;
        clAma;
        clRma;
        
        currentTime;
        lastTradeTime = nan;
        
        td = TurtleData;
        
        stock;
        enteredStock;
        
        cross_MA;
       
        voAvg;
        
    end
    
    methods
        
        function obj = TurtleAutoRealTime()
            
            obj.stopLoss.BULL = NaN;
            obj.tradeLen.BULL = 0;
            obj.enterPrice.BULL = NaN;
            obj.enterMarket.BULL = 0;
            obj.trades.BULL = [];
            obj.condition.Trying_to_Enter.BULL = 0;
            obj.cross_MA.BULL = nan;
            
            
            obj.stopLoss.BEAR = NaN;
            obj.tradeLen.BEAR = 0;
            obj.enterPrice.BEAR = NaN;
            obj.enterMarket.BEAR = 0;
            obj.trades.BEAR = [];
            obj.condition.Trying_to_Enter.BEAR = 0;
            obj.cross_MA.BEAR = nan;
            
            
        end
        
        function organizeDataIB(obj, ib_data, stockOrIndx)
            
            if size(ib_data,2) == 6
                nanPad = nan(size(ib_data,1),3);
                ib_data(:,7:9) = nanPad;
            end 
            
            if strcmp(stockOrIndx,'stock')
                
                [daIB, opIB, hiIB, loIB, clIB, voIB] = obj.td.organizeDataIB(ib_data);
                obj.hi.STOCK = hiIB;
                obj.lo.STOCK = loIB;
                obj.op.STOCK = opIB;
                obj.cl.STOCK = clIB;
                obj.vo.STOCK = voIB;
                obj.da.STOCK = daIB;
                
            elseif strcmp(stockOrIndx,'indx')
                [daIB, opIB, hiIB, loIB, clIB, voIB] = obj.td.organizeDataIB(ib_data);
                obj.hi.INDX = hiIB;
                obj.lo.INDX = loIB;
                obj.op.INDX = opIB;
                obj.cl.INDX = clIB;
                obj.vo.INDX = voIB;
                obj.da.INDX = daIB;
                
            else
                disp('Second argument must be string "stock" or "indx"')
                
            end
            
        end
        
        function setStock(obj, stock)
            
            obj.stock = stock;
            
        end 
        
        function checkConditions(obj)

            if obj.cl.STOCK(end) <= obj.stopLoss.BULL
                obj.condition.Not_Stopped_Out.BULL = 0;
            else
                obj.condition.Not_Stopped_Out.BULL = 1;
            end
            
            if obj.cl.STOCK(end) >= obj.stopLoss.BEAR
                obj.condition.Not_Stopped_Out.BEAR = 0;
            else
                obj.condition.Not_Stopped_Out.BEAR = 1;
            end
            
            
            if (obj.enterMarket.BULL == 1 || obj.enterMarket.BEAR) || ...
                    obj.vo.STOCK(end-1) > obj.voAvg ||...
                    obj.vo.STOCK(end-2) > obj.voAvg
                
%                 obj.vo.STOCK(end) > obj.voAvg ||...
            
                % && ((obj.vo.INDX(end-1) > mean(obj.vo.INDX(~isnan(obj.vo.INDX(1:end-1)))) ||...
                % obj.vo.INDX(end-2) > mean(obj.vo.INDX(~isnan(obj.vo.INDX(1:end-1)))))))
                
                %ADDED INDX TRACKING TO VOLUME
                
                obj.condition.Large_Volume = 1;
            else
                obj.condition.Large_Volume = 0;
            end
            
           
            if obj.cl.STOCK(end-1) > obj.clSma(end-1) && obj.cl.INDX(end-1) > obj.clAma(end-1)
                obj.condition.Above_MA.BULL = 1;
            else
                obj.condition.Above_MA.BULL = 0;
            end
            
            if obj.cl.STOCK(end-1) < obj.clSma(end-1) && obj.cl.INDX(end-1) < obj.clAma(end-1)
                obj.condition.Below_MA.BEAR = 1;
            else
                obj.condition.Below_MA.BEAR = 0;
            end
            
            
            if obj.currentTime >= 1550 %strcmp(datestr(obj.da.INDX(obj.ind),15), '16:00')
                obj.condition.Not_End_of_Day = 0;
            else
                obj.condition.Not_End_of_Day = 1;
            end
            
            %VERIFY THAT END OF DAY CONDITION IS WORKING 
            
            
            if obj.enterMarket.BULL || (obj.condition.Trying_to_Enter.BULL == 1 && obj.cross_MA.BULL) %obj.cl.STOCK(end) <= obj.clSma(end-1))
                obj.condition.Allowed_to_Enter.BULL = 1;
            else
                obj.condition.Allowed_to_Enter.BULL = 0;
            end
            
            if obj.enterMarket.BEAR || (obj.condition.Trying_to_Enter.BEAR == 1 && obj.cross_MA.BEAR) %obj.cl.STOCK(end) >= obj.clSma(end-1))
                obj.condition.Allowed_to_Enter.BEAR = 1;
            else
                obj.condition.Allowed_to_Enter.BEAR = 0;
            end
            
            if  obj.lastTradeTime ~= obj.currentTime
                obj.condition.Not_Same_Candle_Trade = 1;
            else
                obj.condition.Not_Same_Candle_Trade = 0;
            end
            
            
        end
        
        function calculateData(obj, isFlip)
            
            [obj.clSma, obj.clAma, obj.clRma] = obj.tAnalyze.getMovingStandard(obj.cl.STOCK, obj.cl.INDX, 12, isFlip);
            %%%%%% TRY ENTER IN ON 26 AND EXIT ON 12
            
            obj.voAvg = mean(obj.vo.STOCK(~isnan(obj.vo.STOCK(1:end-1))));  
            
            % NOT USING REAL CURRENT TIME
            %             obj.currentTime = datestr(now,15); obj.currentTime(3) = [];
            %             obj.currentTime = str2double(obj.currentTime);
            obj.currentTime = obj.da.STOCK(end);
            
            
            if obj.cl.STOCK(end) >= obj.clSma(end-1) && obj.lo.STOCK(end) < obj.clSma(end-1)
                obj.cross_MA.BULL = 1;
            else
                obj.cross_MA.BULL = 0;
            end
            
            if obj.cl.STOCK(end) <= obj.clSma(end-1) && obj.hi.STOCK(end) > obj.clSma(end-1)
                obj.cross_MA.BEAR = 1;
            else
                obj.cross_MA.BEAR = 0;
            end
            
            
        end
        
        function setStopLoss(obj)
            
            %NEEDS TO CHECK THE EXTREME OF THE ENTER CANDLE
            
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
                    obj.stopLoss.BULL = obj.lo.STOCK(end-2); %obj.enterPrice.BULL; %
                end
            end
            
            if obj.tradeLen.BEAR <= 1
                obj.stopLoss.BEAR = obj.enterPrice.BEAR*(1.00+obj.slPercentFirst/100);
            elseif obj.tradeLen.BEAR == 2
                obj.stopLoss.BEAR = obj.enterPrice.BEAR*(1.00+obj.slPercentSecond/100);
            else
                if  obj.hi.STOCK(end-2) < obj.stopLoss.BEAR
                    obj.stopLoss.BEAR = obj.hi.STOCK(end-2); % obj.enterPrice.BEAR; %
                end
            end
            
        end
        
        function executeBullTrade(obj)
            
            if obj.condition.Not_Stopped_Out.BULL...
                    && obj.condition.Large_Volume...
                    && obj.condition.Not_End_of_Day...
                    && obj.condition.Not_Same_Candle_Trade...
                    && obj.condition.Above_MA.BULL...
                    
                obj.condition.Trying_to_Enter.BULL = 1;
                
                if obj.condition.Allowed_to_Enter.BULL == 1
                    
                    if obj.enterMarket.BULL == 0
                        obj.enterPrice.BULL = obj.cl.STOCK(end);
                        obj.trades.BULL = [obj.trades.BULL; obj.enterPrice.BULL, NaN, length(obj.cl.STOCK), NaN];
                    end
                    
                    obj.enterMarket.BULL = 1;
                    obj.enteredStock = obj.stock;
                    obj.lastTradeTime = nan;
%                     obj.tradeLen.BULL = length(obj.cl.STOCK) - obj.trades.BULL(end,3) + 1;
                    
                end
                
            else
                
                obj.condition.Trying_to_Enter.BULL = 0;
                
                if obj.enterMarket.BULL == 1
                    
                    if obj.condition.Not_Stopped_Out.BULL
                        obj.trades.BULL(end,2) = obj.cl.STOCK(end);
                    else
                        if obj.op.STOCK(end) > obj.stopLoss.BULL
                            obj.trades.BULL(end,2) = obj.stopLoss.BULL;
                        else
                            obj.trades.BULL(end,2) = obj.op.STOCK(end);
                        end
                    end
                    
                    obj.trades.BULL(end,4) = length(obj.cl.STOCK);
                    obj.lastTradeTime = obj.currentTime;
                    
                    %obj.ind = obj.ind-1;
                    %%% ^^ DOES THIS ADD FUTUE KNOWLEDGE? ^^
                end
                
                obj.enterMarket.BULL = 0;
                obj.enterPrice.BULL = NaN;
                obj.tradeLen.BULL = 0;
                obj.stopLoss.BULL = NaN;
                 
                 if ~obj.enterMarket.BULL && ~obj.enterMarket.BEAR
                    obj.enteredStock = [];
                end 
                
            end
            
        end
        
        function executeBearTrade(obj)
            
            if obj.condition.Not_Stopped_Out.BEAR...
                    && obj.condition.Large_Volume...
                    && obj.condition.Not_End_of_Day...
                    && obj.condition.Not_Same_Candle_Trade...
                    && obj.condition.Below_MA.BEAR...
               
                obj.condition.Trying_to_Enter.BEAR = 1;
                
                if obj.condition.Allowed_to_Enter.BEAR == 1
                    
                    
                    if obj.enterMarket.BEAR == 0
                        obj.enterPrice.BEAR = obj.cl.STOCK(end);
                        obj.trades.BEAR = [obj.trades.BEAR; obj.enterPrice.BEAR, NaN, length(obj.cl.STOCK), NaN];
                    end
                    
                    obj.enterMarket.BEAR = 1;
                    obj.enteredStock = obj.stock;
                    obj.lastTradeTime = nan;
%                     obj.tradeLen.BEAR = length(obj.cl.STOCK) - obj.trades.BEAR(end,3) + 1;
                    
                end
                
            else
                
                obj.condition.Trying_to_Enter.BEAR = 0;
                
                if obj.enterMarket.BEAR == 1
                    
                    if obj.condition.Not_Stopped_Out.BEAR
                        obj.trades.BEAR(end,2) = obj.cl.STOCK(end);
                    else
                        if obj.op.STOCK(end) < obj.stopLoss.BEAR
                            obj.trades.BEAR(end,2) = obj.stopLoss.BEAR;
                        else
                            obj.trades.BEAR(end,2) = obj.op.STOCK(end);
                        end
                    end
                    
                    obj.trades.BEAR(end,4) = length(obj.cl.STOCK);
                    obj.lastTradeTime = obj.currentTime;
                    
                    %                     obj.ind = obj.ind-1;
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
