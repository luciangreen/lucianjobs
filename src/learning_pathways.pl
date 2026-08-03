:- module(learning_pathways, [
    create_learning_project/4,
    job_learning_path/3,
    project_status/2
]).

:- use_module(library(lists)).
:- use_module(persistence).
:- use_module(job_generator).
:- use_module(task_generator).
:- use_module(validation).
:- use_module(hrm_utils).

create_learning_project(JobId, ParticipantId, ProjectOptions, ProjectId) :-
    validation:ensure_entity(job_role, JobId, create_learning_project),
    job_generator:job_role(JobId, Job),
    persistence:generate_id(project, ProjectId),
    hrm_utils:now_atom(CreatedAt),
    job_learning_path(JobId, ProjectOptions, LearningPath),
    get_dict(title, Job, RoleTitle),
    get_dict(repository_ids, Job, RepositoryIds),
    Project = learning_project{
        id:ProjectId,
        job_id:JobId,
        participant_id:ParticipantId,
        role_title:RoleTitle,
        repository_ids:RepositoryIds,
        stage:orientation,
        creative_vision_ids:[],
        evidence_ids:[],
        reflection_ids:[],
        resource_declarations:[],
        learning_path:LearningPath,
        understanding_threshold:85,
        base_work_value:100,
        created_at:CreatedAt,
        status:active,
        options:ProjectOptions
    },
    persistence:store_entity(project, ProjectId, Project).

job_learning_path(JobId, ParticipantProfile, LearningPath) :-
    validation:ensure_entity(job_role, JobId, job_learning_path),
    job_generator:job_role(JobId, Job),
    get_dict(authentic_task_ids, Job, TaskIds),
    findall(TaskTitle, (member(TaskId, TaskIds), task_generator:work_task(TaskId, Task), get_dict(title, Task, TaskTitle)), TaskTitles),
    LearningPath = learning_path{
        job_id:JobId,
        participant_profile:ParticipantProfile,
        stages:[orientation, vision, independent_design, independent_implementation, comparison_unlocked, comparison_reflection, final_revision, assessment, completed],
        recommended_tasks:TaskTitles
    }.

project_status(ProjectId, Project) :-
    persistence:fetch_entity(project, ProjectId, Project).
