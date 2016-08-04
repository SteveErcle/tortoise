classdef TurtleOptimizer < handle
    
    
    properties
        
    end
    
    methods
        
        function x = solve(obj, opt,nvars,lb,ub)
            
            x = particleswarm(opt,nvars,lb,ub);
            
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
        
    end
    
    
    
end

