:- begin_tests(appeals).

:- use_module(test_support).
:- use_module('../src/hrm_rewards.pl').
:- use_module('../src/appeals.pl', []).

test(appeal_upheld_creates_revised_assessment, [setup(test_support:reset_environment), nondet]) :-
    test_support:create_project_fixture('https://github.com/luciangreen/detlog', participant_1, _{}, ProjectId),
    forall(
        member(Criterion, [purpose, input_output_behaviour, internal_process, correctness, application, debugging, modification, explanation, constraints_and_limitations]),
        test_support:submit_understanding_evidence(ProjectId, Criterion, 100)
    ),
    hrm_rewards:assess_understanding(ProjectId, _{}, AssessmentId),
    test_support:submit_understanding_evidence(ProjectId, transfer, 100),
    hrm_rewards:submit_appeal(AssessmentId, _{
        appellant_id:participant_1,
        grounds:[overlooked_evidence]
    }, AppealId),
    appeals:appeal_outcome(AppealId, Outcome),
    get_dict(status, Outcome, Status),
    get_dict(revised_assessment_id, Outcome, RevisedAssessmentId),
    get_dict(reward_id, Outcome, RewardId),
    Status == upheld,
    nonvar(RevisedAssessmentId),
    nonvar(RewardId).

:- end_tests(appeals).
