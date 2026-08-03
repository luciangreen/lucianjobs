:- module(understanding_assessment, [
    assess_understanding/3,
    understanding_result/3,
    mandatory_understanding_complete/1,
    assessment_explanation/2,
    understanding_criterion/2
]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(persistence).
:- use_module(evidence_store).
:- use_module(validation).
:- use_module(hrm_utils).

assess_understanding(ProjectId, _Options, AssessmentId) :-
    validation:ensure_entity(project, ProjectId, assess_understanding),
    understanding_result(ProjectId, Score, CriterionResults),
    mandatory_status(ProjectId, Score, CriterionResults, Status),
    persistence:generate_id(understanding_assessment, AssessmentId),
    explanation_for_understanding(ProjectId, Score, CriterionResults, Status, Explanation),
    hrm_utils:now_atom(CreatedAt),
    Assessment = understanding_assessment{
        id:AssessmentId,
        project_id:ProjectId,
        score:Score,
        criterion_results:CriterionResults,
        status:Status,
        explanation:Explanation,
        created_at:CreatedAt
    },
    persistence:store_entity(understanding_assessment, AssessmentId, Assessment).

understanding_result(ProjectId, Score, CriterionResults) :-
    criteria_for_project(ProjectId, Criteria),
    evidence_store:project_evidence(ProjectId, Evidence),
    maplist(result_for_criterion(Evidence), Criteria, CriterionResults),
    sum_weights(CriterionResults, Available, Achieved),
    (   Available =:= 0
    ->  Score = 0
    ;   Score is round((Achieved / Available) * 1000) / 10
    ).

mandatory_understanding_complete(ProjectId) :-
    understanding_result(ProjectId, _, CriterionResults),
    forall(
        member(Result, CriterionResults),
        (
            get_dict(mandatory, Result, Mandatory),
            get_dict(score, Result, ResultScore),
            get_dict(status, Result, ResultStatus),
            Mandatory == true
        ->  ResultScore >= 100,
            ResultStatus == complete
        ;   true
        )
    ),
    \+ critical_understanding_failure(ProjectId).

assessment_explanation(AssessmentId, Explanation) :-
    persistence:fetch_entity(understanding_assessment, AssessmentId, Assessment),
    get_dict(explanation, Assessment, Explanation).

understanding_criterion(CriterionId, Criterion) :-
    member(Criterion, [
        understanding_criterion{id:purpose, project_type:algorithm_project, name:'Purpose', description:'Explain the purpose of the algorithm.', mandatory:true, weight:10, evidence_rules:[explanation, examples]},
        understanding_criterion{id:input_output_behaviour, project_type:algorithm_project, name:'Input and Output Behaviour', description:'Describe inputs, outputs, and examples.', mandatory:true, weight:10, evidence_rules:[examples, tests]},
        understanding_criterion{id:internal_process, project_type:algorithm_project, name:'Internal Process', description:'Trace the internal process accurately.', mandatory:true, weight:10, evidence_rules:[trace, explanation]},
        understanding_criterion{id:correctness, project_type:algorithm_project, name:'Correctness', description:'Demonstrate correct behaviour.', mandatory:true, weight:10, evidence_rules:[tests, review]},
        understanding_criterion{id:application, project_type:algorithm_project, name:'Application', description:'Apply the work to a new example.', mandatory:true, weight:10, evidence_rules:[demo, examples]},
        understanding_criterion{id:debugging, project_type:algorithm_project, name:'Debugging', description:'Diagnose faults and explain repairs.', mandatory:true, weight:10, evidence_rules:[bug_report, repair]},
        understanding_criterion{id:modification, project_type:algorithm_project, name:'Modification', description:'Modify the system without breaking agreed behaviour.', mandatory:true, weight:10, evidence_rules:[code, tests]},
        understanding_criterion{id:explanation, project_type:algorithm_project, name:'Explanation', description:'Explain the result in plain language.', mandatory:true, weight:10, evidence_rules:[documentation, reflection]},
        understanding_criterion{id:constraints_and_limitations, project_type:algorithm_project, name:'Constraints and Limitations', description:'Identify limits and trade-offs.', mandatory:true, weight:10, evidence_rules:[reflection, documentation]},
        understanding_criterion{id:transfer, project_type:algorithm_project, name:'Transfer to a New Problem', description:'Transfer the idea to a related problem.', mandatory:true, weight:10, evidence_rules:[design, examples]}
    ]),
    get_dict(id, Criterion, DefinedId),
    DefinedId = CriterionId.

criteria_for_project(ProjectId, Criteria) :-
    persistence:fetch_entity(project, ProjectId, Project),
    get_dict(options, Project, Options),
    (   get_dict(understanding_criteria, Options, Criteria0)
    ->  Criteria = Criteria0
    ;   findall(Criterion, understanding_criterion(_, Criterion), Criteria)
    ).

result_for_criterion(Evidence, Criterion, Result) :-
    findall(
        Strength,
        (
            member(Item, Evidence),
            get_dict(supports, Item, Supports),
            get_dict(verified, Item, Verified),
            get_dict(strength, Item, Strength),
            get_dict(id, Criterion, CriterionId),
            memberchk(CriterionId, Supports),
            Verified == true
        ),
        Strengths
    ),
    hrm_utils:max_or_zero(Strengths, Score),
    get_dict(mandatory, Criterion, Mandatory),
    get_dict(weight, Criterion, Weight),
    get_dict(name, Criterion, Name),
    get_dict(id, Criterion, CriterionId),
    criterion_status(Mandatory, Score, Status),
    Points is Weight * (Score / 100),
    Result = criterion_result{
        criterion_id:CriterionId,
        name:Name,
        mandatory:Mandatory,
        weight:Weight,
        score:Score,
        points:Points,
        status:Status
    }.

sum_weights([], 0, 0).
sum_weights([Result|Rest], TotalWeight, TotalPoints) :-
    sum_weights(Rest, RestWeight, RestPoints),
    get_dict(weight, Result, Weight),
    get_dict(points, Result, Points),
    TotalWeight is RestWeight + Weight,
    TotalPoints is RestPoints + Points.

mandatory_status(ProjectId, Score, _CriterionResults, complete) :-
    mandatory_understanding_complete(ProjectId),
    Score >= 100,
    !.
mandatory_status(ProjectId, Score, _, incomplete_mandatory_criterion) :-
    Score >= 99.5,
    \+ mandatory_understanding_complete(ProjectId),
    !.
mandatory_status(ProjectId, _, _, critical_failure) :-
    critical_understanding_failure(ProjectId),
    !.
mandatory_status(_, _, _, partial).

explanation_for_understanding(ProjectId, Score, CriterionResults, Status, Explanation) :-
    findall(
        CriterionId,
        (
            member(Result, CriterionResults),
            get_dict(status, Result, ResultStatus),
            get_dict(criterion_id, Result, CriterionId),
            ResultStatus \== complete
        ),
        Missing
    ),
    Explanation = understanding_explanation{
        project_id:ProjectId,
        score:Score,
        status:Status,
        missing_or_incomplete:Missing,
        criteria:CriterionResults
    }.

critical_understanding_failure(ProjectId) :-
    evidence_store:project_evidence(ProjectId, Evidence),
    member(Item, Evidence),
    get_dict(supports, Item, Supports),
    get_dict(critical_failure, Item, CriticalFailure),
    memberchk(correctness, Supports),
    CriticalFailure == true.

criterion_status(true, Score, complete) :-
    Score >= 100,
    !.
criterion_status(true, _, incomplete).
criterion_status(_, Score, complete) :-
    Score >= 100,
    !.
criterion_status(_, _, partial).
