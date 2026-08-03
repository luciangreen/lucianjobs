:- module(persistence, [
    reset_store/0,
    generate_id/2,
    store_entity/3,
    replace_entity/3,
    fetch_entity/3,
    list_entities/2,
    entity_exists/2
]).

:- dynamic stored_entity/3.
:- dynamic entity_counter/2.

reset_store :-
    retractall(stored_entity(_, _, _)),
    retractall(entity_counter(_, _)).

generate_id(Type, Id) :-
    (   retract(entity_counter(Type, Counter0))
    ->  Counter is Counter0 + 1
    ;   Counter = 1
    ),
    asserta(entity_counter(Type, Counter)),
    format(atom(Id), '~w_~d', [Type, Counter]).

store_entity(Type, Id, Entity) :-
    \+ stored_entity(Type, Id, _),
    assertz(stored_entity(Type, Id, Entity)).

replace_entity(Type, Id, Entity) :-
    retractall(stored_entity(Type, Id, _)),
    assertz(stored_entity(Type, Id, Entity)).

fetch_entity(Type, Id, Entity) :-
    stored_entity(Type, Id, Entity).

list_entities(Type, Entities) :-
    findall(Entity, stored_entity(Type, _, Entity), Entities).

entity_exists(Type, Id) :-
    stored_entity(Type, Id, _).
