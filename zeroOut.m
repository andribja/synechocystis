function [outArr] = zeroOut(inArr)

outArr = [];

count=1;

for i = 1:size(inArr, 1)
        if(abs(inArr(i)) < 1e-4)
            outArr(i) = 0.0;
            count = count + 1;
        else 
            outArr(i) = inArr(i);
        end
end

fprintf('%1.2f fluxes zeroed out', count);

