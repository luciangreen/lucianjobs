:- module(hrm_rewards, [
    import_repository/2,
    register_repository/2,
    analyse_repository/2,
    confirm_algorithm_concept/2,
    map_repository_to_industries/2,
    generate_job_options/2,
    job_role/2,
    confirm_generated_job/2,
    job_competencies/2,
    job_tasks/2,
    task_assessment_map/2,
    create_learning_project/4,
    project_status/2,
    record_creative_vision/3,
    record_resource_declaration/4,
    submit_evidence/4,
    complete_independent_stage/2,
    unlock_comparison/2,
    submit_reflection/3,
    submit_stakeholder_review/6,
    project_reviews/2,
    record_contribution/8,
    project_team_credit/2,
    record_fulfilment/5,
    fulfilment_visible_to/3,
    fairness_check/2,
    conflict_of_interest/3,
    assess_understanding/3,
    assess_prestigiousness/3,
    calculate_rewards/3,
    explain_assessment/2,
    explain_reward/2,
    submit_appeal/3,
    generate_participant_report/2,
    participant_report_json/2
]).

:- use_module(repository_catalogue, []).
:- use_module(concept_analysis, []).
:- use_module(industry_mapping, []).
:- use_module(job_generator, []).
:- use_module(learning_pathways, []).
:- use_module(task_generator, []).
:- use_module(competency_model, []).
:- use_module(creative_vision, []).
:- use_module(evidence_store, []).
:- use_module(comparison_control, []).
:- use_module(stakeholder_reviews, []).
:- use_module(contribution_accounting, []).
:- use_module(fulfilment, []).
:- use_module(fairness_rules, []).
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

confirm_algorithm_concept(ConceptId, Note) :-
    concept_analysis:confirm_algorithm_concept(ConceptId, Note).

map_repository_to_industries(RepositoryId, Mappings) :-
    industry_mapping:map_repository_to_industries(RepositoryId, Mappings).

generate_job_options(RepositoryId, JobOptions) :-
    job_generator:generate_job_options(RepositoryId, JobOptions).

job_role(JobId, Job) :-
    job_generator:job_role(JobId, Job).

confirm_generated_job(JobId, Note) :-
    job_generator:confirm_generated_job(JobId, Note).

job_competencies(JobId, Competencies) :-
    job_generator:job_role(JobId, Job),
    get_dict(competency_ids, Job, CompetencyIds),
    maplist(fetch_competency, CompetencyIds, Competencies).

job_tasks(JobId, Tasks) :-
    job_generator:job_role(JobId, Job),
    get_dict(authentic_task_ids, Job, TaskIds),
    maplist(fetch_task, TaskIds, Tasks).

task_assessment_map(TaskId, AssessmentCriteria) :-
    task_generator:task_assessment_map(TaskId, AssessmentCriteria).

create_learning_project(JobId, ParticipantId, ProjectOptions, ProjectId) :-
    learning_pathways:create_learning_project(JobId, ParticipantId, ProjectOptions, ProjectId).

project_status(ProjectId, Project) :-
    learning_pathways:project_status(ProjectId, Project).

record_creative_vision(ProjectId, VisionInput, VisionId) :-
    creative_vision:record_creative_vision(ProjectId, VisionInput, VisionId).

record_resource_declaration(ProjectId, Resource, ResourceType, DeclarationId) :-
    comparison_control:record_resource_declaration(ProjectId, Resource, ResourceType, DeclarationId).

submit_evidence(ProjectId, EvidenceType, EvidenceInput, EvidenceId) :-
    evidence_store:submit_evidence(ProjectId, EvidenceType, EvidenceInput, EvidenceId).

complete_independent_stage(ProjectId, Result) :-
    comparison_control:complete_independent_stage(ProjectId, Result).

unlock_comparison(ProjectId, Decision) :-
    comparison_control:unlock_comparison(ProjectId, Decision).

submit_reflection(ProjectId, ReflectionInput, ReflectionId) :-
    comparison_control:submit_reflection(ProjectId, ReflectionInput, ReflectionId).

submit_stakeholder_review(ProjectId, ReviewerRole, CriteriaResults, Comments, ConflictsOfInterest, ReviewId) :-
    stakeholder_reviews:submit_review(ProjectId, ReviewerRole, CriteriaResults, Comments, ConflictsOfInterest, ReviewId).

project_reviews(ProjectId, Reviews) :-
    stakeholder_reviews:project_reviews(ProjectId, Reviews).

record_contribution(ProjectId, ParticipantId, ContributionType, Description, EvidenceIds, Proportion, ConfirmedBy, ContributionId) :-
    contribution_accounting:record_contribution(ProjectId, ParticipantId, ContributionType, Description, EvidenceIds, Proportion, ConfirmedBy, ContributionId).

project_team_credit(ProjectId, Summary) :-
    contribution_accounting:project_team_credit(ProjectId, Summary).

record_fulfilment(ParticipantId, ProjectId, Responses, Visibility, RecordId) :-
    fulfilment:record_fulfilment(ParticipantId, ProjectId, Responses, Visibility, RecordId).

fulfilment_visible_to(Viewer, RecordId, Decision) :-
    fulfilment:fulfilment_visible_to(Viewer, RecordId, Decision).

fairness_check(Decision, Result) :-
    fairness_rules:fairness_check(Decision, Result).

conflict_of_interest(ReviewerId, ProjectId, Result) :-
    fairness_rules:conflict_of_interest(ReviewerId, ProjectId, Result).

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

participant_report_json(ParticipantId, Json) :-
    reports:participant_report_json(ParticipantId, Json).

fetch_competency(CompetencyId, Competency) :-
    competency_model:competency(CompetencyId, Competency).

fetch_task(TaskId, Task) :-
    task_generator:work_task(TaskId, Task).
