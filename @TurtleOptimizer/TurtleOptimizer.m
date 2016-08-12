classdef TurtleOptimizer < handle
    
    
    properties
        
        tz = TurtleAnalyzer;
        
    end
    
    methods
        
        function x = solve(obj, opt,nvars,lb,ub)
            
            x = particleswarm(opt,nvars,lb,ub);
            
        end
        
        function opt = loopClosure(obj, ma, t, useDiff)
            
            
            y = obj.genWave(x(1:2),x(3:4),x(5:6),t, mean(ta.cl.STOCK));

%             opt = @(x)(sum(abs(ma.STOCK(12:300) 
            
        end
        
        function y = genWave(obj, amplitudes, periods, phases, t, avg)
            
            A = amplitudes;
            P = periods;
            O = phases;
            
            numOfWaves = size(A);
            
            if sum(size(P) == numOfWaves) ~= 2 || sum(size(O) == numOfWaves) ~= 2
                y = [];
                return
            end
            

            y = 0;
            for i = 1:numel(A)
                y = y + A(i)*cos(2*pi*(1/P(i))*t + O(i));
            end    
            
            y = y+avg;
           
            y = y';
            
        end
        
        
        function e = lcv_WhiteSpace(obj, ta, candleStart, candleEnd, x)
            
            roi = obj.lc_WhiteSpace(ta, candleStart, candleEnd, x);
            
            x = sum(roi);
            
            y = 1/x; y(x<=1) = 1; y(x<=-1) = -x(find(x<=-1));
            
            y = y + length(roi)/200;
            
            e = y;
            
        end 
        
        function [roi, inMarket] = lc_WhiteSpace(obj, ta, candleStart, candleEnd, x)
             
            num = floor(x(1));
            whiteSpace = x(2);
            window_size = floor(x(3));
            
            ma.STOCK = tsmovavg(ta.cl.STOCK,'e',window_size,1);
            
            enter.BULL = 0;
            inMarket.BULL = [];
            
            for i = candleStart:candleEnd
                
                if enter.BULL...
                        || (ta.cl.STOCK(i-1) > ma.STOCK(i-1)...
                        && ta.lo.STOCK(i) <= ma.STOCK(i)...
                        && ta.cl.STOCK(i) > ma.STOCK(i)...
                        && ~strcmp(datestr(ta.da.STOCK(i),15), '16:00')...
                        && ~strcmp(datestr(ta.da.STOCK(i),15), '15:50')...
                        && (mean(ta.cl.STOCK(i-num:i)) - ma.STOCK(i)) / ma.STOCK(i) * 100 > whiteSpace)
                    
                    if enter.BULL == 0
                        inMarket.BULL = [inMarket.BULL; i, nan];
                    end
                    
                    enter.BULL = 1;
                    
                end
                
                if enter.BULL...
                    && ((inMarket.BULL(end,1) ~= i && ta.cl.STOCK(i) < ta.op.STOCK(i))...
                        || (strcmp(datestr(ta.da.STOCK(i),15), '16:00') || strcmp(datestr(ta.da.STOCK(i),15), '15:50')))
                    
                    inMarket.BULL(end,2) = i;
                    
                    enter.BULL = 0;
                end
                
            end
            
            if isempty(inMarket.BULL)
                roi = 0;
            else
                
                if isnan(inMarket.BULL(end,2));
                    inMarket.BULL(end,:) = [];
                end 
                
                first = ta.cl.STOCK(inMarket.BULL(:,1));
                second = ta.cl.STOCK(inMarket.BULL(:,2));
                roi = obj.tz.percentDifference(first, second);
            end
        end
        
    end
    
    
    
end

