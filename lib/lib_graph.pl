:- module(lib_graph, [
    'graph-nodes'/2,
    'graph-reachable?'/4,
    'graph-path'/4,
    'graph-shortest-path'/4,
    'graph-weighted-shortest-path'/4,
    'graph-transitive-closure'/2,
    'graph-toposort'/2,
    'graph-has-cycle?'/2,
    'graph-connected-components'/2
]).

:- use_module(library(ugraphs)).
:- use_module(library(lists)).

% Edge format from MeTTa: ((from to) ...).
% Internally we use SWI-Prolog ugraphs for indexed adjacency operations.
'graph-nodes'(Edges, Nodes) :-
    edges_nodes(Edges, RawNodes),
    sort(RawNodes, Nodes), !.

'graph-reachable?'(Edges, Start, Goal, Result) :-
    edges_to_ugraph(Edges, Graph),
    ( reachable_node(Graph, Start, Goal) -> Result = true ; Result = false ), !.

'graph-path'(Edges, Start, Goal, Path) :-
    edges_to_ugraph(Edges, Graph),
    ( once(dfs_path(Graph, Start, Goal, [Start], RevPath)) ->
        reverse(RevPath, Path)
    ;
        Path = []
    ), !.

'graph-shortest-path'(Edges, Start, Goal, Path) :-
    edges_to_ugraph(Edges, Graph),
    ( once(bfs_shortest_path(Graph, [[Start]], Goal, RevPath)) ->
        reverse(RevPath, Path)
    ;
        Path = []
    ), !.

'graph-weighted-shortest-path'(Edges, Start, Goal, Result) :-
    weighted_edges(Edges, WeightedEdges),
    ( once(dijkstra([[0, Start, [Start]]], WeightedEdges, Goal, [], Cost, RevPath)) ->
        reverse(RevPath, Path),
        Result = [path, Path, cost, Cost]
    ;
        Result = []
    ), !.

'graph-transitive-closure'(Edges, ClosureEdges) :-
    edges_to_ugraph(Edges, Graph),
    transitive_closure(Graph, Closure),
    ugraph_to_edges(Closure, ClosureEdges), !.

'graph-toposort'(Edges, Order) :-
    edges_to_ugraph(Edges, Graph),
    ( top_sort(Graph, Sorted) -> Order = Sorted ; Order = [] ), !.

'graph-has-cycle?'(Edges, Result) :-
    edges_to_ugraph(Edges, Graph),
    ( top_sort(Graph, _) -> Result = false ; Result = true ), !.

'graph-connected-components'(Edges, Components) :-
    edges_to_undirected_ugraph(Edges, Graph),
    vertices(Graph, Nodes),
    connected_components(Nodes, Graph, [], Components), !.

edges_to_ugraph(Edges, Graph) :-
    edges_nodes(Edges, Nodes0),
    sort(Nodes0, Nodes),
    maplist(edge_pair, Edges, Pairs),
    vertices_edges_to_ugraph(Nodes, Pairs, Graph).

edges_to_undirected_ugraph(Edges, Graph) :-
    edges_nodes(Edges, Nodes0),
    sort(Nodes0, Nodes),
    findall(A-B, (member(Edge, Edges), edge_term(Edge, A, B)), Forward),
    findall(B-A, (member(Edge, Edges), edge_term(Edge, A, B)), Backward),
    append(Forward, Backward, Pairs),
    vertices_edges_to_ugraph(Nodes, Pairs, Graph).

edge_pair(Edge, A-B) :-
    edge_term(Edge, A, B).

edge_term([A, B], A, B).
edge_term(edge(A, B), A, B).
edge_term(A-B, A, B).

weighted_edge_term([A, B, Weight], A, B, Weight).
weighted_edge_term(edge(A, B, Weight), A, B, Weight).
weighted_edge_term(A-B-Weight, A, B, Weight).

weighted_edges(Edges, WeightedEdges) :-
    findall([A, B, Weight],
            ( member(Edge, Edges),
              weighted_edge_term(Edge, A, B, Weight)
            ),
            WeightedEdges).

edges_nodes(Edges, Nodes) :-
    findall(Node,
            ( member(Edge, Edges),
              edge_term(Edge, A, B),
              (Node = A ; Node = B)
            ),
            Nodes).

ugraph_to_edges(Graph, Edges) :-
    findall([From, To],
            ( member(From-Tos, Graph),
              member(To, Tos)
            ),
            Edges).

reachable_node(_Graph, Node, Node).
reachable_node(Graph, Start, Goal) :-
    reachable(Start, Graph, Nodes),
    memberchk(Goal, Nodes).

dfs_path(_Graph, Node, Node, Path, Path).
dfs_path(Graph, Current, Goal, Seen, Path) :-
    neighbours(Current, Graph, Nexts),
    member(Next, Nexts),
    \+ memberchk(Next, Seen),
    dfs_path(Graph, Next, Goal, [Next|Seen], Path).

bfs_shortest_path(_Graph, [[Goal|Path]|_], Goal, [Goal|Path]).
bfs_shortest_path(_Graph, [], _Goal, []) :- fail.
bfs_shortest_path(Graph, [[Current|Path]|Rest], Goal, Result) :-
    neighbours(Current, Graph, Nexts),
    findall([Next, Current|Path],
            ( member(Next, Nexts),
              \+ memberchk(Next, [Current|Path])
            ),
            Expanded),
    append(Rest, Expanded, Queue),
    bfs_shortest_path(Graph, Queue, Goal, Result).

dijkstra([[Cost, Goal, Path]|_], _Edges, Goal, _Seen, Cost, Path).
dijkstra([[_, Node, _]|Rest], Edges, Goal, Seen, Cost, Path) :-
    memberchk(Node, Seen), !,
    dijkstra(Rest, Edges, Goal, Seen, Cost, Path).
dijkstra([[BaseCost, Node, Path0]|Rest], Edges, Goal, Seen, Cost, Path) :-
    findall([NextCost, Next, [Next|Path0]],
            ( member([Node, Next, Weight], Edges),
              number(Weight),
              \+ memberchk(Next, Seen),
              NextCost is BaseCost + Weight
            ),
            Expanded),
    append(Rest, Expanded, Queue0),
    sort(Queue0, Queue),
    dijkstra(Queue, Edges, Goal, [Node|Seen], Cost, Path).

connected_components([], _Graph, _Seen, []).
connected_components([Node|Rest], Graph, Seen, Components) :-
    ( memberchk(Node, Seen) ->
        connected_components(Rest, Graph, Seen, Components)
    ;
        reachable(Node, Graph, Component0),
        sort(Component0, Component),
        append(Seen, Component, Seen1),
        Components = [Component|Tail],
        connected_components(Rest, Graph, Seen1, Tail)
    ).
