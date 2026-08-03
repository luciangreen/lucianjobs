:- module(cli, [main/1]).

:- use_module(library(readutil)).
:- use_module(library(http/json)).
:- use_module(hrm_rewards).
:- use_module(repository_catalogue).
:- use_module(job_generator).
:- use_module(learning_pathways).
:- use_module(reports).
:- use_module(comparison_control).
:- use_module(persistence).

main(Argv) :-
    command_result(Argv, Result),
    print_result(Result).

command_result([repository, import, Url], imported(RepositoryId)) :-
    hrm_rewards:import_repository(Url, RepositoryId).
command_result([repository, list], Repositories) :-
    repository_catalogue:all_repositories(Repositories).
command_result([repository, analyse, RepositoryId], Analysis) :-
    hrm_rewards:analyse_repository(RepositoryId, Analysis).
command_result([jobs, generate, RepositoryId], Jobs) :-
    hrm_rewards:generate_job_options(RepositoryId, Jobs).
command_result([jobs, list], Jobs) :-
    findall(Job, job_generator:job_role(_, Job), Jobs).
command_result([project, create, JobId, ParticipantId], created(ProjectId)) :-
    hrm_rewards:create_learning_project(JobId, ParticipantId, _{}, ProjectId).
command_result([project, vision, ProjectId, File], recorded(VisionId)) :-
    read_json_file(File, Vision),
    hrm_rewards:record_creative_vision(ProjectId, Vision, VisionId).
command_result([project, status, ProjectId], Project) :-
    learning_pathways:project_status(ProjectId, Project).
command_result([evidence, submit, ProjectId, Type, File], recorded(EvidenceId)) :-
    read_json_file(File, Evidence),
    hrm_rewards:submit_evidence(ProjectId, Type, Evidence, EvidenceId).
command_result([project, complete-independent, ProjectId], Result) :-
    hrm_rewards:complete_independent_stage(ProjectId, Result).
command_result([comparison, unlock, ProjectId], Result) :-
    hrm_rewards:unlock_comparison(ProjectId, Result).
command_result([reflection, submit, ProjectId, File], recorded(ReflectionId)) :-
    read_json_file(File, Reflection),
    hrm_rewards:submit_reflection(ProjectId, Reflection, ReflectionId).
command_result([assess, understanding, ProjectId], recorded(AssessmentId)) :-
    hrm_rewards:assess_understanding(ProjectId, _{}, AssessmentId).
command_result([assess, prestigiousness, ProjectId], recorded(AssessmentId)) :-
    hrm_rewards:assess_prestigiousness(ProjectId, _{}, AssessmentId).
command_result([rewards, calculate, ProjectId], recorded(RewardId)) :-
    hrm_rewards:calculate_rewards(ProjectId, employee_participant, RewardId).
command_result([report, participant, ParticipantId], Report) :-
    reports:generate_participant_report(ParticipantId, Report).
command_result([explain, assessment, AssessmentId], Explanation) :-
    hrm_rewards:explain_assessment(AssessmentId, Explanation).
command_result([explain, reward, RewardId], Explanation) :-
    hrm_rewards:explain_reward(RewardId, Explanation).
command_result([appeal, submit, AssessmentId, File], recorded(AppealId)) :-
    read_json_file(File, Appeal),
    hrm_rewards:submit_appeal(AssessmentId, Appeal, AppealId).
command_result([test], ok) :-
    load_files('tests/test_runner.pl', [silent(true)]),
    run_tests.

print_result(Result) :-
    (   string(Result)
    ->  writeln(Result)
    ;   write_term(Result, [quoted(true), fullstop(true), nl(true)])
    ).

read_json_file(File, Dict) :-
    open(File, read, Stream),
    call_cleanup(json_read_dict(Stream, Dict), close(Stream)).
