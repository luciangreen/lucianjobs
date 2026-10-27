# Features, API, and test guide

This guide describes what the current implementation does, how to exercise it,
and which parts of the requirements remain incomplete. The system is an
in-memory Prolog prototype, not a production HR or payroll service.

## Implemented features

| Area | Current behavior | Main modules |
| --- | --- | --- |
| Repository catalogue | Registers supplied metadata and recognizes the bundled `detlog`, `listprologinterpreter`, and `algorithm-writing` fixtures. Other GitHub URLs become provisional records with unknown metadata; no network request is made. | `repository_catalogue`, `repository_import` |
| Concepts and industries | Builds a provisional concept from a fixture template or repository metadata. Topic and language rules infer industry mappings with confidence and basis fields. Concepts can be confirmed by an administrator. | `concept_analysis`, `industry_mapping` |
| Jobs, competencies, and tasks | Generates suggested job roles with competency IDs, ethical boundaries, expected work products, and three authentic task templates. Generated jobs remain suggestions until explicitly approved. | `job_generator`, `competency_model`, `task_generator` |
| Learning pathway | Creates a project with an orientation stage, records a creative vision, accepts evidence, requires independent-design evidence before completion, then unlocks comparison and accepts reflection. | `learning_pathways`, `creative_vision`, `comparison_control`, `evidence_store` |
| Assessment | Scores understanding against mandatory criteria and prevents a complete result when required evidence is missing. Prestigiousness is gated by the project's understanding threshold. | `understanding_assessment`, `prestigiousness_assessment` |
| Reviews, fairness, and credit | Stores role-limited stakeholder reviews, checks configured conflicts of interest, records contributions, checks fairness flags, and enforces fulfilment visibility choices. | `stakeholder_reviews`, `fairness_rules`, `contribution_accounting`, `fulfilment` |
| Rewards and explanations | Calculates decomposed reward components, blocks rewards for critical evidence failures, and provides assessment and reward explanations. | `reward_engine`, `reports` |
| Appeals and reports | An appeal citing overlooked evidence creates a revised understanding assessment and reward. Participant reports are available as text or JSON. | `appeals`, `reports` |
| Command line | Offers one-shot commands for repository import/list/analysis, job generation/listing, project/evidence workflow, assessments, rewards, reports, explanations, appeals, and tests. | `cli.pl`, `hrm` |

Generated concepts, industries, jobs, and decisions are deliberately
inspectable. Repository analysis and industry mapping are rule/template based;
they do not scan arbitrary remote repository source code.

## Command-line usage

Install SWI-Prolog 10 or later and run commands from the repository root.

```sh
./hrm repository import https://github.com/luciangreen/detlog
./hrm repository list
./hrm repository analyse repo_1
./hrm jobs generate repo_1
./hrm jobs list
./hrm project create job_software_engineer participant_42
./hrm project vision project_7 vision.json
./hrm project status project_7
./hrm evidence submit project_7 code_sample evidence.json
./hrm project complete-independent project_7
./hrm comparison unlock project_7
./hrm reflection submit project_7 reflection.json
./hrm assess understanding project_7
./hrm assess prestigiousness project_7
./hrm rewards calculate project_7
./hrm report participant participant_42
./hrm explain assessment assessment_3
./hrm explain reward reward_5
./hrm appeal submit assessment_3 appeal.json
./hrm test
```

Commands that read input files expect JSON objects. The CLI starts a new
process for every invocation and the current persistence store is in-memory;
therefore IDs and state created by one CLI invocation are **not** available to
the next invocation. For multi-step workflows, call the public Prolog API from
a single SWI-Prolog process or use the tests as executable examples. Durable
storage and a stateful CLI are not implemented yet.

The fixture URL is supported offline. An arbitrary GitHub URL is only parsed
into a provisional record; it is not fetched. For manual registration, call
`register_repository/2` with a metadata dict containing `owner`, `name`, `url`,
`description`, `primary_language`, `topics`, `license`, and `status`.

## Public Prolog API

