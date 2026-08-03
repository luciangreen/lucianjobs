:- module(contribution_accounting, [
    record_contribution/8,
    project_team_credit/2
]).

:- use_module(library(lists)).
:- use_module(persistence).
:- use_module(validation).
:- use_module(hrm_utils).

record_contribution(ProjectId, ParticipantId, ContributionType, Description, EvidenceIds, Proportion, ConfirmedBy, ContributionId) :-
    validation:ensure_entity(project, ProjectId, contribution),
    persistence:generate_id(contribution, ContributionId),
    Contribution = contribution{
        id:ContributionId,
        project_id:ProjectId,
        participant_id:ParticipantId,
        contribution_type:ContributionType,
        description:Description,
        evidence_ids:EvidenceIds,
        proportion:Proportion,
        confirmed_by:ConfirmedBy
    },
    persistence:store_entity(contribution, ContributionId, Contribution).

project_team_credit(ProjectId, Summary) :-
    findall(
        Contribution,
        (
            persistence:fetch_entity(contribution, _, Contribution),
            get_dict(project_id, Contribution, ContributionProjectId),
            ContributionProjectId == ProjectId
        ),
        Contributions
    ),
    Summary = team_credit{
        project_id:ProjectId,
        contributions:Contributions
    }.
