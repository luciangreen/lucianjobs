:- begin_tests(repository_catalogue).

:- use_module(test_support).
:- use_module('../src/repository_catalogue.pl').
:- use_module('../src/concept_analysis.pl').
:- use_module('../src/job_generator.pl').

test(import_repository_fixture, [setup(test_support:reset_environment)]) :-
    repository_catalogue:import_repository('https://github.com/luciangreen/detlog', RepositoryId),
    repository_catalogue:repository(RepositoryId, Repository),
    get_dict(owner, Repository, Owner),
    get_dict(primary_language, Repository, Language),
    Owner == luciangreen,
    Language == prolog.

test(unknown_licence_warning, [setup(test_support:reset_environment), nondet]) :-
    repository_catalogue:import_repository('https://github.com/luciangreen/detlog', RepositoryId),
    repository_catalogue:licence_warning(RepositoryId, licence_warning(_, Warning)),
    sub_atom(Warning, _, _, _, 'licence').

test(analysis_creates_provisional_concept, [setup(test_support:reset_environment)]) :-
    repository_catalogue:import_repository('https://github.com/luciangreen/detlog', RepositoryId),
    concept_analysis:analyse_repository(RepositoryId, Analysis),
    get_dict(concept_status, Analysis, ConceptStatus),
    ConceptStatus == provisional.

test(sample_repositories_generate_multiple_jobs, [setup(test_support:reset_environment)]) :-
    findall(
        Count,
        (
            member(Url, [
                'https://github.com/luciangreen/detlog',
                'https://github.com/luciangreen/listprologinterpreter',
                'https://github.com/luciangreen/algorithm-writing'
            ]),
            repository_catalogue:import_repository(Url, RepositoryId),
            concept_analysis:analyse_repository(RepositoryId, _),
            job_generator:generate_job_options(RepositoryId, Jobs),
            length(Jobs, Count)
        ),
        Counts
    ),
    sum_list(Counts, Total),
    Total >= 3.

:- end_tests(repository_catalogue).
