# Scene Texture Switcher

Controlled continuation of the published, working Scene Texture Switcher v1.3.

## Current state

The canonical v1.3 source has been imported from the original working RBZ and recorded by checksum. No replacement `core.rb` has been invented.

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

The plain-language version plan is in `docs/DEVELOPMENT_ROADMAP.md`.

## First development milestone

1. Confirm the imported v1.3 baseline in the existing `Texture-Test.skp` model.
2. Integrate the tested scene-name folder service without changing switching behaviour.
3. Add a persistent scene-to-folder registry.
4. Add the compact status overview without modifying the switching engine.

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
