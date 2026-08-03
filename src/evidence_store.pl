:- module(evidence_store, [
    submit_evidence/4,
    evidence_valid/2,
    evidence_supports_criterion/3,
    project_evidence/2
]).

:- use_module(library(lists)).
:- use_module(persistence).
:- use_module(validation).
:- use_module(hrm_utils).

submit_evidence(ProjectId, EvidenceType, EvidenceInput, EvidenceId) :-
    validation:ensure_entity(project, ProjectId, submit_evidence),
    normalize_evidence(ProjectId, EvidenceType, EvidenceInput, Evidence),
    validation:validate_evidence(ProjectId, Evidence),
    persistence:generate_id(evidence, EvidenceId),
    StoredEvidence = Evidence.put(_{id:EvidenceId}),
    persistence:store_entity(evidence, EvidenceId, StoredEvidence),
    persistence:fetch_entity(project, ProjectId, Project),
    get_dict(evidence_ids, Project, ExistingEvidenceIds),
    get_dict(stage, Project, Stage),
    append(ExistingEvidenceIds, [EvidenceId], EvidenceIds),
    next_stage_after_evidence(Stage, EvidenceInput, NextStage),
    Updated = Project.put(_{evidence_ids:EvidenceIds, stage:NextStage}),
    persistence:replace_entity(project, ProjectId, Updated).

evidence_valid(Evidence, valid) :-
    get_dict(verified, Evidence, Verified),
    get_dict(payload, Evidence, Payload),
    Verified == true,
    Payload \== missing,
    !.
evidence_valid(Evidence, invalid(Reason)) :-
    get_dict(verified, Evidence, Verified),
    get_dict(payload, Evidence, Payload),
    (   Verified \== true
    ->  Reason = not_verified
    ;   Payload == missing
    ->  Reason = missing_payload
    ;   Reason = missing_payload
    ).

evidence_supports_criterion(EvidenceId, CriterionId, support_result{
    evidence_id:EvidenceId,
    criterion_id:CriterionId,
    score:Score,
    explanation:Explanation
}) :-
    persistence:fetch_entity(evidence, EvidenceId, Evidence),
    get_dict(supports, Evidence, Supports),
    get_dict(strength, Evidence, Score),
    get_dict(explanation, Evidence, Explanation),
    memberchk(CriterionId, Supports).

project_evidence(ProjectId, EvidenceList) :-
    persistence:fetch_entity(project, ProjectId, Project),
    get_dict(evidence_ids, Project, EvidenceIds),
    findall(
        Evidence,
        (
            member(EvidenceId, EvidenceIds),
            persistence:fetch_entity(evidence, EvidenceId, Evidence)
        ),
        EvidenceList
    ).

normalize_evidence(ProjectId, EvidenceType, EvidenceInput, Evidence) :-
    hrm_utils:now_atom(RecordedAt),
    hrm_utils:dict_get_default(EvidenceInput, supports, [], Supports0),
    hrm_utils:dict_get_default(EvidenceInput, tags, [], Tags),
    hrm_utils:dict_get_default(EvidenceInput, visibility, private, Visibility),
    hrm_utils:dict_get_default(EvidenceInput, strength, 100, Strength),
    hrm_utils:dict_get_default(EvidenceInput, payload, EvidenceInput, Payload),
    hrm_utils:dict_get_default(EvidenceInput, verified, true, Verified),
    hrm_utils:dict_get_default(EvidenceInput, explanation, 'Evidence submitted.', Explanation),
    hrm_utils:dict_get_default(EvidenceInput, critical_failure, false, CriticalFailure),
    hrm_utils:dict_get_default(EvidenceInput, prestigiousness, _{}, Prestigiousness),
    Evidence = evidence{
        project_id:ProjectId,
        evidence_type:EvidenceType,
        payload:Payload,
        supports:Supports0,
        tags:Tags,
        verified:Verified,
        strength:Strength,
        visibility:Visibility,
        explanation:Explanation,
        critical_failure:CriticalFailure,
        prestigiousness:Prestigiousness,
        recorded_at:RecordedAt
    }.

next_stage_after_evidence(_, EvidenceInput, independent_design) :-
    hrm_utils:dict_get_default(EvidenceInput, tags, [], Tags),
    memberchk(independent_design, Tags),
    !.
next_stage_after_evidence(Stage, _, Stage).
