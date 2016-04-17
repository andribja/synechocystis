load iJN678;

model = changeRxnBounds(model, 'EX_o2(e)', -1000, 'l');
% R00178 AUKAHVARF FYRIR CCOAOMT
model = addReaction(model, 'S-adenosyl-L-methionine carboxy-lyase', 'amet[c] + h[c]  <=> ametam[c] + co2[c] ');
model = addReaction(model, 'CCoAOMT', 'amet[c] + caffcoa[c] <=> ahcys[c] + ferulcoa[c]');
model = addReaction(model, 'EX_phe-L(e)', 'phe-L[c] -> '); 
%R00697
model = addReaction(model, 'PAL', 'phe-L[c] + 2 h[c] <=> cinnam[c] + nh4[c] ');
%model=addReaction(model,'DM_phe-L','phe-L[c] ->');
%robustnessAnalysis(model,'DM_phe-L'); 
%R00737
model = addReaction(model, 'PTAL', 'tyr-L[c] + 2 h[c] <=> coumac[c] + nh4[c] ');
%model=addReaction(model,'DM_tyr-L','tyr-L[c] ->');
%robustnessAnalysis(model,'DM_tyr-L'); 

%R02253 C4H eða CA4H
model = addReaction(model, 'trans-cinnamate 4-monooxygenase', 'cinnam[c] + o2[c] + nadph[c] + h[c]  <=> coumac[c] + nadp[c] + h2o[c] ');
model=addReaction(model,'DM_cinnam','cinnam[c] ->'); 
robustnessAnalysis(model,'DM_cinnam');
model=addReaction(model,'DM_coumac','coumac[c] ->'); 
robustnessAnalysis(model,'DM_coumac'); 
%R01616
model = addReaction(model, '4-coumarate---CoA ligase a', 'atp[c] + coumac[c] + coa[c]  <=> amp[c] + ppi[c] + coumcoa[c] ');
model = addReaction(model, 'DM_coumcoa', 'coumcoa[c] ->');

%R02416
model = addReaction(model, 'shikimate O-hydroxycinnamoyltransferase a', 'coumcoa[c] + skm[c]  <=> coa[c] + 4coumshik[c] ');
model = addReaction(model, 'DM_4coumshik', '4coumshik[c] ->');
robustnessAnalysis(model,'DM_4coumshik'); 
 
%R08815 C4H eða CA4H SKODA
model = addReaction(model, 'trans-cinnamate 4-monooxygenase b', '4coumshik[c] + o2[c] + nadph[c] + 2 h[c]  <=> ox4coumshik[c] + nadp[c] + h2o[c] ');
model = addReaction(model, 'DM_ox4coumshik', 'ox4coumshik[c] ->');
robustnessAnalysis(model,'DM_ox4coumshik'); 
 
%R07433
model = addReaction(model, 'shikimate O-hydroxycinnamoyltransferase b', 'ox4coumshik[c] + coa[c]  <=> caffcoa[c] + skm[c] ');

% Aldehyde dehydrogenase
model = addReaction(model, 'Aldehyde dehydrogenase asdf', 'conifald[c] + nad[c] + h2o[c]  <=> ferulac[c] + nadh[c]');

%R02193
model = addReaction(model, 'Coniferyl aldehyde:NADP+ oxidoreductase', 'conifald[c] + coa[c] + nadp[c]  <=> ferulcoa[c] + nadph[c] + h[c] ');

%R02194
%model = addReaction(model, '4-coumarate---CoA ligase', 'atp[c] + ferulac[c] + coa[c]  <=> amp[c] + ppi[c] + ferulcoa[c] ');

% HERE
% R07436
%model = addReaction(model, 'p-coumaroyl-CoA:caffeoyl-CoA 3-hydrolase', 'coumcoa[c] + h2o[c] <=> caffcoa[c] + 2 h[c]');
% HERE

% R05772
model = addReaction(model, 'trans-feruloyl-CoA hydratase', 'ferulcoa[c] + h2o[c]  <=> hydpropcoa[c] ');

% R05773
model = addReaction(model, 'vanillin lyase', 'hydpropcoa[c]  <=> accoa[c] + vanil[c] ');

% Seyting 
model = addReaction(model, 'EX_vanil(e)', 'vanil[c]  -> ');

model = addReaction(model, 'DM_coumcoa', 'coumcoa[c] ->');
robustnessAnalysis(model,'DM_coumcoa');
model = addReaction(model, 'DM_caffcoa', 'caffcoa[c] ->');
robustnessAnalysis(model,'DM_caffcoa');
model = addReaction(model, 'DM_conifald', 'conifald[c] ->');
robustnessAnalysis(model,'DM_conifald');
model = addReaction(model, 'DM_ferulac', 'ferulac[c] ->');
robustnessAnalysis(model,'DM_ferulac');
model = addReaction(model, 'DM_ferulcoa', 'ferulcoa[c] ->');
robustnessAnalysis(model,'DM_ferulcoa');
model = addReaction(model, 'DM_hydpropcoa', 'hydpropcoa[c] ->');
robustnessAnalysis(model,'DM_hydpropcoa'); 
 
robustnessAnalysis(model, 'EX_vanil(e)');
robustnessAnalysis(model, 'EX_phe-L(e)');
