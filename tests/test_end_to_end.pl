:- begin_tests(end_to_end).

:- use_module(test_support).
:- use_module('../src/hrm_rewards.pl').
:- use_module('../src/stakeholder_reviews.pl', []).
:- use_module('../src/reports.pl', []).
:- use_module('../src/persistence.pl').

test(demonstration_scenario_runs_end_to_end, [setup(test_support:reset_environment), nondet]) :-
    test_support:create_project_fixture('https://github.com/luciangreen/detlog', participant_demo, _{}, ProjectId),
    test_support:submit_full_understanding_evidence(ProjectId),
    hrm_rewards:unlock_comparison(ProjectId, unlocked(ProjectId)),
    hrm_rewards:submit_reflection(ProjectId, _{
        similarities:["preserves semantics"],
        differences:["uses explicit deterministic structures"],
        intentional_differences:["trace-first output"],
        lessons:["comparison improved reliability notes"]
    }, _),
    test_support:submit_prestigiousness_evidence(ProjectId, _{
        creative_coherence:92,
        originality:93,
        craftsmanship:91,
        reliability:92,
        customer_value:90,
        community_value:94
    }),
    stakeholder_reviews:submit_review(ProjectId, customer, _{customer_value:90, usability:88, communication:92}, "Useful result", [], _),
    stakeholder_reviews:submit_review(ProjectId, community, _{community_value:94, documentation:90, mentorship:88}, "Helpful docs", [], _),
    stakeholder_reviews:submit_review(ProjectId, employee, _{reliability:95, improvement:92, teamwork:80, fulfilment:100}, "Strong execution", [], _),
    hrm_rewards:assess_understanding(ProjectId, _{}, AssessmentId),
    hrm_rewards:assess_prestigiousness(ProjectId, _{}, PrestigiousnessAssessmentId),
    hrm_rewards:calculate_rewards(ProjectId, employee_participant, RewardId),
    hrm_rewards:generate_participant_report(participant_demo, Report),
    persistence:fetch_entity(understanding_assessment, AssessmentId, UnderstandingAssessment),
    persistence:fetch_entity(prestigiousness_assessment, PrestigiousnessAssessmentId, PrestigiousnessAssessment),
    persistence:fetch_entity(reward, RewardId, Reward),
    get_dict(score, UnderstandingAssessment, UnderstandingScore),
    get_dict(score, PrestigiousnessAssessment, PrestigiousnessScore),
    get_dict(total, Reward, RewardTotal),
    UnderstandingScore =:= 100,
    PrestigiousnessScore >= 90,
    sub_atom(Report, _, _, _, 'Participant Report'),
    RewardTotal > 0.

:- end_tests(end_to_end).
