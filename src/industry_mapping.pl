:- module(industry_mapping, [
    map_repository_to_industries/2,
    repository_industry/2
]).

:- use_module(library(lists)).
:- use_module(persistence).
:- use_module(repository_catalogue).
:- use_module(concept_analysis).
:- use_module(validation).

industry_template(logic_programming, 'Logic Programming', 'Deterministic and declarative programming systems').
industry_template(compiler_construction, 'Compiler Construction', 'Program transformation, optimisation, and compiler work').
industry_template(educational_software, 'Educational Software', 'Learning systems, training pathways, and explanatory tooling').
industry_template(creative_technology, 'Creative Technology', 'Creative algorithm design and human-computer interaction').

map_repository_to_industries(RepositoryId, Mappings) :-
    validation:ensure_entity(repository, RepositoryId, map_repository_to_industries),
    repository_catalogue:repository(RepositoryId, Repository),
    findall(
        Mapping,
        inferred_mapping(Repository, Mapping),
        MappingList
    ),
    store_mappings(MappingList, Mappings).

repository_industry(RepositoryId, Mapping) :-
    persistence:fetch_entity(repository_industry, _, Mapping),
    get_dict(repository_id, Mapping, MappingRepositoryId),
    MappingRepositoryId == RepositoryId.

inferred_mapping(Repository, Mapping) :-
    inferred_industry(Repository, IndustryId, Confidence, Basis),
    ensure_industry_record(IndustryId),
    persistence:generate_id(repository_industry, MappingId),
    get_dict(id, Repository, RepositoryId),
    Mapping = repository_industry{
        id:MappingId,
        repository_id:RepositoryId,
        industry_id:IndustryId,
        confidence:Confidence,
        basis:Basis,
        status:review_required
    }.

inferred_industry(Repository, logic_programming, high, topics(Topics)) :-
    get_dict(topics, Repository, Topics),
    memberchk(determinism, Topics).
inferred_industry(Repository, compiler_construction, medium, topics(Topics)) :-
    get_dict(topics, Repository, Topics),
    memberchk(compiler, Topics).
inferred_industry(Repository, educational_software, high, topics(Topics)) :-
    get_dict(topics, Repository, Topics),
    memberchk(education, Topics).
inferred_industry(Repository, creative_technology, medium, description(Description)) :-
    get_dict(description, Repository, Description),
    sub_atom(Description, _, _, _, 'creative').
inferred_industry(Repository, logic_programming, medium, language(Language)) :-
    get_dict(primary_language, Repository, Language),
    Language == prolog.

store_mappings([], []).
store_mappings([Mapping|Rest], [Stored|StoredRest]) :-
    get_dict(id, Mapping, MappingId),
    persistence:store_entity(repository_industry, MappingId, Mapping),
    Stored = Mapping,
    store_mappings(Rest, StoredRest).

ensure_industry_record(IndustryId) :-
    persistence:entity_exists(industry, IndustryId),
    !.
ensure_industry_record(IndustryId) :-
    industry_template(IndustryId, Name, Description),
    Industry = industry{
        id:IndustryId,
        name:Name,
        description:Description
    },
    persistence:store_entity(industry, IndustryId, Industry).
