:- module(competency_model, [
    default_competencies/1,
    competency/2,
    job_competencies/2
]).

:- use_module(library(lists)).
:- use_module(persistence).

default_competencies(Competencies) :-
    findall(Competency, competency_template(Competency), Competencies0),
    store_competencies(Competencies0, Competencies).

competency(CompetencyId, Competency) :-
    persistence:fetch_entity(competency, CompetencyId, Competency).

job_competencies(RepositoryTopics, CompetencyIds) :-
    default_competencies(Competencies),
    include(relevant_competency(RepositoryTopics), Competencies, Selected0),
    (   Selected0 == []
    ->  CompetencyIds = [conceptual_understanding]
    ;   maplist({}/[Competency, Id]>>get_dict(id, Competency, Id), Selected0, CompetencyIds)
    ).

competency_template(competency{
    id:conceptual_understanding,
    name:'Conceptual Understanding',
    category:conceptual_understanding,
    description:'Explain algorithm purpose, structure, and trade-offs.',
    level_descriptors:[developing, competent, accomplished, complete],
    evidence_requirements:[explanation, tracing, transfer]
}).
competency_template(competency{
    id:implementation,
    name:'Implementation',
    category:implementation,
    description:'Modify or implement the system correctly.',
    level_descriptors:[developing, competent, accomplished, complete],
    evidence_requirements:[code, tests]
}).
competency_template(competency{
    id:testing,
    name:'Testing',
    category:testing,
    description:'Write and interpret executable checks.',
    level_descriptors:[developing, competent, accomplished, complete],
    evidence_requirements:[tests, results]
}).
competency_template(competency{
    id:explanation,
    name:'Explanation',
    category:explanation,
    description:'Communicate the work clearly and accurately.',
    level_descriptors:[developing, competent, accomplished, complete],
    evidence_requirements:[documentation, reflection]
}).
competency_template(competency{
    id:creative_design,
    name:'Creative Design',
    category:creative_design,
    description:'Show coherent originality within constraints.',
    level_descriptors:[developing, competent, accomplished, complete],
    evidence_requirements:[vision, design]
}).
competency_template(competency{
    id:customer_value,
    name:'Customer Value',
    category:customer_value,
    description:'Deliver useful outcomes to beneficiaries.',
    level_descriptors:[developing, competent, accomplished, complete],
    evidence_requirements:[customer_review, demonstration]
}).
competency_template(competency{
    id:community_contribution,
    name:'Community Contribution',
    category:community_contribution,
    description:'Create reusable, respectful, and helpful contributions.',
    level_descriptors:[developing, competent, accomplished, complete],
    evidence_requirements:[documentation, issue_response]
}).
competency_template(competency{
    id:teamwork,
    name:'Teamwork',
    category:teamwork,
    description:'Collaborate responsibly and recognise invisible work.',
    level_descriptors:[developing, competent, accomplished, complete],
    evidence_requirements:[coordination, review]
}).
competency_template(competency{
    id:ethical_judgement,
    name:'Ethical Judgement',
    category:ethical_judgement,
    description:'Respect fairness, safety, and consent boundaries.',
    level_descriptors:[developing, competent, accomplished, complete],
    evidence_requirements:[safety_checks, consent]
}).
competency_template(competency{
    id:reflection,
    name:'Reflection',
    category:reflection,
    description:'Reflect on differences, lessons, and next steps.',
    level_descriptors:[developing, competent, accomplished, complete],
    evidence_requirements:[reflection]
}).

store_competencies([], []).
store_competencies([Competency|Rest], [Stored|StoredRest]) :-
    get_dict(id, Competency, CompetencyId),
    (   persistence:entity_exists(competency, CompetencyId)
    ->  Stored = Competency
    ;   persistence:store_entity(competency, CompetencyId, Competency),
        Stored = Competency
    ),
    store_competencies(Rest, StoredRest).

relevant_competency(Topics, Competency) :-
    get_dict(id, Competency, CompetencyId),
    (   memberchk(education, Topics),
        memberchk(CompetencyId, [conceptual_understanding, explanation, reflection, customer_value])
    ;   memberchk(compiler, Topics),
        memberchk(CompetencyId, [implementation, testing, conceptual_understanding])
    ;   memberchk(determinism, Topics),
        memberchk(CompetencyId, [implementation, testing, creative_design])
    ;   Topics == [],
        memberchk(CompetencyId, [conceptual_understanding, implementation, explanation])
    ).
