
classdef TurtleFun
    
    properties
        
    end
    
    methods
        
        function [hi, lo, cl, op, da, vo] = returnOHLCDarray(obj, t)
            hi = t(:,3); lo = t(:,4); cl = t(:,5); op = t(:,2); da = t(:,1); vo = t(:,6);
        end
        
        function [figHandle, pHandle] = plotHiLoMultiple(obj, t)
            
            if (isa(t, 'TurtleVal'))
                hi = t.hi;
                lo = t.lo;
                cl = t.cl;
                op = t.op;
                da = t.da;
            else
                [hi, lo, cl, op, da] = obj.returnOHLCDarray(t);
            end
            
            pHandle = highlow(hi, lo, op, cl, 'blue', da);
            hold on
            figHandle = gcf;
            
        end
          
        function [figHandle, pHandle] = plotHiLoSolo(obj, t, tickSize)
           
            [hi, lo, cl, op, da] = obj.returnOHLCDarray(t);
            
            pHandle(1) = plot([da,da], [lo,hi]);
            pHandle(2) = plot([da-tickSize,da], [op,op]);
            pHandle(3) = plot([da,da+tickSize], [cl,cl]);
            hold on
            figHandle = gcf;
            
        end
        
        function [figHandle, pHandle] = plotOp(obj, t, tickSize)
            
            if (isa(t, 'TurtleVal'))
                hi = t.hi;
                lo = t.lo;
                cl = t.cl;
                op = t.op;
                da = t.da;
            else
                [hi, lo, cl, op, da] = obj.returnOHLCDarray(t);
            end
            
            pHandle = plot([da(1)-tickSize,da(1)], [1,1]*op(1));
            hold on
            figHandle = gcf;
            
        end
        
        function [figHandle, pHandle, pT] = resetPlot(obj, figHandle, tPast, startDay, levels, dAll)
            
            set(0,'CurrentFigure',figHandle)
            
            handle = gca;
            cla(handle);
            
            obj.plotStartDay(startDay);
            [figHandle,pHandle] = obj.plotHiLoMultiple(tPast);
            
            if ~isempty(levels)
                for i = 1:3
                    for j = 1:length(levels)
                        set(0,'CurrentFigure',i)
                        plot([dAll(end,1), dAll(1,1)], [1,1]*levels(j), 'k');
                    end
                end
            end
            
            
            pT = 0;

        end 
             
        function  [foundRes, foundSup, foundDates,...
                closestRes, closestSup] = getContainerLevels(obj, maxNumDays, hi, lo, da)
            
            begin = 2;
            
            founder = [];
            for i = 10:maxNumDays
                
                res = max(hi(begin:begin+i));
                sup = min(lo(begin:begin+i));
                
                founder = [founder; begin + i, (res-sup)/sup];
                
            end
            
            uniqueNY = unique(founder(:,2));
            foundX = [];
            for i = 1:length(uniqueNY)
                
                specific = find(uniqueNY(i) == founder(:,2));
                
                foundX = [foundX; uniqueNY(i), max(founder(specific,1))];
                
            end
            
            
            %             weightedContainer = (100 - foundX(:,1)*100).*[(1./power(1:size(foundX,1),.1))]'
            %             weightedTime = foundX(:,2)
            %             fScore = weightedContainer.*weightedTime ./ (weightedContainer+weightedTime)
            
            foundLevels = [];
            for i = 1: size(foundX,1)
                
                indxStart   = begin;
                indxEnd     = foundX(i,2);
                
                foundDates  = da(indxStart:indxEnd);
                foundRes    = max(hi(indxStart:indxEnd));
                foundSup    = min(lo(indxStart:indxEnd));
                
                foundLevels = [foundLevels; foundRes, foundSup, da(indxStart), da(indxEnd)];
                
            end
            
            foundRes = foundLevels(:,1);
            foundSup = foundLevels(:,2);
            foundDates = foundLevels(:,3:4);
            
            closestRes = sort(abs((hi(1)-foundRes)./foundRes));
            closestRes = closestRes(1);
            closestSup = sort(abs((lo(1)-foundSup)./foundSup));
            closestSup = closestSup(1);
            
            
            
        end
        
        function plotContainer(obj, foundLevels)
            for i = 1:size(foundLevels,1)
                plot([foundLevels(i,4); foundLevels(i,3)], ones(2,1)*foundLevels(i,1), 'b')
                plot([foundLevels(i,4); foundLevels(i,3)], ones(2,1)*foundLevels(i,2), 'b')
            end
            
        end
        
        function plotStartDay(obj, startDay)
            
            plot([startDay, startDay],  [0, 1000], 'c')
            hold on;
            
        end
        
        function typeOfLevel = matchToResOrSup(obj, t, values)
            
            [hi, lo, cl, op, da] = obj.returnOHLCDarray(t);
            dateOnPlot = values(end,1);
            [M indx] = min(abs(da-dateOnPlot))
            
            if values(end,2) == hi(indx)
                typeOfLevel = 1;
            elseif values(end,2) == lo(indx)
                typeOfLevel = -1;
            else
                typeOfLevel = 0;
            end
            
        end
        
    end
    
end






