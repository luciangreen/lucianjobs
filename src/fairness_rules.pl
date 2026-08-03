:- module(fairness_rules, [
    fairness_check/2,
    access_allowed/3,
    record_consent/4,
    conflict_of_interest/3
]).

:- use_module(library(lists)).
:- use_module(persistence).
:- use_module(validation).
:- use_module(hrm_utils).

fairness_check(Decision, passed) :-
    \+ get_dict(popularity_used, Decision, true),
    \+ get_dict(automated_penalty_only, Decision, true),
    !.
fairness_check(Decision, failed(Issues)) :-
    findall(
        Issue,
        (
            (get_dict(popularity_used, Decision, true), Issue = popularity_substituted_for_quality);
            (get_dict(automated_penalty_only, Decision, true), Issue = automated_only_penalty)
        ),
        Issues
    ).

access_allowed(Viewer, Resource, allowed) :-
    get_dict(visibility, Resource, Visibility),
    get_dict(participant_id, Resource, ParticipantId),
    (
        Viewer == owner
    ;   Visibility == assessor_only,
        Viewer == assessor
    ;   Visibility == team,
        memberchk(Viewer, [assessor, team])
    ;   Visibility == organisation,
        memberchk(Viewer, [assessor, team, organisation])
    ;   Visibility == public_with_consent,
        consent_granted(ParticipantId, publication)
    ),
    !.
access_allowed(_, _, denied).

record_consent(ParticipantId, Scope, Granted, ConsentId) :-
    persistence:generate_id(consent, ConsentId),
    hrm_utils:now_atom(RecordedAt),
    Consent = consent{
        id:ConsentId,
        participant_id:ParticipantId,
        scope:Scope,
        granted:Granted,
        recorded_at:RecordedAt
    },
    persistence:store_entity(consent, ConsentId, Consent).

conflict_of_interest(ReviewerId, ProjectId, conflict) :-
    persistence:fetch_entity(project, ProjectId, Project),
    get_dict(options, Project, Options),
    get_dict(conflicts, Options, ReviewerIds),
    memberchk(ReviewerId, ReviewerIds),
    !.
conflict_of_interest(_, _, clear).

consent_granted(ParticipantId, Scope) :-
    persistence:fetch_entity(consent, _, Consent),
    get_dict(participant_id, Consent, ConsentParticipantId),
    get_dict(scope, Consent, ConsentScope),
    get_dict(granted, Consent, Granted),
    ConsentParticipantId == ParticipantId,
    ConsentScope == Scope,
    Granted == true.
