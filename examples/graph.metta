!(import! &self (library lib_graph))

!(test (graph-nodes ((a b) (b c) (a d))) (a b c d))

!(test (graph-reachable? ((a b) (b c) (a d)) a c) true)
!(test (graph-reachable? ((a b) (b c)) c a) false)

!(test (graph-path ((a b) (b c) (a d)) a c) (a b c))
!(test (graph-path ((a b) (b c)) c a) ())
!(test (graph-shortest-path ((a b) (b c) (a c)) a c) (a c))
!(test (graph-shortest-path ((a b) (b c)) c a) ())
!(test (graph-weighted-shortest-path ((a b 2) (b c 3) (a c 10)) a c) (path (a b c) cost 5))
!(test (graph-weighted-shortest-path ((a b 2) (b c 3)) c a) ())

!(test (graph-transitive-closure ((a b) (b c))) ((a b) (a c) (b c)))

!(test (graph-toposort ((a b) (b c) (a d))) (a b d c))
!(test (graph-has-cycle? ((a b) (b c) (c a))) true)
!(test (graph-has-cycle? ((a b) (b c))) false)

!(test (graph-connected-components ((a b) (c d))) ((a b) (c d)))
