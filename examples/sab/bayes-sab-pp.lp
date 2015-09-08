% postprocess Bayes water for SAB

% change edge color inheritance
_pp(edgeDefault(color,inherit,false),1).
_pp(edgeDefault(color,"#7cb342"),1).

% pass edge through
_pp(edge(X,Y),S) :- _as(edge(X,Y),S).

% remove singletons (nodes that are never connected)
% all nodes
nodes(X) :- _as(node(X),_).
% get nodes that are connected
conn(X) :- nodes(X), nodes(Y), _as(edge(X,Y),_).
conn(X) :- nodes(X), nodes(Y), _as(edge(Y,X),_).
% pass through nodes that are connected
_pp(node(X),S) :- _as(node(X),S), conn(X).
_pp(nodeAttr(X,A,B),S) :- _as(nodeAttr(X,A,B),S), conn(X).

% nodes that have changed incoming edges
% edge removed
chNode(X, Step) :- _as(node(X), Step), _as(edge(Y,X), Step), not _as(edge(Y,X), Step-1).
% edge added
chNode(X, Step) :- _as(node(X), Step), not _as(edge(Y,X), Step), _as(edge(Y,X), Step-1).

% color changed nodes
_pp(chNode(X),Step) :- chNode(X,Step).
_pp(nodeAttr(X, color, "#ff993f"), Step) :- chNode(X, Step).
% color other nodes by default color
_pp(nodeAttr(X, color, "#dcedc8"), Step) :- _as(node(X), Step), not chNode(X, Step), conn(X).

% EOF
