% Map node, edge and attributes through
_pp(Any, S) :- _as(Any, S).

% Edges that were just removed
removed(From, To, Step) :- _as(edge(From,To), Step-1), not _as(edge(From,To), Step).
% Edges that were just added
added(From, To, Step) :- not _as(edge(From,To), Step-1), _as(edge(From,To), Step).
% Edges that stay
other(From, To, Step) :- _as(edge(From,To), Step), not added(From, To, Step).

% Add, and color removed edges gray
_pp(edge(From,To),Step) :- removed(From,To,Step).
_pp(edgeAttr((From, To), color, "#cccccc"), Step) :- removed(From, To, Step).

% Color added edges orange
_pp(edgeAttr((From, To), color, "#ef6700"), Step) :- added(From, To, Step).
% Color other edges black
_pp(edgeAttr((From, To), color, "#587f2f"), Step) :- other(From, To, Step).
