:- module(hrm_utils, [
    now_atom/1,
    slug_atom/2,
    ensure_list/2,
    dict_get_default/4,
    dict_list_pairs/2,
    max_or_zero/2,
    stakeholder_category/2
]).

:- use_module(library(apply)).
:- use_module(library(lists)).

now_atom(Atom) :-
    get_time(Time),
    format_time(atom(Atom), '%FT%TZ', Time).

slug_atom(Value, Atom) :-
    term_string(Value, String0),
    string_lower(String0, Lower),
    split_string(Lower, " _:/.-", " _:/.-", Parts0),
    exclude(=(""), Parts0, Parts),
    atomic_list_concat(Parts, '_', Atom).

ensure_list(Value, List) :-
    (   is_list(Value)
    ->  List = Value
    ;   List = [Value]
    ).

dict_get_default(Dict, Key, Default, Value) :-
    (   get_dict(Key, Dict, Found)
    ->  Value = Found
    ;   Value = Default
    ).

dict_list_pairs(Dict, Pairs) :-
    dict_pairs(Dict, _, DictPairs),
    maplist(pair_to_key_value, DictPairs, Pairs).

pair_to_key_value(Key-Value, Key-Value).

max_or_zero([], 0).
max_or_zero(List, Max) :-
    max_list(List, Max).

stakeholder_category(StakeholderId, Category) :-
    atom_string(StakeholderId, StakeholderString),
    member(Category, [employee, customer, community, team, learning, creative_contribution]),
    atom_string(Category, Prefix),
    sub_string(StakeholderString, 0, _, _, Prefix),
    !.
stakeholder_category(_, employee).
