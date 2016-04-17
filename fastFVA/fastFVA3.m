function [minFlux,maxFlux,optsol,ret,fbasol,fvamin,fvamax] = fastFVA(model,optPercentage,objective,solver)
%fastFVA Flux variablity analysis optimized for the GLPK and CPLEX solvers.
%
% [minFlux,maxFlux] = fastFVA(model,optPercentage,objective, solver)
%
% Solves LPs of the form for all v_j: max/min v_j
%                                     subject to S*v = b
%                                     lb <= v <= ub
% Inputs:
%   model             Model structure
%     Required fields
%       S            Stoichiometric matrix
%       b            Right hand side = 0
%       c            Objective coefficients
%       lb           Lower bounds
%       ub           Upper bounds
%     Optional fields
%       A            General constraint matrix
%       csense       Type of constraints, csense is a vector with elements
%                    'E' (equal), 'L' (less than) or 'G' (greater than).
%     If the optional fields are supplied, following LPs are solved
%                    max/min v_j
%                    subject to Av {'<=' | '=' | '>='} b
%                               lb <= v <= ub
%
%   optPercentage    Only consider solutions that give you at least a certain
%                    percentage of the optimal solution (default = 100
%                    or optimal solutions only)
%   objective        Objective ('min' or 'max') (default 'max')
%   solver           'cplex' or 'glpk' (default 'glpk')
%
% Outputs:
%   minFlux   Minimum flux for each reaction
%   maxFlux   Maximum flux for each reaction
%   optsol    Optimal solution (of the initial FBA)
%   ret       Zero if success
%   
% [minFlux,maxFlux,optsol,ret,fbasol,fvamin,fvamax] = fastFVA(...) returns 
% vectors for the initial FBA in FBASOL together with matrices FVAMIN and
% FVAMAX containing the flux values for each individual min/max problem.
% Note that for large models the memory requirements may become prohibitive.
%
% Example:
%    load modelRecon1Biomass.mat % Human reconstruction (recon1)
%    SetWorkerCount(4) % Only if you have the parallel toolbox installed
%    [minFlux,maxFlux]=fastFVA(model, 90);
%
% Reference: S. Gudmundsson and I. Thiele, Computationally efficient
%            Flux Variability Analysis. BMC Bioinformatics, 2010, 11:489

% Author: Steinn Gudmundsson.
% Last updated: 10.7.2013

verbose=0;

if nargin<4, solver='glpk'; end
if nargin<3, objective='max'; end
if nargin<2, optPercentage=100; end

if strcmpi(objective,'max')
   obj=-1;
elseif strcmpi(objective,'min')
   obj=1;
else
   error('Unknown objective')
end

if strmatch('glpk',solver)
   FVAc=@glpkFVA3cc;
elseif strmatch('cplex',solver)
   FVAc=@cplexFVAc;
else
   error(sprintf('Solver %s not supported', solver))
end

if isfield(model,'A')
   % "Generalized FBA"
   A=model.A;
   csense=model.csense(:);
else
   % Standard FBA
   A=model.S;
   csense=char('E'*ones(size(A,1),1));
end
if ~issparse(A)
   A=sparse(A); % C++ code assumes a sparse stochiometric matrix
end
if nargout>4
   assert(nargout == 7);
   bExtraOutputs=true;
else
   bExtraOutputs=false;
end

b=model.b;
[m,n]=size(A);

nworkers=GetWorkerCount();
if nworkers<=1
   % Sequential version
   if bExtraOutputs
      [minFlux,maxFlux,optsol,ret,fbasol,fvamin,fvamax]=FVAc(model.c,A,b,csense,model.lb,model.ub, ...
                                                             optPercentage,obj,(1:n)');
   else
      [minFlux,maxFlux,optsol,ret]=FVAc(model.c,A,b,csense,model.lb,model.ub, ...
                                        optPercentage,obj,(1:n)');
   end
   if ret ~= 0 && verbose
      fprintf('Unable to complete the FVA, return code=%d\n', ret)
   end
else
   % Divide the reactions amongst workers
   %
   % The load balancing can be improved for certain problems, e.g. in case
   % of problems involving E-type matrices, some workers will get mostly
   % well-behaved LPs while others may get many badly scaled LPs.
   if n > 5000
      % A primitive load-balancing strategy for large problems
      nworkers=4*nworkers;
   end

   nrxn=repmat(fix(n/nworkers),nworkers,1);
   i=1;
   while sum(nrxn) < n
      nrxn(i)=nrxn(i)+1;
      i=i+1;
   end
   assert(sum(nrxn)==n);
   istart=1; iend=nrxn(1);
   for i=2:nworkers
      istart(i)=iend(i-1)+1;
      iend(i)=istart(i)+nrxn(i)-1;
   end

   minFlux=zeros(n*(n-1)/2,1); maxFlux=zeros(n*(n-1)/2,1);
   iopt=zeros(nworkers,1);
   iret=zeros(nworkers,1);
   if bExtraOutputs
      fbasol=zeros(n,1); fbasol_single=zeros(n,nworkers);
      fvaminRes={}; fvamaxRes={};
   end
   parfor i=1:nworkers
      if bExtraOutputs
         [minf,maxf,iopt(i),iret(i),fbasol_single(:,i),fvamin_single,fvamax_single] =  ...
                                    FVAc(model.c, A,b,csense,model.lb,model.ub, ...
                                        optPercentage,obj,(istart(i):iend(i))');
      else
         [minf,maxf,iopt(i),iret(i)]=FVAc(model.c,A,b,csense,model.lb,model.ub, ...
                                          optPercentage,obj,(istart(i):iend(i))');
      end
      if iret(i) ~= 0 && verbose
         fprintf('Problems solving partition %d, return code=%d\n', i, iret(i))
      end
      minFlux=minFlux+minf;
      maxFlux=maxFlux+maxf;
      if bExtraOutputs
         fvaminRes{i}=fvamin_single;
         fvamaxRes{i}=fvamax_single;
      end
   end
   % Aggregate results   
   optsol=iopt(1);
   ret=max(iret);
   if bExtraOutputs
      fbasol=fbasol_single(:,1); % FBA solutions are identical across workers
      fvamin=zeros(n,sum(nrxn));
      fvamax=zeros(n,sum(nrxn));
      for i=1:nworkers
         fvamin(:,istart(i):iend(i))=fvaminRes{i};
         fvamax(:,istart(i):iend(i))=fvamaxRes{i};
      end
   end
end
