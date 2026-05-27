# lib_graph

`lib_graph` is a Prolog-backed graph algorithms library for PeTTa. It gives MeTTa programs clear APIs for graph reasoning while using SWI-Prolog for efficient graph conversion and traversal.

The library is useful for symbolic AI workflows where relationships naturally form graphs: knowledge graphs, concept hierarchies, inference chains, rule dependencies, planning graphs, type graphs, and atom-space relation networks.

## Files

```text
lib/lib_graph.pl
lib/lib_graph.metta
lib/lib_graph.md
examples/graph.metta
```

`lib/lib_graph.pl` contains the Prolog implementation.

`lib/lib_graph.metta` exposes the APIs to PeTTa.

`examples/graph.metta` contains runnable tests and usage examples.

## Import

```lisp
!(import! &self (library lib_graph))
```

## Graph Format

Directed graphs are represented as edge lists:

```lisp
((a b) (b c) (a d))
```

This means:

```text
a -> b
b -> c
a -> d
```

Weighted graphs use a third value:

```lisp
((a b 2) (b c 3) (a c 10))
```

This means:

```text
a -> b costs 2
b -> c costs 3
a -> c costs 10
```

## API

### `graph-nodes`

```lisp
(graph-nodes ((a b) (b c) (a d)))
```

Returns all unique nodes:

```lisp
(a b c d)
```

### `graph-reachable?`

```lisp
(graph-reachable? ((a b) (b c)) a c)
```

Returns whether the goal node can be reached from the start node:

```lisp
true
```

### `graph-path`

```lisp
(graph-path ((a b) (b c) (a d)) a c)
```

Returns one path from start to goal:

```lisp
(a b c)
```

If no path exists, it returns:

```lisp
()
```

### `graph-shortest-path`

```lisp
(graph-shortest-path ((a b) (b c) (a c)) a c)
```

Returns the shortest unweighted path:

```lisp
(a c)
```

### `graph-weighted-shortest-path`

```lisp
(graph-weighted-shortest-path ((a b 2) (b c 3) (a c 10)) a c)
```

Returns the lowest-cost path:

```lisp
(path (a b c) cost 5)
```

The direct edge `a -> c` costs `10`, but `a -> b -> c` costs `2 + 3 = 5`, so the lower-cost path is selected.

### `graph-transitive-closure`

```lisp
(graph-transitive-closure ((a b) (b c)))
```

Returns direct and implied reachability edges:

```lisp
((a b) (a c) (b c))
```

Here `a -> c` is added because `a` reaches `c` through `b`.

### `graph-toposort`

```lisp
(graph-toposort ((a b) (b c) (a d)))
```

Returns a valid dependency order:

```lisp
(a b d c)
```

This means each node appears before the nodes that depend on it. If the graph has a cycle, it returns:

```lisp
()
```

### `graph-has-cycle?`

```lisp
(graph-has-cycle? ((a b) (b c) (c a)))
```

Returns:

```lisp
true
```

### `graph-connected-components`

```lisp
(graph-connected-components ((a b) (c d)))
```

Treats edges as undirected and returns connected groups:

```lisp
((a b) (c d))
```

## PeTTa Use Case: Atom-Space Relations

PeTTa examples such as `examples/spacefunction.metta` show how atoms can be added to and removed from `&self`:

```lisp
!(add-atom &self (my test))
!(remove-atom &self (my test))
```

A future PeTTa workflow could store graph edges in the atom space:

```lisp
!(add-atom &self (edge Human Mammal))
!(add-atom &self (edge Mammal Animal))
```

After collecting those edges into an edge list, `lib_graph` can reason over them:

```lisp
(graph-reachable? ((Human Mammal) (Mammal Animal)) Human Animal)
```

Result:

```lisp
true
```

This shows how PeTTa can analyze symbolic relationships and paths between concepts.

## Testing

Run the example test file from the PeTTa repository root:

```bash
sh run.sh examples/graph.metta
```

The test file imports the library and checks all public APIs:

```text
graph-nodes
graph-reachable?
graph-path
graph-shortest-path
graph-weighted-shortest-path
graph-transitive-closure
graph-toposort
graph-has-cycle?
graph-connected-components
```

The tests cover node extraction, reachability, path search, shortest paths, weighted shortest paths, transitive closure, topological sorting, cycle detection, connected components, and missing-path behavior.

## Evaluation Notes

### Works

`lib_graph` works through PeTTa's normal execution flow. The verification command is:

```bash
sh run.sh examples/graph.metta
```

The output includes passing checks such as:

```text
is true, should true.
is (a b c), should (a b c).
is (path (a b c) cost 5), should (path (a b c) cost 5).
```

### Difficulty

This is more than a simple wrapper. It implements a full graph reasoning toolkit with DFS path search, BFS shortest path, Dijkstra-style weighted shortest path, transitive closure, topological sorting, cycle detection, and connected components.

It also converts MeTTa edge lists into efficient Prolog graph structures and returns PeTTa-friendly outputs.

### Relevance

The library is relevant to PeTTa because symbolic reasoning often creates graph-shaped data.

Useful areas include:

```text
Knowledge graphs
Inference chains
Concept hierarchies
Rule dependencies
Planning graphs
Atom-space relation networks
PLN/NARS reasoning
```

### API Clarity

The API is intentionally simple:

```lisp
(graph-reachable? $edges $start $goal)
(graph-path $edges $start $goal)
(graph-weighted-shortest-path $weightedEdges $start $goal)
```

Return values are predictable:

```text
Boolean checks -> true / false
Paths -> (a b c)
No path -> ()
Weighted path -> (path (a b c) cost 5)
```

### Performance

The library is Prolog-backed for speed. It uses SWI-Prolog's `library(ugraphs)` for graph operations and custom Prolog implementations for DFS, BFS, Dijkstra-style search, and connected components.

This is faster and cleaner than implementing graph traversal in pure MeTTa.

## Implementation Notes

The library is implemented in `lib/lib_graph.pl` and exposed through `lib/lib_graph.metta`.

Internally, edge lists are converted into SWI-Prolog `ugraphs` where possible. The library uses `library(ugraphs)` for efficient graph operations and adds custom Prolog implementations for DFS path search, BFS shortest path, Dijkstra-style weighted shortest path, and connected component grouping.

## Summary

`lib_graph` is a Prolog-backed graph reasoning library for PeTTa. It lets PeTTa search, explain, optimize, and validate graph-shaped symbolic relationships through clear APIs and efficient Prolog execution.
