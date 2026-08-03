:- begin_tests(rewards).

:- use_module(test_support).
:- use_module('../src/hrm_rewards.pl').
:- use_module('../src/stakeholder_reviews.pl').
:- use_module('../src/reward_engine.pl', []).
:- use_module('../src/persistence.pl').

test(reward_breakdown_is_decomposed_and_reproducible, [setup(test_support:reset_environment), nondet]) :-
    test_support:create_project_fixture('https://github.com/luciangreen/detlog', participant_1, _{}, ProjectId),
    test_support:submit_full_understanding_evidence(ProjectId),
    test_support:submit_prestigiousness_evidence(ProjectId, _{
        creative_coherence:90,
        originality:90,
        craftsmanship:90,
        reliability:90,
        customer_value:80,
        community_value:70
    }),
    stakeholder_reviews:submit_review(ProjectId, employee, _{reliability:90, improvement:95, teamwork:80, fulfilment:100}, "Reliable work", [], _),
    hrm_rewards:calculate_rewards(ProjectId, employee_participant, RewardId1),
    persistence:fetch_entity(reward, RewardId1, Reward1),
    hrm_rewards:calculate_rewards(ProjectId, employee_participant, RewardId2),
    persistence:fetch_entity(reward, RewardId2, Reward2),
    get_dict(components, Reward1, Components1),
    get_dict(components, Reward2, Components2),
    get_dict(total, Reward1, Total1),
    get_dict(total, Reward2, Total2),
    Components1 == Components2,
    Total1 == Total2.

test(customer_approval_cannot_override_safety_failure, [setup(test_support:reset_environment), nondet]) :-
    test_support:create_project_fixture('https://github.com/luciangreen/detlog', participant_1, _{}, ProjectId),
    stakeholder_reviews:submit_review(ProjectId, customer, _{customer_value:100, usability:100, communication:100}, "Loved it", [], _),
    hrm_rewards:submit_evidence(ProjectId, automated_test, _{
        payload:"Safety failure",
        supports:[correctness],
        verified:true,
        strength:0,
        critical_failure:true,
        explanation:"Critical correctness failure"
    }, _),
    hrm_rewards:calculate_rewards(ProjectId, customer_partner, RewardId),
    reward_engine:reward_explanation(RewardId, Explanation),
    get_dict(eligibility, Explanation, Eligibility),
    Eligibility == blocked(safety_failure).

:- end_tests(rewards).
