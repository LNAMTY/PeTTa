;; lib_json.metta - JSON utilities for PeTTa

!(import! &self (library lib_import.metta))

;; Annotations
(: json-parse (-> String Expression))
(: json-stringify (-> %Undefined% String))
(: json-get (-> %Undefined% Atom %Undefined%))
(: json-has-key? (-> %Undefined% Atom Bool))
(: json-array-get (-> %Undefined% Number %Undefined%))
(: json-array-length (-> %Undefined% Number))
(: json-object-keys (-> %Undefined% Expression))
(: json-type (-> %Undefined% Atom))

!(import_prolog_functions_from_file (library lib_json.pl)
    (json-parse
     json-stringify
     json-get
     json-has-key?
     json-array-get
     json-array-length
     json-object-keys
     json-type))
