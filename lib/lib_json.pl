:- module(lib_json, ['json-parse'/2, 'json-stringify'/2]).
:- use_module(library(http/json)).

% Parse JSON string to MeTTa expression
'json-parse'(String, Expr) :-
    setup_call_cleanup(open_string(String, Stream),
                       json_read_dict(Stream, Dict),
                       close(Stream)),
    dict_to_metta(Dict, Expr).

% Stringify MeTTa expression to JSON string
'json-stringify'(Expr, String) :-
    metta_to_dict(Expr, Dict),
    with_output_to(string(String), json_write_dict(current_output, Dict)).

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
metta_to_dict(['json-object'|Pairs], Dict) :- !,
    maplist(metta_to_pair, Pairs, List),
    dict_create(Dict, json, List).
metta_to_dict(['json-array'|Items], List) :- !,
    maplist(metta_to_dict, Items, List).
metta_to_dict(Atom, Atom).

metta_to_pair([Key, Val], KeyStr-Dict) :-
    atom_string(KeyStr, Key),
    metta_to_dict(Val, Dict).
