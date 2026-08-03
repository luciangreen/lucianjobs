:- module(stakeholder_reviews, [
    submit_review/6,
    allowed_review_dimensions/2,
    project_reviews/2
]).

:- use_module(library(lists)).
:- use_module(persistence).
:- use_module(validation).
:- use_module(hrm_utils).

submit_review(ProjectId, ReviewerRole, CriteriaResults, Comments, ConflictsOfInterest, ReviewId) :-
    validation:ensure_entity(project, ProjectId, submit_review),
    validation:validate_review_role(ReviewerRole),
    allowed_review_dimensions(ReviewerRole, Allowed),
    dict_pairs(CriteriaResults, _, Pairs),
    forall(member(Key-_, Pairs), validation:ensure_member(Key, Allowed, review_dimension)),
    persistence:generate_id(review, ReviewId),
    hrm_utils:now_atom(SubmittedAt),
    Review = review{
        id:ReviewId,
        project_id:ProjectId,
        reviewer_role:ReviewerRole,
        criteria_results:CriteriaResults,
        comments:Comments,
        conflicts_of_interest:ConflictsOfInterest,
        submitted_at:SubmittedAt
    },
    persistence:store_entity(review, ReviewId, Review).

allowed_review_dimensions(employee, [improvement, reliability, teamwork, fulfilment]).
allowed_review_dimensions(customer, [customer_value, usability, communication]).
allowed_review_dimensions(community, [community_value, documentation, mentorship]).
allowed_review_dimensions(technical, [correctness, reliability, craftsmanship, maintainability]).
allowed_review_dimensions(peer, [teamwork, clarity, review_quality]).
allowed_review_dimensions(automated_test, [correctness, reliability]).

project_reviews(ProjectId, Reviews) :-
    findall(
        Review,
        (
            persistence:fetch_entity(review, _, Review),
            get_dict(project_id, Review, ReviewProjectId),
            ReviewProjectId == ProjectId
        ),
        Reviews
    ).
