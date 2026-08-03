:- begin_tests(job_generator).

:- use_module(test_support).
:- use_module('../src/job_generator.pl').

test(job_contains_authentic_tasks_and_competencies, [setup(test_support:reset_environment)]) :-
    test_support:create_job_fixture('https://github.com/luciangreen/detlog', _, JobId),
    job_generator:job_role(JobId, Job),
    get_dict(authentic_task_ids, Job, TaskIds),
    get_dict(competency_ids, Job, CompetencyIds),
    get_dict(status, Job, Status),
    TaskIds \== [],
    CompetencyIds \== [],
    Status == suggested.

:- end_tests(job_generator).
