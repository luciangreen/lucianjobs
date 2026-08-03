:- begin_tests(understanding).

:- use_module(test_support).
:- use_module('../src/hrm_rewards.pl').
:- use_module('../src/understanding_assessment.pl', []).

test(complete_understanding_reaches_100, [setup(test_support:reset_environment), nondet]) :-
    test_support:create_project_fixture('https://github.com/luciangreen/detlog', participant_1, _{}, ProjectId),
    test_support:submit_full_understanding_evidence(ProjectId),
    hrm_rewards:assess_understanding(ProjectId, _{}, AssessmentId),
    understanding_assessment:assessment_explanation(AssessmentId, Explanation),
    get_dict(score, Explanation, Score),
    Score =:= 100,
    understanding_assessment:mandatory_understanding_complete(ProjectId).

test(rounded_but_incomplete_stays_below_100, [setup(test_support:reset_environment), nondet]) :-
    test_support:create_project_fixture('https://github.com/luciangreen/detlog', participant_1, _{}, ProjectId),
    forall(
        member(Criterion, [purpose, input_output_behaviour, internal_process, correctness, application, debugging, modification, explanation, constraints_and_limitations]),
        test_support:submit_understanding_evidence(ProjectId, Criterion, 100)
    ),
    test_support:submit_understanding_evidence(ProjectId, transfer, 96),
    understanding_assessment:understanding_result(ProjectId, Score, _),
    Score =:= 99.6,
    \+ understanding_assessment:mandatory_understanding_complete(ProjectId).

test(popularity_does_not_change_understanding, [setup(test_support:reset_environment), nondet]) :-
    test_support:create_project_fixture('https://github.com/luciangreen/detlog', participant_1, _{}, ProjectId1),
    test_support:submit_full_understanding_evidence(ProjectId1),
    hrm_rewards:submit_evidence(ProjectId1, context, _{
        payload:"Repository has many stars",
        supports:[],
        verified:true,
        strength:100,
        explanation:"Context only"
    }, _),
    understanding_assessment:understanding_result(ProjectId1, Score1, _),
    test_support:create_project_fixture('https://github.com/luciangreen/detlog', participant_2, _{}, ProjectId2),
    test_support:submit_full_understanding_evidence(ProjectId2),
    understanding_assessment:understanding_result(ProjectId2, Score2, _),
    Score1 =:= Score2.

:- end_tests(understanding).
