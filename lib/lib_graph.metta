;; lib_graph.metta - Graph algorithms for PeTTa.

!(import! &self (library lib_import.metta))

;; Edges are represented as ((from to) ...).
(: graph-nodes (-> Expression Expression))
(: graph-reachable? (-> Expression Atom Atom Bool))
(: graph-path (-> Expression Atom Atom Expression))
(: graph-shortest-path (-> Expression Atom Atom Expression))
(: graph-weighted-shortest-path (-> Expression Atom Atom Expression))
(: graph-transitive-closure (-> Expression Expression))
(: graph-toposort (-> Expression Expression))
(: graph-has-cycle? (-> Expression Bool))
(: graph-connected-components (-> Expression Expression))

!(import_prolog_functions_from_file (library lib_graph.pl)
    (graph-nodes
     graph-reachable?
     graph-path
     graph-shortest-path
     graph-weighted-shortest-path
     graph-transitive-closure
     graph-toposort
     graph-has-cycle?
     graph-connected-components))
