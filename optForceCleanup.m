function [ret] = optForceCleanup(mat, exc)
ret = [];
    for i=1:size(mat, 1)
        if(exc(mat(i,1)) == 0 && exc(mat(i,2)) == 0)
            ret = [ret ; mat(i,:)];
        end
    end
            
