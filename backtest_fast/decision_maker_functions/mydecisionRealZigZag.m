        function [real] = mydecisionRealZigZag (LastReturn)
            
            %NOTE: se l'ultima operazione e' vinta, salta la prossima
            % (da usare se i ritorni sono seghettati: una vinta una persa)
            
            if ( LastReturn > 0 )
            
                real = 0;
            
            else
                
                real = 1;
                
            end
            
        end
        