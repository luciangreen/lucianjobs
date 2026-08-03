:- module(reward_engine, [
    calculate_rewards/3,
    reward_eligibility/3,
    reward_components/3,
    reward_total/2,
    reward_explanation/2
]).

:- use_module(library(lists)).
:- use_module(persistence).
:- use_module(understanding_assessment).
:- use_module(prestigiousness_assessment).
:- use_module(stakeholder_reviews).
:- use_module(fairness_rules).
:- use_module(validation).
:- use_module(hrm_utils).

calculate_rewards(ProjectId, StakeholderId, RewardId) :-
    validation:ensure_entity(project, ProjectId, calculate_rewards),
    reward_eligibility(ProjectId, StakeholderId, Eligibility),
    reward_components(ProjectId, StakeholderId, Components),
    reward_total(Components, Total),
    recognition(ProjectId, StakeholderId, Recognition),
    persistence:generate_id(reward, RewardId),
    Explanation = reward_explanation{
        project_id:ProjectId,
        stakeholder_id:StakeholderId,
        eligibility:Eligibility,
        components:Components,
        total:Total,
        recognition:Recognition
    },
    Reward = reward{
        id:RewardId,
        project_id:ProjectId,
        stakeholder_id:StakeholderId,
        eligibility:Eligibility,
        components:Components,
        total:Total,
        recognition:Recognition,
        explanation:Explanation
    },
    persistence:store_entity(reward, RewardId, Reward).

reward_eligibility(ProjectId, StakeholderId, eligible(Category)) :-
    stakeholder_category(StakeholderId, Category),
    \+ blocked_reward(ProjectId),
    !.
reward_eligibility(ProjectId, _, blocked(safety_failure)) :-
    blocked_reward(ProjectId).

reward_components(ProjectId, StakeholderId, Components) :-
    persistence:fetch_entity(project, ProjectId, Project),
    get_dict(base_work_value, Project, BaseWorkValue),
    understanding_assessment:understanding_result(ProjectId, UnderstandingScore, _),
    (   prestigiousness_assessment:prestigiousness_eligible(ProjectId)
    ->  prestigiousness_assessment:prestigiousness_result(ProjectId, PrestigiousnessScore, _)
    ;   PrestigiousnessScore = 0
    ),
    impact_factor(ProjectId, StakeholderId, ImpactFactor),
    responsibility_factor(ProjectId, ResponsibilityFactor),
    fairness_rules:fairness_check(_{popularity_used:false, automated_penalty_only:false}, FairnessResult),
    fairness_multiplier(FairnessResult, EquityAdjustment),
    completion_factor(ProjectId, CompletionFactor),
    QualityFactor is max(0.5, PrestigiousnessScore / 100),
    UnderstandingFactor is UnderstandingScore / 100,
    Components = [
        component(base_work_value, BaseWorkValue),
        component(completion, CompletionFactor),
        component(understanding, UnderstandingFactor),
        component(quality, QualityFactor),
        component(impact, ImpactFactor),
        component(responsibility, ResponsibilityFactor),
        component(equity_adjustment, EquityAdjustment)
    ],
    validation:validate_reward_components(Components).

reward_total(Components, Total) :-
    memberchk(component(base_work_value, Base), Components),
    include(not_base_component, Components, Factors),
    foldl(multiply_component, Factors, Base, Total0),
    Total is round(Total0).

reward_explanation(RewardId, Explanation) :-
    persistence:fetch_entity(reward, RewardId, Reward),
    get_dict(explanation, Reward, Explanation).

recognition(ProjectId, StakeholderId, Recognition) :-
    stakeholder_category(StakeholderId, Category),
    understanding_assessment:mandatory_understanding_complete(ProjectId),
    !,
    Recognition = [complete_understanding, Category].
recognition(_, StakeholderId, [partial_progress, Category]) :-
    stakeholder_category(StakeholderId, Category).

impact_factor(ProjectId, StakeholderId, ImpactFactor) :-
    stakeholder_category(StakeholderId, Category),
    stakeholder_review_metric(Category, Metric),
    stakeholder_reviews:project_reviews(ProjectId, Reviews),
    findall(
        Score,
        (
            member(Review, Reviews),
            get_dict(criteria_results, Review, CriteriaResults),
            get_dict(Metric, CriteriaResults, Score0),
            Score is Score0 / 100
        ),
        Scores
    ),
    (   Scores == []
    ->  ImpactFactor = 1.0
    ;   max_list(Scores, ImpactFactor)
    ).

responsibility_factor(ProjectId, 0.0) :-
    blocked_reward(ProjectId),
    !.
responsibility_factor(_, 1.0).

completion_factor(ProjectId, 1.0) :-
    persistence:fetch_entity(project, ProjectId, Project),
    get_dict(stage, Project, Stage),
    memberchk(Stage, [assessment, completed, comparison_reflection, final_revision, comparison_unlocked, independent_implementation]),
    !.
completion_factor(_, 0.8).

blocked_reward(ProjectId) :-
    understanding_assessment:understanding_result(ProjectId, _, _),
    persistence:fetch_entity(evidence, _, Evidence),
    get_dict(project_id, Evidence, EvidenceProjectId),
    get_dict(critical_failure, Evidence, CriticalFailure),
    EvidenceProjectId == ProjectId,
    CriticalFailure == true.

stakeholder_review_metric(employee, reliability).
stakeholder_review_metric(customer, customer_value).
stakeholder_review_metric(community, community_value).
stakeholder_review_metric(team, teamwork).
stakeholder_review_metric(learning, improvement).
stakeholder_review_metric(creative_contribution, craftsmanship).

fairness_multiplier(passed, 1.0).
fairness_multiplier(failed(_), 0.0).

not_base_component(component(base_work_value, _)) :-
    !,
    fail.
not_base_component(_).

multiply_component(component(_, Factor), Acc, Result) :-
    Result is Acc * Factor.
