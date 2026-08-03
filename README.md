# lucianjobs

`lucianjobs` is a deterministic SWI-Prolog implementation of the Understanding/Prestigiousness HRM rewards algorithm from `pr1.txt`.

The system treats repositories as the starting point for jobs, learning pathways, authentic work, assessments, and explainable rewards. It separates understanding from prestigiousness, keeps comparison locked until independent work is complete, records stakeholder reviews and appeals, and produces reproducible reward breakdowns.

## Quick start

1. Install SWI-Prolog 10 or later.
2. Run the full test suite:

   ```sh
   swipl -q -f tests/test_runner.pl -g run_tests -t halt
   ```

3. Run the CLI:

   ```sh
   ./hrm repository import https://github.com/luciangreen/detlog
   ./hrm test
   ```

## Project structure

* `src/hrm_rewards.pl` - top-level public API
* `src/repository_catalogue.pl` - repository registration and catalogue records
* `src/concept_analysis.pl` - concept extraction and confirmation
* `src/industry_mapping.pl` - industry inference with confidence labels
* `src/job_generator.pl` - job options, competencies, and authentic tasks
* `src/learning_pathways.pl` - project creation and lifecycle state
* `src/evidence_store.pl` - evidence validation and storage
* `src/understanding_assessment.pl` - mandatory-gated understanding scoring
* `src/prestigiousness_assessment.pl` - prestigiousness scoring after understanding
* `src/reward_engine.pl` - decomposed rewards and explanations
* `src/appeals.pl` - appeal handling and revised assessment outcomes
* `src/cli.pl` - command-line entry point

## Documentation

* [Installation guide](docs/installation.md)
* [Architecture guide](docs/architecture.md)
* [Administrator guide](docs/administrator.md)
* [Assessor guide](docs/assessor.md)
* [Participant guide](docs/participant.md)
