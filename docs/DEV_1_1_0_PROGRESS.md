# Version 1.1.0 development progress

## dev.1 — read-only scanner and migration planner

Completed:

- scans the original `Surface##/NN.ext` structure;
- recognises PNG, JPG, and JPEG;
- derives required surfaces from actual `Surface##` folders;
- classifies existing texture states as ready or incomplete;
- lists missing surfaces;
- detects several extensions competing for one surface/state;
- ignores unrelated files safely, including future marker files;
- proposes `NN/Surface##.ext` destinations;
- accepts scene labels as separate input when they become available inside SketchUp;
- renders a human-readable report;
- contains no copy, move, rename, or delete operation.

Automated coverage:

- recovered demo library: two surfaces, three complete states, six files;
- incomplete state;
- duplicate-extension conflict;
- unrelated marker file;
- scene-first destination mapping;
- explicit confirmation that the plan is not writable.

Next:

1. Wrap the scanner in a SketchUp-only preview command.
2. Read scene names and their stored texture numbers from the open model.
3. Feed those labels into the report.
4. Display/save the preview without altering the library.
5. Package as `1.1.0-dev.1` for testing alongside—not over—the production baseline.

