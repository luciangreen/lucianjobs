:- module(hrm_rewards, [
    import_repository/2,
    register_repository/2,
    analyse_repository/2,
    generate_job_options/2,
    create_learning_project/4,
    record_creative_vision/3,
    submit_evidence/4,
    complete_independent_stage/2,
    unlock_comparison/2,
    submit_reflection/3,
    assess_understanding/3,
    assess_prestigiousness/3,
    calculate_rewards/3,
    explain_assessment/2,
    explain_reward/2,
    submit_appeal/3,
    generate_participant_report/2
]).

:- use_module(repository_catalogue, []).
:- use_module(concept_analysis, []).
:- use_module(job_generator, []).
:- use_module(learning_pathways, []).
:- use_module(creative_vision, []).
:- use_module(evidence_store, []).
:- use_module(comparison_control, []).
:- use_module(understanding_assessment, []).
:- use_module(prestigiousness_assessment, []).
:- use_module(reward_engine, []).
:- use_module(reports, []).
:- use_module(appeals, []).

import_repository(Input, RepositoryId) :-
    repository_catalogue:import_repository(Input, RepositoryId).

register_repository(Input, RepositoryId) :-
    repository_catalogue:register_repository(Input, RepositoryId).

analyse_repository(RepositoryId, Analysis) :-
    concept_analysis:analyse_repository(RepositoryId, Analysis).

generate_job_options(RepositoryId, JobOptions) :-
    job_generator:generate_job_options(RepositoryId, JobOptions).

create_learning_project(JobId, ParticipantId, ProjectOptions, ProjectId) :-
    learning_pathways:create_learning_project(JobId, ParticipantId, ProjectOptions, ProjectId).

record_creative_vision(ProjectId, VisionInput, VisionId) :-
    creative_vision:record_creative_vision(ProjectId, VisionInput, VisionId).

submit_evidence(ProjectId, EvidenceType, EvidenceInput, EvidenceId) :-
    evidence_store:submit_evidence(ProjectId, EvidenceType, EvidenceInput, EvidenceId).

complete_independent_stage(ProjectId, Result) :-
    comparison_control:complete_independent_stage(ProjectId, Result).

unlock_comparison(ProjectId, Decision) :-
    comparison_control:unlock_comparison(ProjectId, Decision).

submit_reflection(ProjectId, ReflectionInput, ReflectionId) :-
    comparison_control:submit_reflection(ProjectId, ReflectionInput, ReflectionId).

assess_understanding(ProjectId, Options, AssessmentId) :-
    understanding_assessment:assess_understanding(ProjectId, Options, AssessmentId).

assess_prestigiousness(ProjectId, Options, AssessmentId) :-
    prestigiousness_assessment:assess_prestigiousness(ProjectId, Options, AssessmentId).

calculate_rewards(ProjectId, StakeholderId, RewardId) :-
    reward_engine:calculate_rewards(ProjectId, StakeholderId, RewardId).

explain_assessment(AssessmentId, Explanation) :-
    reports:explain_assessment(AssessmentId, Explanation).

explain_reward(RewardId, Explanation) :-
    reports:explain_reward(RewardId, Explanation).

submit_appeal(AssessmentId, AppealInput, AppealId) :-
    appeals:submit_appeal(AssessmentId, AppealInput, AppealId).

generate_participant_report(ParticipantId, Report) :-
    reports:generate_participant_report(ParticipantId, Report).
