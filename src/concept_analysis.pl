:- module(concept_analysis, [
    analyse_repository/2,
    concept_for_repository/2,
    confirm_algorithm_concept/2
]).

:- use_module(library(lists)).
:- use_module(persistence).
:- use_module(repository_catalogue).
:- use_module(repository_import).
:- use_module(validation).

analyse_repository(RepositoryId, Analysis) :-
    validation:ensure_entity(repository, RepositoryId, analyse_repository),
    repository_catalogue:repository(RepositoryId, Repository),
    create_or_reuse_concept(Repository, Concept),
    get_dict(id, Concept, ConceptId),
    get_dict(status, Concept, Status),
    Analysis = analysis{
        repository_id:RepositoryId,
        concept_ids:[ConceptId],
        concept_status:Status
    }.

concept_for_repository(RepositoryId, Concept) :-
    persistence:fetch_entity(concept, _, Concept),
    get_dict(repository_id, Concept, ConceptRepositoryId),
    ConceptRepositoryId == RepositoryId.

confirm_algorithm_concept(ConceptId, Note) :-
    validation:ensure_entity(concept, ConceptId, confirm_algorithm_concept),
    persistence:fetch_entity(concept, ConceptId, Concept),
    Updated = Concept.put(_{status:confirmed, confirmation_note:Note}),
    persistence:replace_entity(concept, ConceptId, Updated).

create_or_reuse_concept(Repository, Concept) :-
    get_dict(id, Repository, RepositoryId),
    (   concept_for_repository(RepositoryId, Concept0)
    ->  Concept = Concept0
    ;   create_concept(Repository, Concept)
    ).

create_concept(Repository, Concept) :-
    persistence:generate_id(concept, ConceptId),
    concept_template_for_repository(Repository, Template),
    get_dict(id, Repository, RepositoryId),
    get_dict(name, Template, Name),
    get_dict(purpose, Template, Purpose),
    get_dict(inputs, Template, Inputs),
    get_dict(outputs, Template, Outputs),
    get_dict(core_operations, Template, CoreOperations),
    get_dict(constraints, Template, Constraints),
    get_dict(evidence_source, Template, EvidenceSource),
    Concept = concept{
        id:ConceptId,
        repository_id:RepositoryId,
        name:Name,
        purpose:Purpose,
        inputs:Inputs,
        outputs:Outputs,
        core_operations:CoreOperations,
        constraints:Constraints,
        evidence_source:EvidenceSource,
        status:provisional
    },
    persistence:store_entity(concept, ConceptId, Concept).

concept_template_for_repository(Repository, Template) :-
    repository_import:sample_concept_template(Key, Template0),
    repository_import:sample_repository_data(Key, Sample),
    get_dict(name, Sample, SampleName),
    get_dict(name, Repository, RepositoryName),
    SampleName == RepositoryName,
    !,
    Template = Template0.
concept_template_for_repository(Repository, concept_template{
    name:RepositoryName,
    purpose:RepositoryDescription,
    inputs:[unknown],
    outputs:[unknown],
    core_operations:[under_review],
    constraints:[administrator_confirmation_required],
    evidence_source:[metadata],
    status:provisional
}) :-
    get_dict(name, Repository, RepositoryName),
    get_dict(description, Repository, RepositoryDescription).
