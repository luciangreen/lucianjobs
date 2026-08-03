:- module(task_generator, [
    generate_tasks_for_job/2,
    work_task/2,
    task_assessment_map/2
]).

:- use_module(library(lists)).
:- use_module(persistence).

generate_tasks_for_job(Job, Tasks) :-
    job_task_templates(Job, Templates),
    store_tasks(Templates, Tasks).

work_task(TaskId, Task) :-
    persistence:fetch_entity(work_task, TaskId, Task).

task_assessment_map(TaskId, AssessmentCriteria) :-
    work_task(TaskId, Task),
    get_dict(assessment_criteria, Task, AssessmentCriteria).

job_task_templates(Job, [
    work_task{
        job_id:JobId,
        title:'Write an independent implementation',
        brief:'Create an original implementation before detailed comparison.',
        inputs:[creative_vision, specification],
        required_outputs:[code, tests, documentation],
        constraints:[independent_creation, explainability],
        beneficiary:employee,
        difficulty:intermediate,
        estimated_effort:'1 week',
        assessment_criteria:[purpose, internal_process, correctness, originality]
    },
    work_task{
        job_id:JobId,
        title:'Explain the algorithm to a beginner',
        brief:'Produce accessible educational material for the repository concept.',
        inputs:[concept_summary],
        required_outputs:[documentation, examples],
        constraints:[plain_language, accuracy],
        beneficiary:community,
        difficulty:intermediate,
        estimated_effort:'2 days',
        assessment_criteria:[explanation, transfer, community_value]
    },
    work_task{
        job_id:JobId,
        title:'Prepare customer-oriented validation',
        brief:'Demonstrate the solution against beneficiary needs without replacing technical correctness.',
        inputs:[requirements, implementation],
        required_outputs:[demo, customer_feedback, test_results],
        constraints:[safety, usefulness],
        beneficiary:customer,
        difficulty:advanced,
        estimated_effort:'3 days',
        assessment_criteria:[application, correctness, customer_value]
    }
]) :-
    get_dict(id, Job, JobId).

store_tasks([], []).
store_tasks([Template|Rest], [Stored|StoredRest]) :-
    persistence:generate_id(task, TaskId),
    Stored = Template.put(_{id:TaskId}),
    persistence:store_entity(work_task, TaskId, Stored),
    store_tasks(Rest, StoredRest).
