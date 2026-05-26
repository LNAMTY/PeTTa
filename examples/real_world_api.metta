;;; JSON DATA PROCESSING ;;;
;;; Deterministic tests for the Prolog-backed JSON library.

!(import! &self (library lib_json))

;; A realistic API response, kept local so tests do not depend on the network.
(= (todo-json)
   "{\"userId\":1,\"id\":1,\"title\":\"delectus aut autem\",\"completed\":false,\"tags\":[\"urgent\",\"home\"]}")

(= (todo-object)
   (json-parse (todo-json)))

(= (todo-title)
   (json-get (todo-object) title))

(= (todo-completed?)
   (json-get (todo-object) completed))

(= (todo-first-tag)
   (json-array-get (json-get (todo-object) tags) 0))

!(test (json-type (todo-object)) object)
!(test (json-object-keys (todo-object)) (completed id tags title userId))

!(test (todo-title) "delectus aut autem")
!(test (todo-completed?) false)
!(test (todo-first-tag) "urgent")

!(test (json-has-key? (todo-object) title) true)
!(test (json-has-key? (todo-object) missing) false)
!(test (json-get (todo-object) missing) ())

!(test (json-array-length (json-get (todo-object) tags)) 2)
!(test (json-array-get (json-get (todo-object) tags) 1) "home")
!(test (json-array-get (json-get (todo-object) tags) 4) ())

!(test (json-parse (json-stringify (todo-object))) (todo-object))
