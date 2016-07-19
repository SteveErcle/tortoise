classdef TurtleCharacteristic < handle
    
    
    properties
        
        character;
        taz = TurtleAnalyzer;
        
    end
    
    
    methods
        
        
        function point = makePointAtoB(obj, allData, maxInterval)
            
            point.A = [];
            point.B = [];
            
            for i = 1:3:maxInterval
                
                for j = 1:length(allData.SPY.close)-maxInterval
                    
                    point.A = [point.A; j];
                    point.B = [point.B; j+i];
                    
                end
                
            end
            
        end
       
        function getCharacterGoog(obj, allData, stock, indx)
            
            [clSma, clAma, clRma] = obj.taz.getMovingStandard(allData.(stock).close, allData.(indx).close, 12, 0)
            lo_to_ma = obj.taz.percentDifference(clSma, allData.(stock).low);
            
            obj.character.vo.STOCK = allData.(stock).volume;
            obj.character.vo_n1.STOCK = [nan; allData.(stock).volume(2:end-1)];
            obj.character.cl.STOCK = allData.(stock).close;
            obj.character.op.STOCK = allData.(stock).open;
            obj.character.hi.STOCK = allData.(stock).high;
            obj.character.lo.STOCK = allData.(stock).low;
            obj.character.lo_n1.STOCK = [nan; allData.(stock).low(2:end-1)];
            obj.character.lo_n2.STOCK = [nan;nan; allData.(stock).low(3:end-2)];
            obj.character.da.STOCK = allData.(stock).date;
            obj.character.lo_to_ma.STOCK = lo_to_ma;
            obj.character.lo_to_ma_n1.STOCK = [nan; lo_to_ma(2:end-1)];
            obj.character.lo_to_ma_n2.STOCK = [nan; nan; lo_to_ma(3:end-2)];
            
            
            obj.character.vo.INDX = allData.(indx).volume;
            obj.character.cl.INDX = allData.(indx).close;
            obj.character.op.INDX = allData.(indx).open;
            obj.character.hi.INDX = allData.(indx).high;
            obj.character.lo.INDX = allData.(indx).low;
            obj.character.da.INDX = allData.(indx).date;
            
            
        end
        
        function plotMeanAndStd(obj, indx, color, data)
        
            co = strcat(color,'o');
            cx = strcat(color,'x');
            
            avgData = mean(data(~isnan(data)));
            stdData = std(data(~isnan(data)));
            
            plot([indx, indx], [avgData + stdData, avgData - stdData], color);
            plot(indx, avgData, co);
            plot(indx, avgData + stdData, cx);
            plot(indx, avgData - stdData, cx);
             
        end
        
        
        
    end
    
end