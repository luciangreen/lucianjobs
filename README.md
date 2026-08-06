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

## Example command showcase

The examples below assume the CLI wrapper `./hrm` is executable and SWI-Prolog 10+ is on your `PATH`.

### Repository management

```sh
# Import a repository by URL and receive its assigned RepositoryId
./hrm repository import https://github.com/luciangreen/detlog

# List all registered repositories
./hrm repository list

# Analyse a repository (concept extraction, industry mapping)
./hrm repository analyse repo_1
```

### Job generation

```sh
# Generate job options derived from a repository
./hrm jobs generate repo_1

# List all known job roles
./hrm jobs list
```

### Learning project lifecycle

```sh
# Create a learning project for a job and participant
./hrm project create job_software_engineer participant_42

# Record a creative vision from a JSON file
./hrm project vision project_7 vision.json

# Check the current status of a project
./hrm project status project_7

# Mark the independent work stage as complete
./hrm project complete-independent project_7

# Unlock comparison (only available after independent stage is complete)
./hrm comparison unlock project_7
```

### Evidence and reflection

```sh
# Submit evidence of a given type from a JSON file
./hrm evidence submit project_7 code_sample evidence.json

# Submit a reflection from a JSON file
./hrm reflection submit project_7 reflection.json
```

### Assessment and rewards

```sh
# Run understanding assessment for a project
./hrm assess understanding project_7

# Run prestigiousness assessment (requires understanding gate to be passed)
./hrm assess prestigiousness project_7

# Calculate rewards for a project
./hrm rewards calculate project_7

# Get a human-readable explanation of an assessment
./hrm explain assessment assessment_3

# Get a human-readable explanation of a reward breakdown
./hrm explain reward reward_5
```

### Reports and appeals

```sh
# Generate a full participant report
./hrm report participant participant_42

# Submit an appeal against an assessment from a JSON file
./hrm appeal submit assessment_3 appeal.json
```

### Running the test suite

```sh
# Run all unit and integration tests via the CLI
./hrm test

# Or run the test suite directly with SWI-Prolog
swipl -q -f tests/test_runner.pl -g run_tests -t halt
```

## Documentation

* [Installation guide](docs/installation.md)
* [Architecture guide](docs/architecture.md)
* [Administrator guide](docs/administrator.md)
* [Assessor guide](docs/assessor.md)
* [Participant guide](docs/participant.md)
