:- begin_tests(fairness).

:- use_module(test_support).
:- use_module('../src/fairness_rules.pl').
:- use_module('../src/fulfilment.pl').
:- use_module('../src/contribution_accounting.pl').

test(private_fulfilment_stays_private, [setup(test_support:reset_environment), nondet]) :-
    test_support:create_project_fixture('https://github.com/luciangreen/detlog', participant_1, _{}, ProjectId),
    fulfilment:record_fulfilment(participant_1, ProjectId, _{meaningful:true}, private, RecordId),
    fulfilment:fulfilment_visible_to(participant_1, RecordId, allowed),
    fulfilment:fulfilment_visible_to(manager, RecordId, denied).

test(conflict_of_interest_is_detected, [setup(test_support:reset_environment), nondet]) :-
    test_support:create_project_fixture('https://github.com/luciangreen/detlog', participant_1, _{conflicts:[reviewer_1]}, ProjectId),
    fairness_rules:conflict_of_interest(reviewer_1, ProjectId, conflict).

test(team_credit_recognises_non_code_work, [setup(test_support:reset_environment), nondet]) :-
    test_support:create_project_fixture('https://github.com/luciangreen/detlog', participant_1, _{}, ProjectId),
    contribution_accounting:record_contribution(ProjectId, participant_1, documentation, "Wrote documentation", [], 0.2, assessor, _),
    contribution_accounting:record_contribution(ProjectId, participant_2, coordination, "Coordinated work", [], 0.2, assessor, _),
    contribution_accounting:project_team_credit(ProjectId, Summary),
    get_dict(contributions, Summary, Contributions),
    length(Contributions, 2).

:- end_tests(fairness).
