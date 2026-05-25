;; lib_json.metta - JSON utilities for PeTTa

!(import! &self (library lib_import.metta))

;; Annotations
(: json-parse (-> String Expression))
(: json-stringify (-> Expression String))

!(import_prolog_functions_from_file (library lib_json.pl)
    (json-parse json-stringify))
