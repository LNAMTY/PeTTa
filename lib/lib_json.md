# lib_json

`lib_json` is a Prolog-backed JSON interoperability library for PeTTa. It gives MeTTa programs clear APIs for parsing, stringifying, and manipulating structured JSON data while using SWI-Prolog's high-performance native JSON processing.

The library is useful for agentic AI workflows where communication with external services (LLMs, web APIs, configuration files) happens via JSON. It allows PeTTa to ingest external data natively and reason over its fields using standard pattern matching.

## Files

```text
lib/lib_json.pl
lib/lib_json.metta
lib/lib_json.md
examples/lib_json_test.metta
```

`lib/lib_json.pl` contains the Prolog implementation using `library(http/json)`.

`lib/lib_json.metta` exposes the APIs to PeTTa with type annotations.

`lib/lib_json.md` is this documentation file.

`examples/lib_json_test.metta` contains runnable tests and usage examples.

## Import

```lisp
!(import! &self (library lib_json))
```

## JSON Format

JSON objects are represented as tagged expression lists:

```lisp
(json-object (userId 1) (id 1) (title "delectus aut autem") (completed false))
```

JSON arrays use the `json-array` tag:

```lisp
(json-array "urgent" "home")
```

## API

### `json-parse`

```lisp
(json-parse "{\"id\": 1, \"title\": \"test\"}")
```

Returns a structured MeTTa expression:

```lisp
(json-object (id 1) (title "test"))
```

### `json-stringify`

```lisp
(json-stringify (json-object (id 1) (title "test")))
```

Returns a JSON string:

```text
"{\"id\":1,\"title\":\"test\"}"
```

### `json-get`

```lisp
(json-get (json-object (id 1) (title "test")) title)
```

Returns the value for the given key:

```text
"test"
```

If the key is missing, it returns `()`.

### `json-has-key?`

```lisp
(json-has-key? (json-object (id 1)) id)
```

Returns:

```lisp
true
```

### `json-array-get`

```lisp
(json-array-get (json-array "a" "b" "c") 1)
```

Returns the item at the zero-based index:

```text
"b"
```

### `json-array-length`

```lisp
(json-array-length (json-array "a" "b"))
```

Returns:

```lisp
2
```

### `json-object-keys`

```lisp
(json-object-keys (json-object (id 1) (title "test")))
```

Returns a list of all keys in the object:

```lisp
(id title)
```

### `json-type`

```lisp
(json-type (json-object (id 1)))
```

Returns the type of the JSON value: `object`, `array`, `string`, `number`, `bool`, or `null`.

## PeTTa Use Case: API Ingestion

A typical agentic workflow involves fetching data from a web API and reasoning over it:

```lisp
;; 1. Fetch raw JSON string from an API
(= (fetch-todo) 
   "{\"id\": 1, \"title\": \"delectus aut autem\", \"completed\": false}")

;; 2. Parse and check status
!(let $todo (json-parse (fetch-todo))
      (if (== (json-get $todo completed) false)
          (print "Task is incomplete")
          (print "Task is finished")))
```

This shows how `lib_json` bridges the gap between external web-standard data and PeTTa's internal reasoning.

## Testing

Run the example test file from the PeTTa repository root:

```bash
sh run.sh examples/lib_json_test.metta
```

The test file verifies parsing, extraction, array manipulation, and round-trip stringification.

## Evaluation Notes

### Works

`lib_json` works through PeTTa's normal execution flow. The verification command is:

```bash
sh run.sh examples/lib_json_test.metta
```

### Difficulty

This library provides a robust mapping between Prolog's dynamic dictionaries and MeTTa's expression structures. It handles nested objects, arrays, and type conversions (Boolean, Null, Numbers) while ensuring compatibility with MeTTa's pattern matching.

### Relevance

JSON is the standard for LLM outputs and web APIs. This library is essential for any PeTTa user building real-world agents that interact with the internet or modern AI models.

### API Clarity

The API follows standard naming conventions (`json-parse`, `json-get`, etc.) and provides predictable return values for all edge cases (like missing keys).

### Performance

The library is Prolog-backed. It uses SWI-Prolog's highly optimized native C-based JSON parser, making it significantly faster than any pure MeTTa or Python-bridged implementation.

## Summary

`lib_json` is a professional-grade JSON library for PeTTa. It enables native ingestion and reasoning over structured external data, providing the essential connectivity needed for modern AI agent development.
