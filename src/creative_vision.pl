:- module(creative_vision, [
    record_creative_vision/3,
    visions_for_project/2
]).

:- use_module(persistence).
:- use_module(validation).
:- use_module(hrm_utils).

record_creative_vision(ProjectId, VisionInput, VisionId) :-
    validation:ensure_entity(project, ProjectId, creative_vision),
    validation:require_keys(VisionInput, [problem, intended_users, principles, distinctive_features, success_conditions]),
    persistence:fetch_entity(project, ProjectId, Project),
    get_dict(participant_id, Project, DefaultParticipantId),
    hrm_utils:dict_get_default(VisionInput, participant_id, DefaultParticipantId, ParticipantId),
    get_dict(problem, VisionInput, Problem),
    get_dict(intended_users, VisionInput, IntendedUsers),
    get_dict(principles, VisionInput, Principles),
    get_dict(distinctive_features, VisionInput, DistinctiveFeatures),
    get_dict(success_conditions, VisionInput, SuccessConditions),
    persistence:generate_id(vision, VisionId),
    hrm_utils:now_atom(RecordedAt),
    Vision = creative_vision{
        id:VisionId,
        project_id:ProjectId,
        participant_id:ParticipantId,
        problem:Problem,
        intended_users:IntendedUsers,
        principles:Principles,
        distinctive_features:DistinctiveFeatures,
        success_conditions:SuccessConditions,
        recorded_at:RecordedAt
    },
    persistence:store_entity(creative_vision, VisionId, Vision),
    get_dict(creative_vision_ids, Project, ExistingVisionIds),
    append(ExistingVisionIds, [VisionId], VisionIds),
    Updated = Project.put(_{creative_vision_ids:VisionIds, stage:vision}),
    persistence:replace_entity(project, ProjectId, Updated).

visions_for_project(ProjectId, Visions) :-
    findall(
        Vision,
        (
            persistence:fetch_entity(creative_vision, _, Vision),
            get_dict(project_id, Vision, VisionProjectId),
            VisionProjectId == ProjectId
        ),
        Visions
    ).
