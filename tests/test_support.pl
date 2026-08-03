:- module(test_support, [
    reset_environment/0,
    create_job_fixture/3,
    create_project_fixture/4,
    submit_full_understanding_evidence/1,
    submit_understanding_evidence/3,
    submit_prestigiousness_evidence/2
]).

:- use_module('../src/persistence.pl').
:- use_module('../src/hrm_rewards.pl').

reset_environment :-
    persistence:reset_store.

create_job_fixture(RepositoryUrl, RepositoryId, JobId) :-
    hrm_rewards:import_repository(RepositoryUrl, RepositoryId),
    hrm_rewards:analyse_repository(RepositoryId, _),
    hrm_rewards:generate_job_options(RepositoryId, Jobs),
    Jobs = [Job|_],
    get_dict(id, Job, JobId).

create_project_fixture(RepositoryUrl, ParticipantId, ProjectOptions, ProjectId) :-
    create_job_fixture(RepositoryUrl, _, JobId),
    hrm_rewards:create_learning_project(JobId, ParticipantId, ProjectOptions, ProjectId),
    hrm_rewards:record_creative_vision(ProjectId, _{
        problem:"Build an independent deterministic transformation.",
        intended_users:["Prolog developers"],
        principles:["correctness", "clarity"],
        distinctive_features:["explicit traces"],
        success_conditions:["all mandatory criteria complete"]
    }, _),
    hrm_rewards:submit_evidence(ProjectId, design, _{
        payload:"Independent design sketch",
        supports:[],
        tags:[independent_design],
        verified:true,
        strength:100,
        explanation:"Independent design evidence"
    }, _),
    hrm_rewards:complete_independent_stage(ProjectId, _).

submit_full_understanding_evidence(ProjectId) :-
    submit_understanding_evidence(ProjectId, purpose, 100),
    submit_understanding_evidence(ProjectId, input_output_behaviour, 100),
    submit_understanding_evidence(ProjectId, internal_process, 100),
    submit_understanding_evidence(ProjectId, correctness, 100),
    submit_understanding_evidence(ProjectId, application, 100),
    submit_understanding_evidence(ProjectId, debugging, 100),
    submit_understanding_evidence(ProjectId, modification, 100),
    submit_understanding_evidence(ProjectId, explanation, 100),
    submit_understanding_evidence(ProjectId, constraints_and_limitations, 100),
    submit_understanding_evidence(ProjectId, transfer, 100).

submit_understanding_evidence(ProjectId, Criterion, Strength) :-
    format(atom(Message), 'Evidence for ~w', [Criterion]),
    hrm_rewards:submit_evidence(ProjectId, portfolio, _{
        payload:Message,
        supports:[Criterion],
        verified:true,
        strength:Strength,
        explanation:Message
    }, _).

submit_prestigiousness_evidence(ProjectId, PrestigiousnessDict) :-
    hrm_rewards:submit_evidence(ProjectId, showcase, _{
        payload:"Prestigiousness evidence",
        supports:[explanation],
        verified:true,
        strength:100,
        prestigiousness:PrestigiousnessDict,
        explanation:"Prestigiousness evidence"
    }, _).
