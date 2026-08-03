:- module(repository_catalogue, [
    register_repository/2,
    import_repository/2,
    repository/2,
    all_repositories/1,
    licence_warning/2
]).

:- use_module(persistence).
:- use_module(hrm_utils).
:- use_module(validation).
:- use_module(repository_import).

register_repository(Input, RepositoryId) :-
    repository_import:import_repository_data(Input, RawData),
    persistence:generate_id(repository, RepositoryId),
    hrm_utils:now_atom(RetrievedAt),
    Repository = RawData.put(_{
        id:RepositoryId,
        retrieved_at:RetrievedAt
    }),
    validation:validate_repository(Repository),
    persistence:store_entity(repository, RepositoryId, Repository).

import_repository(Input, RepositoryId) :-
    register_repository(Input, RepositoryId).

repository(RepositoryId, Repository) :-
    persistence:fetch_entity(repository, RepositoryId, Repository).

all_repositories(Repositories) :-
    persistence:list_entities(repository, Repositories).

licence_warning(RepositoryId, licence_warning(RepositoryId, Warning)) :-
    repository(RepositoryId, Repository),
    get_dict(license, Repository, License),
    (   License == unknown
    ->  Warning = 'Repository licence has not been confirmed. Do not assume permission for redistribution or commercial reuse.'
    ;   Warning = 'Repository licence confirmed.'
    ).
