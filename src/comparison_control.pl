:- module(comparison_control, [
    complete_independent_stage/2,
    unlock_comparison/2,
    comparison_may_be_unlocked/2,
    record_resource_declaration/4,
    submit_reflection/3,
    project_stage/2
]).

:- use_module(library(lists)).
:- use_module(persistence).
:- use_module(validation).
:- use_module(hrm_utils).

project_stage(ProjectId, Stage) :-
    persistence:fetch_entity(project, ProjectId, Project),
    get_dict(stage, Project, Stage).

record_resource_declaration(ProjectId, Resource, ResourceType, DeclarationId) :-
    validation:ensure_entity(project, ProjectId, resource_declaration),
    persistence:generate_id(resource_declaration, DeclarationId),
    hrm_utils:now_atom(RecordedAt),
    Declaration = resource_declaration{
        id:DeclarationId,
        project_id:ProjectId,
        resource:Resource,
        resource_type:ResourceType,
        recorded_at:RecordedAt
    },
    persistence:store_entity(resource_declaration, DeclarationId, Declaration),
    persistence:fetch_entity(project, ProjectId, Project),
    get_dict(resource_declarations, Project, ExistingDeclarations),
    append(ExistingDeclarations, [DeclarationId], Declarations),
    Updated = Project.put(_{resource_declarations:Declarations}),
    persistence:replace_entity(project, ProjectId, Updated).

complete_independent_stage(ProjectId, completed(stage(independent_implementation))) :-
    validation:ensure_entity(project, ProjectId, complete_independent_stage),
    persistence:fetch_entity(project, ProjectId, Project),
    get_dict(creative_vision_ids, Project, VisionIds),
    VisionIds \== [],
    has_independent_evidence(Project),
    Updated = Project.put(_{stage:independent_implementation}),
    persistence:replace_entity(project, ProjectId, Updated).
complete_independent_stage(ProjectId, denied(missing_prerequisites)) :-
    validation:ensure_entity(project, ProjectId, complete_independent_stage),
    persistence:fetch_entity(project, ProjectId, Project),
    get_dict(creative_vision_ids, Project, VisionIds),
    (VisionIds == [] ; \+ has_independent_evidence(Project)).

comparison_may_be_unlocked(ProjectId, allowed) :-
    persistence:fetch_entity(project, ProjectId, Project),
    get_dict(stage, Project, Stage),
    Stage == independent_implementation,
    !.
comparison_may_be_unlocked(ProjectId, denied(independent_stage_incomplete)) :-
    validation:ensure_entity(project, ProjectId, comparison_unlock),
    persistence:fetch_entity(project, ProjectId, Project),
    get_dict(stage, Project, Stage),
    Stage \== independent_implementation.

unlock_comparison(ProjectId, unlocked(ProjectId)) :-
    comparison_may_be_unlocked(ProjectId, allowed),
    persistence:fetch_entity(project, ProjectId, Project),
    hrm_utils:now_atom(UnlockedAt),
    Updated = Project.put(_{stage:comparison_unlocked, comparison_unlocked_at:UnlockedAt}),
    persistence:replace_entity(project, ProjectId, Updated).
unlock_comparison(ProjectId, Decision) :-
    comparison_may_be_unlocked(ProjectId, Decision),
    Decision \== allowed.

submit_reflection(ProjectId, ReflectionInput, ReflectionId) :-
    validation:ensure_entity(project, ProjectId, reflection),
    validation:require_keys(ReflectionInput, [similarities, differences, lessons]),
    persistence:generate_id(reflection, ReflectionId),
    hrm_utils:now_atom(RecordedAt),
    hrm_utils:dict_get_default(ReflectionInput, intentional_differences, [], IntentionalDifferences),
    get_dict(similarities, ReflectionInput, Similarities),
    get_dict(differences, ReflectionInput, Differences),
    get_dict(lessons, ReflectionInput, Lessons),
    Reflection = reflection{
        id:ReflectionId,
        project_id:ProjectId,
        similarities:Similarities,
        differences:Differences,
        intentional_differences:IntentionalDifferences,
        lessons:Lessons,
        recorded_at:RecordedAt
    },
    persistence:store_entity(reflection, ReflectionId, Reflection),
    persistence:fetch_entity(project, ProjectId, Project),
    get_dict(reflection_ids, Project, ExistingReflectionIds),
    append(ExistingReflectionIds, [ReflectionId], ReflectionIds),
    Updated = Project.put(_{reflection_ids:ReflectionIds, stage:comparison_reflection}),
    persistence:replace_entity(project, ProjectId, Updated).

has_independent_evidence(Project) :-
    get_dict(evidence_ids, Project, EvidenceIds),
    member(EvidenceId, EvidenceIds),
    persistence:fetch_entity(evidence, EvidenceId, Evidence),
    get_dict(tags, Evidence, Tags),
    memberchk(independent_design, Tags).
