:- begin_tests(learning_pathways).

:- use_module(test_support).
:- use_module('../src/comparison_control.pl', []).
:- use_module('../src/learning_pathways.pl', []).
:- use_module('../src/hrm_rewards.pl').

test(project_starts_in_orientation, [setup(test_support:reset_environment)]) :-
    test_support:create_job_fixture('https://github.com/luciangreen/detlog', _, JobId),
    hrm_rewards:create_learning_project(JobId, participant_1, _{}, ProjectId),
    learning_pathways:project_status(ProjectId, Project),
    get_dict(stage, Project, Stage),
    Stage == orientation.

test(comparison_lock_denies_early_access, [setup(test_support:reset_environment)]) :-
    test_support:create_job_fixture('https://github.com/luciangreen/detlog', _, JobId),
    hrm_rewards:create_learning_project(JobId, participant_1, _{}, ProjectId),
    comparison_control:comparison_may_be_unlocked(ProjectId, denied(independent_stage_incomplete)).

test(independent_stage_unlocks_comparison, [setup(test_support:reset_environment), nondet]) :-
    test_support:create_project_fixture('https://github.com/luciangreen/detlog', participant_1, _{}, ProjectId),
    hrm_rewards:unlock_comparison(ProjectId, unlocked(ProjectId)),
    hrm_rewards:submit_reflection(ProjectId, _{
        similarities:["both preserve semantics"],
        differences:["uses explicit traces"],
        lessons:["comparison improved debugging strategy"]
    }, _),
    learning_pathways:project_status(ProjectId, Project),
    get_dict(stage, Project, Stage),
    Stage == comparison_reflection.

:- end_tests(learning_pathways).
