
This is an updated version of the iJN678 metabolic reconstruciton of Synechocystis PCC6803.
It contains corrections to mass and charge balancing of some reactions and metabolites.

Last updated: 9.3.2014

Files
=====
iJN678_v1.1.xml			Version 1.1 in SBML format
iJN678_v1.1.mat			Version 1.1 in Matlab format
setup_model.m			Matlab function to load and configure boundary conditions
iJN678_v1.1_updates.xlsx	List of updated reactions and metabolites
iJN678_v1.1_protons.pptx	Replication of proton exchange study from the PNAS paper


Examples of growth rate predictions
===================================
The Cobra toolbox is required. It is available from http://opencobra.sourceforge.net/)

1) Predicted growth rate under autotrophic conditions (carbon limited state)
>> model=setup_model('auto',false);
Autotrophic conditions - Carbon limiting state
>> optimizeCbModel(model)
ans = 
           x: [863x1 double]			<- Flux values
           f: 0.0884				<- Predicted growth rate
           y: [795x1 double]
           w: [863x1 double]
        stat: 1					<- Flux balance analysis was sucessful
    origStat: 5
      solver: 'glpk'
        time: 0.0370

2) Autotrophic conditions, light limited state
>> model=setup_model('auto',true);
>> sol=optimizeCbModel(model); sol.f
ans =
    0.0523

3) Mixotrophic conditions, carbon limited state
>> model=setup_model('mixo',false);
>> sol=optimizeCbModel(model);sol.f
ans =
    0.2388

4) Heterotrophic conditions
>> sol=optimizeCbModel(model);sol.f
ans =
    0.0743
