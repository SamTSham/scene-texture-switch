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

Recovered aspirational ideas and rejected detours are evaluated in `docs/FEATURE_BACKLOG.md`.

## First development milestone

1. Confirm the imported v1.3 baseline in the existing `Texture-Test.skp` model.
2. Build a read-only migration preview from surface-first to scene-first storage.
3. Add regenerable scene-name marker files without changing image files.
4. Add the compact status overview without modifying the switching engine.

## Planned user-facing behaviour

Textures will be grouped by stable scene-state number, with a visible marker filename providing the SketchUp scene name:

```text
Textures — Project Name/
├── 01/
│   ├── Opening.txt
│   ├── Surface01.png
│   └── Surface02.png
└── 02/
    ├── Kitchen - Evening.txt
    ├── Surface01.png
    └── Surface02.png
```

Unsafe marker characters are replaced deterministically. Renaming a scene updates only a tiny marker file; numeric folders and images remain in place.

The overview will show every scene with a status:

- black: ready in every required surface folder;
- red: incomplete in one or more required surface folders;
- grey: missing everywhere.

Interface rendering is not allowed to own or rewrite switching logic.
