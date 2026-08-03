:- module(validation, [
    require_keys/2,
    ensure_member/3,
    ensure_entity/3,
    ensure_nonempty_text/3,
    validate_repository/1,
    validate_job/1,
    validate_evidence/2,
    validate_review_role/1,
    validate_visibility/1,
    validate_reward_components/1,
    validation_error/2
]).

:- use_module(persistence).

validation_error(Code, Context) :-
    throw(error(validation_error(Code, Context), _)).

require_keys(Dict, Keys) :-
    forall(
        member(Key, Keys),
        (   get_dict(Key, Dict, Value),
            Value \== ""
        ->  true
        ;   validation_error(missing_required_key, Key)
        )
    ).

ensure_member(Value, Allowed, Context) :-
    (   memberchk(Value, Allowed)
    ->  true
    ;   validation_error(invalid_value, context(Context, Value, Allowed))
    ).

ensure_entity(Type, Id, Context) :-
    (   persistence:entity_exists(Type, Id)
    ->  true
    ;   validation_error(missing_entity, context(Context, Type, Id))
    ).

ensure_nonempty_text(Text, _Code, _Context) :-
    (   string(Text)
    ;   atom(Text)
    ),
    Text \== "",
    !.
ensure_nonempty_text(_, Code, Context) :-
    validation_error(Code, Context).

validate_repository(Repository) :-
    require_keys(Repository, [id, owner, name, url, primary_language, status]).

validate_job(Job) :-
    require_keys(Job, [id, title, industry_id, mission, status]),
    ensure_list_fields(Job, [repository_ids, competency_ids, authentic_task_ids]).

validate_evidence(ProjectId, Evidence) :-
    ensure_entity(project, ProjectId, evidence_project),
    require_keys(Evidence, [supports, visibility]),
    get_dict(visibility, Evidence, Visibility),
    validate_visibility(Visibility),
    ensure_list_fields(Evidence, [supports]).

validate_review_role(Role) :-
    ensure_member(Role, [employee, customer, community, technical, peer, automated_test], review_role).

validate_visibility(Visibility) :-
    ensure_member(Visibility, [private, assessor_only, team, organisation, public_with_consent], visibility).

validate_reward_components(Components) :-
    is_list(Components),
    forall(
        member(component(Name, Value), Components),
        (   atom(Name),
            number(Value)
        ->  true
        ;   validation_error(invalid_reward_component, component(Name, Value))
        )
    ).

ensure_list_fields(Dict, Keys) :-
    forall(
        member(Key, Keys),
        (   get_dict(Key, Dict, Value),
            is_list(Value)
        ->  true
        ;   validation_error(expected_list, Key)
        )
    ).
