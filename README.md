# Scene Texture Switcher

Controlled continuation of the published, working Scene Texture Switcher v1.3.

## Current state

The repository structure and specifications are ready. The canonical v1.3 source still needs to be imported from the original working RBZ or ZIP. No replacement `core.rb` has been invented.

## Non-negotiable baseline

Published v1.3 is the only canonical engine. Before any new feature is accepted, these behaviours must remain intact:

- extension registration and menu entry;
- scene-change detection;
- automatic texture switching;
- texture scale and mapping preservation;
- existing texture-folder discovery;
- the working selector;
- model stability during repeated scene changes.

See `docs/PROJECT_RULES.md` and `docs/REGRESSION_CHECKLIST.md`.

## First development milestone

1. Import the exact published v1.3 package into `vendor/canonical_v1_3/`.
2. Record its archive checksum and file manifest.
3. Copy it unchanged into the working extension tree.
4. Establish a repeatable baseline test in the existing `Texture-Test.skp` model.
5. Add scene-name folder mapping as an isolated service.
6. Add the compact status overview without modifying the switching engine.

## Planned user-facing behaviour

Texture folders will be readable by scene name rather than dependent on a predetermined number:

```text
textures/
  Opening/
    Surface01/
    Surface02/
  Kitchen - Evening/
    Surface01/
    Surface02/
  Finale/
    Surface01/
    Surface02/
```

Unsafe filesystem characters are replaced deterministically. Duplicate scene names receive point suffixes such as `Kitchen`, `Kitchen.2`, and `Kitchen.3`, while an internal stable identifier keeps the association intact after renames.

The overview will show every scene with a status:

- black: ready in every required surface folder;
- red: incomplete in one or more required surface folders;
- grey: missing everywhere.

Interface rendering is not allowed to own or rewrite switching logic.

