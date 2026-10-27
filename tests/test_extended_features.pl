:- begin_tests(extended_features).

:- use_module(test_support).
:- use_module('../src/hrm_rewards.pl').

test(job_features_are_available_through_public_api, [setup(test_support:reset_environment), nondet]) :-
    test_support:create_job_fixture('https://github.com/luciangreen/detlog', _, JobId),
    hrm_rewards:job_competencies(JobId, Competencies),
    Competencies \= [],
    hrm_rewards:job_tasks(JobId, [Task|_]),
    get_dict(id, Task, TaskId),
    hrm_rewards:task_assessment_map(TaskId, Criteria),
    Criteria \= [],
    hrm_rewards:confirm_generated_job(JobId, "Reviewed by administrator"),
    hrm_rewards:job_role(JobId, Job),
    get_dict(status, Job, approved).

test(concepts_industries_and_resource_declarations_are_available, [setup(test_support:reset_environment), nondet]) :-
    hrm_rewards:import_repository('https://github.com/luciangreen/detlog', RepositoryId),
    hrm_rewards:analyse_repository(RepositoryId, Analysis),
    get_dict(concept_ids, Analysis, [ConceptId]),
    hrm_rewards:confirm_algorithm_concept(ConceptId, "Reviewed concept"),
    hrm_rewards:map_repository_to_industries(RepositoryId, Mappings),
    Mappings \= [],
    test_support:create_job_fixture('https://github.com/luciangreen/detlog', _, JobId),
    hrm_rewards:create_learning_project(JobId, participant_a, _{}, ProjectId),
    hrm_rewards:record_resource_declaration(ProjectId, "README.md", repository_file, DeclarationId),
    hrm_rewards:project_status(ProjectId, Project),
    get_dict(resource_declarations, Project, [DeclarationId]).

test(reviews_and_team_contributions_are_available, [setup(test_support:reset_environment), nondet]) :-
    test_support:create_project_fixture('https://github.com/luciangreen/detlog', participant_a, _{}, ProjectId),
    hrm_rewards:submit_stakeholder_review(
        ProjectId, customer, _{customer_value:90}, "Useful", [], ReviewId),
    hrm_rewards:project_reviews(ProjectId, [Review]),
    get_dict(id, Review, ReviewId),
    hrm_rewards:record_contribution(
        ProjectId, participant_a, documentation, "Wrote accessible documentation", [],
        1.0, assessor, ContributionId),
    hrm_rewards:project_team_credit(ProjectId, Summary),
    get_dict(contributions, Summary, [Contribution]),
    get_dict(id, Contribution, ContributionId).

test(private_fulfilment_is_visible_only_to_participant, [setup(test_support:reset_environment), nondet]) :-
    test_support:create_project_fixture('https://github.com/luciangreen/detlog', participant_a, _{}, ProjectId),
    hrm_rewards:record_fulfilment(
        participant_a, ProjectId, _{meaningful:true}, private, RecordId),
    hrm_rewards:fulfilment_visible_to(participant_a, RecordId, allowed),
    hrm_rewards:fulfilment_visible_to(manager, RecordId, denied).

test(fairness_and_conflict_checks_are_available, [setup(test_support:reset_environment), nondet]) :-
    hrm_rewards:fairness_check(_{popularity_used:false, automated_penalty_only:false}, passed),
    hrm_rewards:fairness_check(_{popularity_used:true}, failed([popularity_substituted_for_quality])),
    test_support:create_project_fixture(
        'https://github.com/luciangreen/detlog', participant_a, _{conflicts:[reviewer_a]}, ProjectId),
    hrm_rewards:conflict_of_interest(reviewer_a, ProjectId, conflict),
    hrm_rewards:conflict_of_interest(reviewer_b, ProjectId, clear).

:- end_tests(extended_features).
