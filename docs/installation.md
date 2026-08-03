# Installation guide

1. Install SWI-Prolog 10 or later.
2. Clone the repository.
3. From the repository root, run:

   ```sh
   swipl -q -f tests/test_runner.pl -g run_tests -t halt
   ```

4. Use the CLI through `./hrm`.

The test suite uses fixture repositories and does not depend on the live GitHub API.
