function model=setup_model(strCondition, bLightLimitingState)
% Load the iJN678 network and configure boundary conditions.
% Usage:
%    MODEL=SETUP_MODEL(STATE, LIGHTLIMITINGSTATE) 
% where STATE is 'auto', 'mixo' or 'hetero' and LIGHTLIMITINGSTATE is
% either TRUE or FALSE (has no effect for heterotrophic conditions).
%
% Example:
%    model=setup_model('auto',false); % Carbon limited state
%    optimizeCbModel(model)

load iJN678_v1_1 % Updated model

if strcmpi(strCondition, 'auto')
   fprintf('Autotrophic conditions - ')
   model = changeRxnBounds(model, 'EX_co2(e)',0, 'b');
   model = changeRxnBounds(model, 'EX_hco3(e)',-3.70, 'l');
   model = changeRxnBounds(model, 'EX_glc(e)',0, 'l');
   model = changeObjective(model, 'Ec_biomass_SynAuto');
   model.ub(findRxnIDs(model,'Ec_biomass_SynMixo'))=0;
   model.ub(findRxnIDs(model,'Ec_biomass_SynHetero'))=0;
elseif strcmpi(strCondition, 'mixo')
   fprintf('Mixotrophic conditions - ')
   model = changeRxnBounds(model, 'EX_co2(e)',0, 'l');
   model = changeRxnBounds(model, 'EX_co2(e)',1000, 'u'); % Allow secretion of CO2
   model = changeRxnBounds(model, 'EX_hco3(e)',-3.70, 'l');
   model = changeRxnBounds(model, 'EX_glc(e)',-1, 'l');
   model = changeObjective(model, 'Ec_biomass_SynMixo');
   model.ub(findRxnIDs(model,'Ec_biomass_SynAuto'))=0;
   model.ub(findRxnIDs(model,'Ec_biomass_SynHetero'))=0;
elseif strcmpi(strCondition, 'hetero')
   fprintf('Heterotrophic conditions\n')
   model = changeRxnBounds(model, 'EX_co2(e)',0, 'l');
   model = changeRxnBounds(model, 'EX_co2(e)',1000, 'u'); % Allow secretion of CO2
   model = changeRxnBounds(model, 'EX_glc(e)',-1, 'l');
   model = changeRxnBounds(model, 'EX_photon(e)',0, 'b');
   model = changeObjective(model, 'Ec_biomass_SynHetero');
   model.ub(findRxnIDs(model,'Ec_biomass_SynAuto'))=0;
   model.ub(findRxnIDs(model,'Ec_biomass_SynMixo'))=0;
else
   error('Unknown state')
end

if strcmpi(strCondition, 'hetero') == 0
    if bLightLimitingState
       fprintf('Light limiting state\n')
       model = changeRxnBounds(model, 'EX_photon(e)',-30, 'b');
    else
       fprintf('Carbon limiting state\n')
       model = changeRxnBounds(model, 'EX_photon(e)',-100, 'b');
     end
end
