# lib_graph

`lib_graph` is a Prolog-backed graph algorithms library for PeTTa. It exposes graph reasoning APIs to MeTTa programs while using SWI-Prolog for efficient graph conversion and traversal.

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

### `graph-transitive-closure`

```lisp
(graph-transitive-closure ((a b) (b c)))
```

Returns direct and implied reachability edges:

```lisp
((a b) (a c) (b c))
```

### `graph-toposort`

```lisp
(graph-toposort ((a b) (b c) (a d)))
```

Returns a valid dependency order:

```lisp
(a b d c)
```

If the graph has a cycle, it returns:

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

## Testing

Run the example test file from the PeTTa repository root:

```bash
sh run.sh examples/graph.metta
```

The test file covers node extraction, reachability, path search, shortest paths, weighted shortest paths, transitive closure, topological sorting, cycle detection, connected components, and missing-path behavior.

## Implementation Notes

The library is implemented in `lib/lib_graph.pl` and exposed through `lib/lib_graph.metta`.

Internally, edge lists are converted into SWI-Prolog `ugraphs` where possible. The library uses `library(ugraphs)` for efficient graph operations and adds custom Prolog implementations for DFS path search, BFS shortest path, Dijkstra-style weighted shortest path, and connected component grouping.
