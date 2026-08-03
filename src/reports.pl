:- module(reports, [
    explain_assessment/2,
    explain_reward/2,
    generate_participant_report/2,
    participant_report_json/2
]).

:- use_module(library(lists)).
:- use_module(library(http/json)).
:- use_module(persistence).
:- use_module(understanding_assessment).
:- use_module(reward_engine).

explain_assessment(AssessmentId, Explanation) :-
    understanding_assessment:assessment_explanation(AssessmentId, Explanation).

explain_reward(RewardId, Explanation) :-
    reward_engine:reward_explanation(RewardId, Explanation).

generate_participant_report(ParticipantId, Report) :-
    findall(
        Project,
        (
            persistence:fetch_entity(project, _, Project),
            get_dict(participant_id, Project, ProjectParticipantId),
            ProjectParticipantId == ParticipantId
        ),
        Projects
    ),
    maplist(project_summary, Projects, Summaries),
    append(
        ['# Participant Report', '', 'Participant: ', ParticipantId, '', '## Projects', ''],
        Summaries,
        Lines
    ),
    atomic_list_concat(Lines, '\n', Report).

participant_report_json(ParticipantId, Json) :-
    findall(
        Summary,
        (
            persistence:fetch_entity(project, _, Project),
            get_dict(participant_id, Project, ProjectParticipantId),
            ProjectParticipantId == ParticipantId,
            project_summary_dict(Project, Summary)
        ),
        Projects
    ),
    Json = _{participant_id:ParticipantId, projects:Projects}.

project_summary(Project, Summary) :-
    project_summary_dict(Project, Dict),
    get_dict(role_title, Dict, RoleTitle),
    get_dict(project_id, Dict, ProjectId),
    get_dict(stage, Dict, Stage),
    format(atom(Summary), '- ~w (~w) stage: ~w', [RoleTitle, ProjectId, Stage]).

project_summary_dict(Project, _{
    project_id:ProjectId,
    role_title:RoleTitle,
    stage:Stage,
    evidence_count:EvidenceCount
}) :-
    get_dict(id, Project, ProjectId),
    get_dict(role_title, Project, RoleTitle),
    get_dict(stage, Project, Stage),
    get_dict(evidence_ids, Project, EvidenceIds),
    length(EvidenceIds, EvidenceCount).
