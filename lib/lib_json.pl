:- module(lib_json, [
    'json-parse'/2,
    'json-stringify'/2,
    'json-get'/3,
    'json-has-key?'/3,
    'json-array-get'/3,
    'json-array-length'/2,
    'json-object-keys'/2,
    'json-type'/2
]).
:- use_module(library(http/json)).
:- use_module(library(lists)).

% Parse JSON string to MeTTa expression
'json-parse'(String, Expr) :-
    setup_call_cleanup(open_string(String, Stream),
                       json_read_dict(Stream, Dict),
                       close(Stream)),
    dict_to_metta(Dict, Expr).

% Stringify MeTTa expression to JSON string
'json-stringify'(Expr, String) :-
    metta_to_json_value(Expr, JsonValue),
    with_output_to(string(String), json_write_dict(current_output, JsonValue)).

% Return the value for Key in a json-object, or () when absent.
'json-get'(['json-object'|Pairs], Key, Value) :-
    normalize_key(Key, KeyAtom),
    ( memberchk([KeyAtom, Found], Pairs) -> Value = Found ; Value = [] ), !.
'json-get'(_, _, []).

% Check whether a json-object has Key.
'json-has-key?'(['json-object'|Pairs], Key, Result) :-
    normalize_key(Key, KeyAtom),
    ( memberchk([KeyAtom, _], Pairs) -> Result = true ; Result = false ), !.
'json-has-key?'(_, _, false).

% Return an array item by zero-based index, or () when out of range.
'json-array-get'(['json-array'|Items], Index, Value) :-
    integer(Index),
    Index >= 0,
    ( nth0(Index, Items, Found) -> Value = Found ; Value = [] ), !.
'json-array-get'(_, _, []).

'json-array-length'(['json-array'|Items], Length) :-
    length(Items, Length), !.
'json-array-length'(_, 0).

'json-object-keys'(['json-object'|Pairs], Keys) :-
    findall(Key, member([Key, _], Pairs), Keys), !.
'json-object-keys'(_, []).

'json-type'(['json-object'|_], object) :- !.
'json-type'(['json-array'|_], array) :- !.
'json-type'(Value, string) :- string(Value), !.
'json-type'(Value, number) :- number(Value), !.
'json-type'(true, bool) :- !.
'json-type'(false, bool) :- !.
'json-type'(null, null) :- !.
'json-type'(_, unknown).

% Convert Dict to MeTTa
dict_to_metta(Dict, ['json-object'|Pairs]) :-
    is_dict(Dict), !,
    dict_pairs(Dict, _, List),
    maplist(pair_to_metta, List, Pairs).
dict_to_metta(List, ['json-array'|Items]) :-
    is_list(List), !,
    maplist(dict_to_metta, List, Items).
dict_to_metta(Atom, Atom).

pair_to_metta(Key-Val, [KeyAtom, MettaVal]) :-
    atom_string(KeyAtom, Key),
    dict_to_metta(Val, MettaVal).

% Convert MeTTa to Dict
metta_to_json_value(['json-object'|Pairs], Dict) :- !,
    maplist(metta_to_pair, Pairs, List),
    dict_create(Dict, json, List).
metta_to_json_value(['json-array'|Items], List) :- !,
    maplist(metta_to_json_value, Items, List).
metta_to_json_value(Atom, Atom).

metta_to_pair([Key, Val], KeyStr-Dict) :-
    normalize_key(Key, KeyStr),
    metta_to_json_value(Val, Dict).

normalize_key(Key, Key) :- atom(Key), !.
normalize_key(Key, Atom) :- string(Key), !, atom_string(Atom, Key).
normalize_key(Key, Atom) :- number(Key), !, atom_number(Atom, Key).
