# Scene-first texture structure and marker specification

## Purpose

The original layout groups images by surface. This is technically consistent but mentally backwards for scene design: it shows one surface across many parallel scene states instead of everything happening in one scene.

Version 1.1 changes the organisation without making scene names part of critical image paths.

## Target structure

```text
Textures — Project Name/
├── 01/
│   ├── Opening.txt
│   ├── Surface01.png
│   ├── Surface02.png
│   └── Surface03.jpg
├── 02/
│   ├── Hotel Room.txt
│   ├── Surface01.png
│   ├── Surface02.png
│   └── Surface03.jpg
└── 03/
    ├── Finale.txt
    ├── Surface01.png
    ├── Surface02.png
    └── Surface03.jpg
```

The numbered folder is the stable technical address. `Surface##` remains the strict controlled-material identifier. The `.txt` marker is the human-readable scene label.

## Texture-library discovery

The plugin searches only beside the active `.skp` file. Compatible names are `Textures`, `Textures - Project`, `Textures – Project`, and `Textures — Project`.

1. Exactly one compatible folder: use it.
2. No compatible folder: offer to create or select one.
3. Several compatible folders: ask; never guess.
4. Store the chosen relative folder and a stable library identity in the model.
5. Copies and later model versions inherit that association.

## Numeric scene-state folders

- Use `01`–`99` to retain the existing texture-number model.
- Renaming a SketchUp scene never renames or moves the numeric folder.
- Several scenes may intentionally share one number and texture state.
- A missing numbered folder means that state has no prepared textures.

## Marker files

Each numbered folder contains one marker for every SketchUp scene using that texture number. The filename is the useful information; its contents repeat the original scene name and number for Finder preview and recovery.

If two scenes share state `05`:

```text
05/
├── Act 1 Kitchen.txt
├── Act 2 Kitchen.txt
├── Surface01.png
└── Surface02.png
```

Marker rules:

1. Normalise Unicode consistently.
2. Replace `/` and `\\` with ` - `.
3. Replace wildcards, control characters, and forbidden filename characters safely.
4. Trim leading/trailing spaces and dots.
5. Use `Untitled Scene.txt` if no visible name remains.
6. Add a point suffix only when sanitised markers collide.
7. Regenerating markers never changes images.

## Scene rename behaviour

1. Read the scene's assigned texture number.
2. Calculate its new safe marker.
3. Create the replacement marker.
4. Remove the former marker only after the replacement exists.
5. Do not rename the numeric folder or any image.

A **Rebuild Scene Labels** command can recreate every marker from the SketchUp model.

## Required surfaces and readiness

Controlled materials retain strict names: `Surface01`, `Surface02`, and so on.

- ready: every required `Surface##` image exists;
- incomplete: at least one but not all exist;
- missing: none exist;
- conflict: duplicate extensions or another ambiguous condition needs attention.

Extension precedence remains `.png`, `.jpg`, `.jpeg`.

## Safe migration

Migration is a preview and copy, never an in-place rearrangement of the only working library.

```text
OLD: Surface01/02.png  ->  NEW: 02/Surface01.png
OLD: Surface02/02.jpg  ->  NEW: 02/Surface02.jpg
```

1. Scan without writing.
2. Produce a complete proposed mapping and conflict report.
3. Choose a new destination library.
4. Copy; never move originals.
5. Verify every copy by size and checksum.
6. Generate scene markers.
7. Test switching against the copy.
8. Adopt it only after explicit confirmation.

## Optional later refinement

Names such as `02 — Hotel Room/` may be considered after version 1.1 has been used in production. They are not required for the scene-oriented system and introduce path changes the marker approach avoids.

