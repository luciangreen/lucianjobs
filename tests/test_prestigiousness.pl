:- begin_tests(prestigiousness).

:- use_module(test_support).
:- use_module('../src/hrm_rewards.pl').
:- use_module('../src/prestigiousness_assessment.pl', []).
:- use_module('../src/persistence.pl').

test(prestigiousness_gated_by_understanding, [setup(test_support:reset_environment), nondet]) :-
    test_support:create_project_fixture('https://github.com/luciangreen/detlog', participant_1, _{}, ProjectId),
    test_support:submit_prestigiousness_evidence(ProjectId, _{
        creative_coherence:95,
        originality:94,
        craftsmanship:92,
        reliability:90,
        customer_value:88,
        community_value:90
    }),
    hrm_rewards:assess_prestigiousness(ProjectId, _{}, AssessmentId),
    persistence:fetch_entity(prestigiousness_assessment, AssessmentId, Assessment),
    get_dict(status, Assessment, Status),
    Status == denied(understanding_gate_not_met).

test(unconventional_valid_solution_can_score_highly, [setup(test_support:reset_environment), nondet]) :-
    test_support:create_project_fixture('https://github.com/luciangreen/detlog', participant_1, _{}, ProjectId),
    test_support:submit_full_understanding_evidence(ProjectId),
    test_support:submit_prestigiousness_evidence(ProjectId, _{
        creative_coherence:93,
        originality:97,
        craftsmanship:91,
        reliability:90,
        customer_value:88,
        community_value:89
    }),
    hrm_rewards:assess_prestigiousness(ProjectId, _{}, AssessmentId),
    persistence:fetch_entity(prestigiousness_assessment, AssessmentId, Assessment),
    get_dict(score, Assessment, Score),
    get_dict(status, Assessment, Status),
    Score > 90,
    Status == partial.

:- end_tests(prestigiousness).
