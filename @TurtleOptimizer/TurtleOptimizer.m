classdef TurtleOptimizer < handle
    
    
    properties
        
    end
    
    methods
        
        function x = solve(obj, opt,nvars,lb,ub)
            
            x = particleswarm(opt,nvars,lb,ub);
            
        end
        
        function y = genWave(obj, amplitudes, periods, phases, t)
            
            A = amplitudes;
            P = periods;
            O = phases;

            y = 0;
            for i = 1:numel(A)
                y = y + A(i)*cos(2*pi*(1/P(i))*t + O(i));
            end    
           
        end
        
    end
    
    
    
end

