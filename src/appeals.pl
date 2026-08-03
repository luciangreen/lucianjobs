:- module(appeals, [
    submit_appeal/3,
    appeal_outcome/2
]).

:- use_module(persistence).
:- use_module(validation).
:- use_module(understanding_assessment).
:- use_module(reward_engine).
:- use_module(hrm_utils).

submit_appeal(AssessmentId, AppealInput, AppealId) :-
    validation:ensure_entity(understanding_assessment, AssessmentId, submit_appeal),
    persistence:fetch_entity(understanding_assessment, AssessmentId, Assessment),
    persistence:generate_id(appeal, AppealId),
    hrm_utils:now_atom(RecordedAt),
    process_appeal(Assessment, AppealInput, Outcome),
    hrm_utils:dict_get_default(AppealInput, additional_evidence, [], AdditionalEvidence),
    get_dict(appellant_id, AppealInput, AppellantId),
    get_dict(grounds, AppealInput, Grounds),
    Appeal = appeal{
        id:AppealId,
        assessment_id:AssessmentId,
        appellant_id:AppellantId,
        grounds:Grounds,
        additional_evidence:AdditionalEvidence,
        status:OutcomeStatus,
        outcome:Outcome,
        recorded_at:RecordedAt
    },
    get_dict(status, Outcome, OutcomeStatus),
    persistence:store_entity(appeal, AppealId, Appeal).

appeal_outcome(AppealId, Outcome) :-
    persistence:fetch_entity(appeal, AppealId, Appeal),
    get_dict(outcome, Appeal, Outcome).

process_appeal(Assessment, AppealInput, Outcome) :-
    get_dict(grounds, AppealInput, Grounds),
    get_dict(project_id, Assessment, ProjectId),
    get_dict(id, Assessment, AssessmentId),
    (   memberchk(overlooked_evidence, Grounds)
    ->  understanding_assessment:assess_understanding(ProjectId, _{}, RevisedAssessmentId),
        reward_engine:calculate_rewards(ProjectId, employee_participant, RewardId),
        Outcome = appeal_outcome{
            status:upheld,
            original_assessment_id:AssessmentId,
            revised_assessment_id:RevisedAssessmentId,
            reward_id:RewardId
        }
    ;   Outcome = appeal_outcome{
            status:rejected,
            original_assessment_id:AssessmentId
        }
    ).
