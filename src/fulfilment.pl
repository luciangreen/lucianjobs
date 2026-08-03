:- module(fulfilment, [
    record_fulfilment/5,
    fulfilment_visible_to/3
]).

:- use_module(persistence).
:- use_module(validation).
:- use_module(hrm_utils).

record_fulfilment(ParticipantId, ProjectId, Responses, Visibility, RecordId) :-
    validation:ensure_entity(project, ProjectId, fulfilment),
    validation:validate_visibility(Visibility),
    persistence:generate_id(fulfilment, RecordId),
    hrm_utils:now_atom(RecordedAt),
    Record = fulfilment_record{
        id:RecordId,
        participant_id:ParticipantId,
        project_id:ProjectId,
        responses:Responses,
        visibility:Visibility,
        recorded_at:RecordedAt
    },
    persistence:store_entity(fulfilment, RecordId, Record).

fulfilment_visible_to(Viewer, RecordId, allowed) :-
    persistence:fetch_entity(fulfilment, RecordId, Record),
    get_dict(participant_id, Record, ParticipantId),
    get_dict(visibility, Record, Visibility),
    (   Viewer == ParticipantId
    ;   Visibility == assessor_only,
        Viewer == assessor
    ;   Visibility == team,
        Viewer == team
    ;   Visibility == organisation,
        Viewer == organisation
    ),
    !.
fulfilment_visible_to(_, _, denied).