Load the API from the repository root:

```prolog
?- use_module('src/hrm_rewards.pl').
```

The public predicates cover the feature workflow:

* Catalogue and analysis: `import_repository/2`,
  `register_repository/2`, `analyse_repository/2`,
  `confirm_algorithm_concept/2`, `map_repository_to_industries/2`.
* Job preparation: `generate_job_options/2`, `job_role/2`,
  `confirm_generated_job/2`, `job_competencies/2`, `job_tasks/2`, and
  `task_assessment_map/2`.
* Project work: `create_learning_project/4`, `record_creative_vision/3`,
  `project_status/2`, `record_resource_declaration/4`, `submit_evidence/4`,
  `complete_independent_stage/2`, `unlock_comparison/2`, and
  `submit_reflection/3`.
* Review and participant safeguards: `submit_stakeholder_review/6`,
  `project_reviews/2`, `record_contribution/8`, `project_team_credit/2`,
  `record_fulfilment/5`, `fulfilment_visible_to/3`, `fairness_check/2`, and
  `conflict_of_interest/3`.
* Outcomes: `assess_understanding/3`, `assess_prestigiousness/3`,
  `calculate_rewards/3`, `explain_assessment/2`, `explain_reward/2`,
  `submit_appeal/3`, `generate_participant_report/2`, and
  `participant_report_json/2`.

The predicate arities indicate their arguments; consult the corresponding
module for dict fields and accepted values. Public API operations share the
in-memory store within one Prolog process. `persistence:reset_store/0` clears
that store and is intended for tests.

## Tests

Run the full offline suite from the repository root:

```sh
swipl -q -f tests/test_runner.pl -g run_tests -t halt
```

Run the newly added public-API integration suite alone:

```sh
swipl -q -f tests/test_runner.pl -g "run_tests(extended_features)" -t halt
```

The test runner includes these suites:

| Suite | Coverage |
| --- | --- |
| `repository_catalogue` | Fixture import, unknown-license warning, provisional concepts, multiple generated jobs |
| `job_generator` | Job competencies and authentic tasks |
| `learning_pathways` | Initial stage and independent-work comparison lock |
| `understanding` | Mandatory criteria and protection against rounded incomplete scores |
| `prestigiousness` | Understanding gate and valid unconventional solutions |
| `rewards` | Decomposed reproducible rewards and safety failures |
| `fairness` | Private fulfilment, conflicts, and non-code team credit |
| `extended_features` | Public API access to job/task details, reviews, contribution records, fulfilment privacy, and fairness checks |
| `appeals` | Revised assessment after upheld appeal |
| `end_to_end` | Combined project, evidence, assessment, review, reward, and report workflow |

All tests use local fixtures and do not require GitHub access. The extended
suite also demonstrates calling the public API from a single process.

## Remaining implementation

The following requirements are not complete and should not be treated as
production capabilities:

* **Repository ingestion:** fetching GitHub API metadata, importing JSON export
  files, caching remote data, and retaining retrieval/source provenance.
* **Durability and operations:** persistent storage, transactional updates,
  concurrent access, a stateful multi-command CLI, and production deployment
  controls.
* **Repository analysis:** source/documentation scanning, general concept
  extraction, and administrator review/edit flows beyond confirming concepts
  and jobs.
* **Assessment governance:** versioned rubrics and repository snapshots,
  assessor identity/qualification tracking, appeal review independence, and
  comprehensive audit history.
* **Evidence and comparison integrity:** criterion-to-evidence support
  explanations are present, but duplicate-use prevention, platform resource
  access logging, and full comparison-stage resource controls are not.
* **Stakeholders and reporting:** reviewer identity and role qualification are
  not enforced; reports for assessors, managers, customers, and community
  reviewers are not implemented.
* **Rewards and employment:** reward calculation is a deterministic prototype,
  not an authorised payroll, customer-credit, or grant system. Deployment
  specific policy, equity rules, and financial authorization are still needed.

These are roadmap items rather than promises of an implementation date.
