function [mustU, mustL, mustUU, mustLL, mustUL] = optForce(model, rxn, target, growthPct)

addpath('./fastFVA');
%%%%%%%%%
%   
% opt(Brute)Force
%   
% 
%
%
%
%
%%%%%%%%%%
exRxns = findExcRxns(model);
wModel = model;
[wMin, wMax] = fastFVA(wModel, growthPct);
altModel = changeRxnBounds(model, rxn, target, 'l');
[altMin, altMax] = fastFVA(altModel, growthPct);
count = 0;

wMin = zeroOut(wMin);
wMax = zeroOut(wMax);
altMin = zeroOut(altMin);
altMax = zeroOut(altMax);

bitmap = transpose(zeros([1 length(wMin)])); % logical vector
% 'bitmap' key:
% -3 mustLU set
% -2 mustLL set
% -1 mustL set
% 0 no set
% 1 mustU set
% 2 mustUU set
% 3 mustUL set
excRxns = find(findExcRxns(model));
zeroC = zeros(length(model.c), 1);
mustU = [];
mustL = [];
mustUU = [];
mustLL = [];
mustUL = [];



% Check for mustU and mustL sets by comparing wild/alt type flux for each rxn
for i=1:length(model.rxns)
    if (wMin(i) > altMax(i))
        fprintf('mustL: %s\n', model.rxns{i});
        mustL = [mustL i];
        bitmap(i) = -1;
        count = count + 1;
    end
    if(wMax(i) < altMin(i))
        fprintf('mustU: %s\n', model.rxns{i});
        mustU = [mustU i];
        count = count + 1;
        bitmap(i) = 1;
    end
end

[wMin2, wMax2] = fastFVA2(wModel, growthPct);
[altMin2, altMax2] = fastFVA2(altModel, growthPct);
wMin2 = zeroOut(wMin2);
wMax2 = zeroOut(wMax2);
altMin2 = zeroOut(altMin2);
altMax2 = zeroOut(altMax2);
cnt = 1;
% check for mustUU/mustLL/mustUL cases
for i=1:length(wMin)
    for j=(i+1):length(wMin)
        if(bitmap(i) == 0 && bitmap(j) == 0)
           if (wMin2(cnt) > altMax2(cnt))
                fprintf('mustLL: %s, %s\n', model.rxns{i}, model.rxns{j});
                mustLL = [mustLL ; i j];
            end
            if(wMax2(cnt) < altMin2(cnt))
                fprintf('mustUU: %s, %s\n', model.rxns{i}, model.rxns{j});
                mustUU = [mustUU ; i j];
            end
            cnt = cnt + 1;
        end
    end
end

[wMin3, wMax3] = fastFVA3(wModel, growthPct);
[altMin3, altMax3] = fastFVA3(altModel, growthPct);
wMin3 = zeroOut(wMin3);
wMax3 = zeroOut(wMax3);
altMin3 = zeroOut(altMin3);
altMax3 = zeroOut(altMax3);
cnt = 1;
for i=1:length(wMin)
    for j=(i+1):length(wMin)
        if(bitmap(i) == 0 && bitmap(j) == 0)
            if (wMin3(cnt) > altMax3(cnt))
                fprintf('mustUL: %s, %s\n', model.rxns{i}, model.rxns{j});
                mustUL = [mustUL ; i j];
            end
            cnt = cnt + 1;
        end
    end
end

mustU = columnVector(mustU);
mustL = columnVector(mustL);
mustUU = optForceCleanup(columnVector(mustUU), exRxns);
mustLL = optForceCleanup(columnVector(mustLL), exRxns);
mustUL = optForceCleanup(columnVector(mustUL), exRxns);
disp(count);
rmpath('./fastFVA');
