function [mustU, mustL, mustUU, mustLL, mustUL, mustLU] = optForce(model, rxn, target)

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

wModel = model;
[wMin, wMax] = fluxVariability(wModel);
altModel = changeRxnBounds(model, rxn, target, 'l');
[altMin, altMax] = fluxVariability(altModel);
count = 0;

bitmap = transpose(zeros([1 length(wMin)])); % logical vector
% 'bitmap' key:
% -3 mustLU set
% -2 mustLL set
% -1 mustL set
% 0 no set
% 1 mustU set
% 2 mustUU set
% 3 mustUL set

zeroC = zeros(length(model.c), 1);
mustU = [];
mustL = [];
mustUU = [];
mustLL = [];
mustUL = [];
mustLU = [];

% Check for mustU and mustL sets by comparing wild/alt type flux for each rxn
for i=1:length(wMin)
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

% check for mustUU/mustLL/mustUL cases
for i=1:length(wMin)
    if(bitmap(i) == 0)
        for j=1:length(wMin)
            wModel.c = zeroC; % Initialize objective vector
            altModel.c = zeroC; 

            % set objective to sum of fluxes of rxns i and j
            wModel.c(i) = 1;
            wModel.c(j) = 1;
            altModel.c(i) = 1;
            altModel.c(j) = 1;
            
            %get upper/lower bounds for each rxn for wild/alt
            wMax2 = optimizeCbModel(wModel);
            wMax2 = wMax2.f;
            altMax2 = optimizeCbModel(altModel);
            altMax2 = altMax2.f;
            wMin2 = optimizeCbModel(wModel, 'min');
            wMin2 = wMin2.f;
            altMin2 = optimizeCbModel(altModel, 'min');
            altMin2 = altMin2.f;

            if (wMin2 > altMax2)
                fprintf('mustLL: %s, %s\n', model.rxns{i}, model.rxns{j});
                mustLL = [mustLL i];
                bitmap(i) = -2;
                count = count + 1;
            end
            if(wMax2 < altMin2)
                fprintf('mustUU: %s, %s\n', model.rxns{i}, model.rxns{j});
                mustUU = [mustUU i];
                count = count + 1;
                bitmap(i) = 2;
            end

            %set objective to difference of rxn i/j fluxes
            wModel.c(j) = -1;
            altModel.c(j) = -1;

            wMax3 = optimizeCbModel(wModel);
            wMax3 = wMax3.f;
            altMax3 = optimizeCbModel(altModel);
            altMax3 = altMax3.f;
            wMin3 = optimizeCbModel(wModel, 'min');
            wMin3 = wMin3.f;
            altMin3 = optimizeCbModel(altModel, 'min');
            altMin3 = altMin3.f;
            
            if (wMin3 > altMax3)
                fprintf('mustLU: %s, %s\n', model.rxns{i}, model.rxns{j});
                mustLU = [mustLU i];
                bitmap(i) = -3;
                count = count + 1;
            end
            if(wMax3 < altMin3)
                fprintf('mustUL: %s, %s\n', model.rxns{i}, model.rxns{j});
                mustUL = [mustUL i];
                count = count + 1;
                bitmap(i) = 3;
            end
        end
    end
end

mustU = columnVector(mustU);
mustL = columnVector(mustL);
mustUU = columnVector(mustUU);
mustLL = columnVector(mustLL);
mustUL = columnVector(mustUL);
mustLU = columnVector(mustLU);
disp(count);
