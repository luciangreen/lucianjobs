:- module(prestigiousness_assessment, [
    assess_prestigiousness/3,
    prestigiousness_result/3,
    prestigiousness_eligible/1
]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(persistence).
:- use_module(evidence_store).
:- use_module(understanding_assessment).
:- use_module(validation).
:- use_module(hrm_utils).

assess_prestigiousness(ProjectId, _Options, AssessmentId) :-
    validation:ensure_entity(project, ProjectId, assess_prestigiousness),
    prestigiousness_result(ProjectId, Score, DimensionResults),
    prestigiousness_status(ProjectId, Score, Status),
    persistence:generate_id(prestigiousness_assessment, AssessmentId),
    Explanation = prestigiousness_explanation{
        project_id:ProjectId,
        score:Score,
        status:Status,
        dimensions:DimensionResults
    },
    hrm_utils:now_atom(CreatedAt),
    Assessment = prestigiousness_assessment{
        id:AssessmentId,
        project_id:ProjectId,
        score:Score,
        dimension_results:DimensionResults,
        status:Status,
        explanation:Explanation,
        created_at:CreatedAt
    },
    persistence:store_entity(prestigiousness_assessment, AssessmentId, Assessment).

prestigiousness_result(ProjectId, Score, DimensionResults) :-
    dimensions_for_project(ProjectId, Dimensions),
    evidence_store:project_evidence(ProjectId, Evidence),
    findall(Review, persistence:fetch_entity(review, _, Review), Reviews0),
    include({ProjectId}/[Review]>>(get_dict(project_id, Review, ReviewProjectId), ReviewProjectId == ProjectId), Reviews0, Reviews),
    maplist(result_for_dimension(Evidence, Reviews), Dimensions, DimensionResults),
    sum_dimension_weights(DimensionResults, Available, Achieved),
    (   Available =:= 0
    ->  Score = 0
    ;   Score is round((Achieved / Available) * 1000) / 10
    ).

prestigiousness_eligible(ProjectId) :-
    persistence:fetch_entity(project, ProjectId, Project),
    get_dict(understanding_threshold, Project, Threshold),
    understanding_assessment:understanding_result(ProjectId, Score, _),
    Score >= Threshold,
    understanding_assessment:mandatory_understanding_complete(ProjectId).

dimensions_for_project(ProjectId, Dimensions) :-
    persistence:fetch_entity(project, ProjectId, Project),
    get_dict(options, Project, Options),
    (   get_dict(prestigiousness_dimensions, Options, Dimensions0)
    ->  Dimensions = Dimensions0
    ;   Dimensions = [
            dimension{id:creative_coherence, weight:20},
            dimension{id:originality, weight:20},
            dimension{id:craftsmanship, weight:20},
            dimension{id:reliability, weight:15},
            dimension{id:customer_value, weight:15},
            dimension{id:community_value, weight:10}
        ]
    ).

result_for_dimension(Evidence, Reviews, Dimension, Result) :-
    get_dict(id, Dimension, DimensionId),
    get_dict(weight, Dimension, Weight),
    findall(
        Strength,
        (
            member(Item, Evidence),
            get_dict(prestigiousness, Item, Prestige),
            get_dict(DimensionId, Prestige, Strength)
        ),
        EvidenceStrengths
    ),
    findall(
        ReviewStrength,
        (
            member(Review, Reviews),
            get_dict(criteria_results, Review, CriteriaResults),
            get_dict(DimensionId, CriteriaResults, ReviewStrength)
        ),
        ReviewStrengths
    ),
    append(EvidenceStrengths, ReviewStrengths, Scores),
    hrm_utils:max_or_zero(Scores, Score),
    Points is Weight * (Score / 100),
    Result = dimension_result{
        dimension_id:DimensionId,
        weight:Weight,
        score:Score,
        points:Points
    }.

prestigiousness_status(ProjectId, _, denied(understanding_gate_not_met)) :-
    \+ prestigiousness_eligible(ProjectId),
    !.
prestigiousness_status(ProjectId, _, denied(unresolved_critical_defect)) :-
    unresolved_critical_defect(ProjectId),
    !.
prestigiousness_status(_, 100, complete) :-
    !.
prestigiousness_status(_, _, partial).

unresolved_critical_defect(ProjectId) :-
    evidence_store:project_evidence(ProjectId, Evidence),
    member(Item, Evidence),
    get_dict(critical_failure, Item, CriticalFailure),
    CriticalFailure == true.

sum_dimension_weights([], 0, 0).
sum_dimension_weights([Result|Rest], TotalWeight, TotalPoints) :-
    sum_dimension_weights(Rest, RestWeight, RestPoints),
    get_dict(weight, Result, Weight),
    get_dict(points, Result, Points),
    TotalWeight is RestWeight + Weight,
    TotalPoints is RestPoints + Points.
