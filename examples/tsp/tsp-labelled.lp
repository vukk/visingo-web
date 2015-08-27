% based on tsp.lp from the book Answer Set Solving in Practice
% Modified for gringo4 syntax

proj_edge(X, Y) :- cost(X, Y, C).

% Generate
1 { edge(X, Y) : proj_edge(X, Y) } 1 :- node(X).
1 { edge(X, Y) : proj_edge(X, Y) } 1 :- node(Y).

% Test
reached(X) :- X = #min{ Y: node(Y) }.
reached(Y) :- edge(X, Y), reached(X).
:- node(Y), not reached(Y).

% Optimize
#minimize { C: edge(X, Y), cost(X, Y, C) }.

% For visualization
edgeAttr((X, Y), label, C) :- edge(X, Y), cost(X, Y, C).

% Display
#show node/1. % node/1 will be shown as a nodes in the visualization
#show edge/2. % edge/2 will be shown as an edges in the visualization
#show edgeAttr/3. % edge attributes for visualization

% EOF
