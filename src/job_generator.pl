:- module(job_generator, [
    generate_job_options/2,
    job_role/2,
    confirm_generated_job/2,
    repository_job_options/2
]).

:- use_module(library(lists)).
:- use_module(persistence).
:- use_module(repository_catalogue).
:- use_module(concept_analysis).
:- use_module(industry_mapping).
:- use_module(competency_model).
:- use_module(task_generator).
:- use_module(validation).

generate_job_options(RepositoryId, JobOptions) :-
    validation:ensure_entity(repository, RepositoryId, generate_job_options),
    repository_catalogue:repository(RepositoryId, Repository),
    concept_analysis:analyse_repository(RepositoryId, _),
    industry_mapping:map_repository_to_industries(RepositoryId, Mappings),
    get_dict(topics, Repository, Topics),
    competency_model:job_competencies(Topics, CompetencyIds),
    findall(
        Job,
        job_template(Repository, Mappings, CompetencyIds, Job),
        Jobs0
    ),
    store_jobs(Jobs0, JobOptions).

repository_job_options(RepositoryId, JobOptions) :-
    findall(Job, job_role_for_repository(RepositoryId, Job), Existing),
    (   Existing == []
    ->  generate_job_options(RepositoryId, JobOptions)
    ;   JobOptions = Existing
    ).

job_role(JobId, Job) :-
    persistence:fetch_entity(job_role, JobId, Job).

confirm_generated_job(JobId, Note) :-
    validation:ensure_entity(job_role, JobId, confirm_generated_job),
    job_role(JobId, Job),
    Updated = Job.put(_{status:approved, confirmation_note:Note}),
    persistence:replace_entity(job_role, JobId, Updated).

job_role_for_repository(RepositoryId, Job) :-
    persistence:fetch_entity(job_role, _, Job),
    get_dict(repository_ids, Job, RepositoryIds),
    memberchk(RepositoryId, RepositoryIds).

job_template(Repository, Mappings, CompetencyIds, Job) :-
    member(Mapping, Mappings),
    get_dict(industry_id, Mapping, IndustryId),
    suggested_job(IndustryId, Title, Mission, Beneficiaries),
    persistence:generate_id(job, JobId),
    get_dict(id, Repository, RepositoryId),
    Job0 = job_role{
        id:JobId,
        title:Title,
        industry_id:IndustryId,
        level:intermediate,
        mission:Mission,
        repository_ids:[RepositoryId],
        competency_ids:CompetencyIds,
        status:suggested,
        expected_work_products:[code, tests, documentation, explanation],
        assessment_criteria:[understanding, prestigiousness, stakeholder_reviews],
        ethical_boundaries:[no_popularity_substitution, respect_consent, preserve_safety],
        beneficiaries:Beneficiaries,
        estimated_complexity:medium,
        supported_experience_level:intermediate
    },
    task_generator:generate_tasks_for_job(Job0, Tasks),
    maplist({}/[Task, Id]>>get_dict(id, Task, Id), Tasks, TaskIds),
    Job = Job0.put(_{authentic_task_ids:TaskIds}).

suggested_job(logic_programming, 'Algorithm Transformation Engineer', 'Design, test, and explain deterministic Prolog transformations.', [employee, customer, community]).
suggested_job(compiler_construction, 'Compiler and Optimisation Analyst', 'Trace compiler-oriented transformations and preserve semantics while improving structure.', [employee, community]).
suggested_job(educational_software, 'Repository Educator', 'Turn repository concepts into explainable learning pathways and documentation.', [community, customer]).
suggested_job(creative_technology, 'Creative Algorithm Designer', 'Develop an original algorithm variation guided by a documented creative vision.', [employee, community]).

store_jobs([], []).
store_jobs([Job|Rest], [Stored|StoredRest]) :-
    validation:validate_job(Job),
    get_dict(id, Job, JobId),
    persistence:store_entity(job_role, JobId, Job),
    Stored = Job,
    store_jobs(Rest, StoredRest).
