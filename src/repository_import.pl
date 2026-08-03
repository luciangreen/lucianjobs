:- module(repository_import, [
    import_repository_data/2,
    sample_repository_data/2,
    sample_concept_template/2
]).

:- use_module(library(lists)).
:- use_module(validation).

sample_repository_data(detlog, repository_data{
    owner:luciangreen,
    name:detlog,
    url:'https://github.com/luciangreen/detlog',
    description:'Deterministic logic programming and Prolog transformation project',
    primary_language:prolog,
    topics:[determinism, optimisation, compiler],
    license:unknown,
    status:active,
    inferred:false,
    source:fixture
}).

sample_repository_data(listprologinterpreter, repository_data{
    owner:luciangreen,
    name:listprologinterpreter,
    url:'https://github.com/luciangreen/listprologinterpreter',
    description:'List-based Prolog interpreter and educational runtime',
    primary_language:prolog,
    topics:[interpreter, education, logic_programming],
    license:unknown,
    status:active,
    inferred:false,
    source:fixture
}).

sample_repository_data(algorithm_writing, repository_data{
    owner:luciangreen,
    name:'algorithm-writing',
    url:'https://github.com/luciangreen/algorithm-writing',
    description:'Algorithm writing, specification, and creative educational methods',
    primary_language:prolog,
    topics:[education, specification, creative_design],
    license:unknown,
    status:active,
    inferred:false,
    source:fixture
}).

sample_concept_template(detlog, concept_template{
    name:'Deterministic Logic Transformation',
    purpose:'Transform nondeterministic Prolog work into explicit deterministic structures.',
    inputs:[prolog_program, transformation_rules],
    outputs:[deterministic_program, explanation],
    core_operations:[analyse_predicates, identify_nondeterminism, rewrite_program],
    constraints:[preserve_semantics, explainability],
    evidence_source:[readme, predicates, tests]
}).

sample_concept_template(listprologinterpreter, concept_template{
    name:'List Prolog Interpretation',
    purpose:'Interpret Prolog-like programs using list-based structures for learning and experimentation.',
    inputs:[list_encoded_program, query],
    outputs:[answers, traces],
    core_operations:[parse_lists, resolve_query, trace_execution],
    constraints:[educational_clarity, deterministic_reporting],
    evidence_source:[readme, source, examples]
}).

sample_concept_template(algorithm_writing, concept_template{
    name:'Algorithm Writing Pedagogy',
    purpose:'Turn algorithm design into teachable, reviewable, and creative work products.',
    inputs:[problem_statement, learner_vision],
    outputs:[algorithm_specification, examples, reflections],
    core_operations:[capture_vision, structure_requirements, compare_solutions],
    constraints:[originality, fairness, portfolio_value],
    evidence_source:[documentation, examples]
}).

import_repository_data(Input, Data) :-
    is_dict(Input),
    !,
    Data = Input.put(_{source:manual, inferred:false}).
import_repository_data(Input, Data) :-
    atom(Input),
    !,
    import_repository_data_from_atom(Input, Data).
import_repository_data(Input, Data) :-
    string(Input),
    atom_string(Atom, Input),
    import_repository_data_from_atom(Atom, Data).

import_repository_data_from_atom(Input, Data) :-
    (   sample_repository_data(_, Repository),
        get_dict(url, Repository, Url),
        Url == Input
    ->  Data = Repository
    ;   parse_github_url(Input, Owner, Name)
    ->  Data = repository_data{
            owner:Owner,
            name:Name,
            url:Input,
            description:'Unknown description; administrator confirmation required.',
            primary_language:unknown,
            topics:[],
            license:unknown,
            status:provisional,
            inferred:true,
            source:github_url
        }
    ;   validation:ensure_nonempty_text(Input, invalid_repository_source, repository_import)
    ).

parse_github_url(Url, Owner, Name) :-
    atomic_list_concat(Parts, '/', Url),
    append(_, ['github.com', Owner, Name0], Parts),
    atom_string(Name0, NameString0),
    split_string(NameString0, "#?", "#?", [NameString|_]),
    atom_string(Name, NameString).
