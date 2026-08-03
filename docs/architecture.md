# Architecture guide

The implementation is intentionally deterministic and explainable.

## Core flow

1. `repository_catalogue.pl` imports or registers repository metadata.
2. `concept_analysis.pl` creates provisional concept records.
3. `industry_mapping.pl` infers conservative industries with confidence labels.
4. `job_generator.pl` derives suggested roles, competencies, and authentic tasks.
5. `learning_pathways.pl` creates participant projects and lifecycle state.
6. `creative_vision.pl`, `comparison_control.pl`, and `evidence_store.pl` enforce independent creation before comparison.
7. `understanding_assessment.pl` calculates criterion-based understanding and blocks 100% unless every mandatory criterion is complete.
8. `prestigiousness_assessment.pl` scores originality and craftsmanship only after the understanding gate passes.
9. `stakeholder_reviews.pl`, `reward_engine.pl`, `fairness_rules.pl`, `fulfilment.pl`, and `appeals.pl` handle reviews, rewards, privacy, fairness, and reassessment.

## Data model

All state is stored in-memory through `persistence.pl` as typed entities keyed by generated identifiers. The public API returns structured Prolog dicts or explanation terms so downstream callers can inspect every decision.
