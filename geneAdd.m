

model = addReaction(model, 'PTAL', 'c9h11no3[c]  <=> c9h8o3[c] + nh3[c] ');
%C4H eða CA4H
model = addReaction(model, 'C4H', 'c9h8o2[c] + o2[c] + nadph[c]  + h[c] <=> c9h8o3[c] + nadp[c] + h2o[c] ');
model = addReaction(model, '4CL', 'atp[c] + c9h803[c] +  c21h36n7o16p3s[c] <=> c10h14n5o7p[c] + h4p2o7[c] + c30h42n7o18p3s[c] ');
model = addReaction(model, 'HCT', 'c30h42n7o18p3s[c] + c7h10o5[c] <=> c21h36n7o16p3s[c] + c16h16o7[c] ');
%C4H eða CA4H
model = addReaction(model, 'C4H', 'c30h42n7o17p3s[c] + o2[c] + nadph[c]  + h[c] <=> c30h42n7o18p3s[c] + nadp[c] + h2o[c] ');

model = addReaction(model, 'HCT', 'c15h22n6o5s[c] + c30h42n7o19p3s[c] <=> c14h20n6o5s[c] + c31h44n7o19p3s[c] ');
%COMT?
model = addReaction(model, 'caffeoyl-CoA 3-O-methyltransferase', 'c10h10o3[c] + c21h36n7o16p3s[c] +  nadp[c] <=> c31h44n7o19p3s[c] + nadph[c] + h[c] ');

%%%%% SKIL


model = addReaction(model, 'CCR', 'c10h10o3[c] + c21h36n7o16p3s[c] +  nadp[c] <=> c31h44n7o19p3s[c] + nadph[c] + h[c] ');

% R07436
model = addReaction(model, 'p-coumaroyl-CoA:caffeoyl-CoA 3-hydrolase', 'c30h42n7o18p3s[c] + h2o[c]  <=> c30h42n7o19p3s[c] + 2h[c] ');

% R05772
model = addReaction(model, 'trans-feruloyl-CoA hydratase', 'c31h44n7o19p3s[c] + h2o[c]  <=> c31h46n7o20p3s[c] ');

% R05773 
model = addReaction(model, 'vanillin lyase', 'c31h46n7o20p3s[c]  <=> c23h38n7o17p3s[c] + c8h8o3[c] ');

% Aldehyde dehydrogenase
model - addReaction(model, 'Aldehyde dehydrogenase', 'c10h10o3 + nad[c] + h2o[c]  <=> c10h10o4[c] + nadh[c] + h[c] '


% R00178 AUKAHVARF FYRIR CCOAOMT
model = addReaction(model, 'S-adenosyl-L-methionine carboxy-lyase', 'c15h22n6o5s[c] + h[c]  <=> c14h23n6o3s[c] + co2[c] ');
