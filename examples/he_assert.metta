!(import! &self ../lib/lib_he)

(= (adder) $y)

!(test (assertEqual (+ 1 2) (- 6 3)) True)
!(test (assertAlphaEqual (h $x $y) (h $a $b)) True)
!(test (assertAlphaEqual (quote (+ $x $y)) (quote (+ $a $b))) True)

!(test (assertEqualToResult (+ 1 2) 3) True)
!(test (assertAlphaEqualToResult (h $x $y) (h $a $b)) True)
!(test (assertAlphaEqualToResult (adder) $y) True)

; dynamic adder test (from wiki suggestion):
; adder is defined as (= (adder) $y) and should be alpha-equivalent to $y by variable renaming.
