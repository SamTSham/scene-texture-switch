# Feature ideas worth retaining

This backlog combines the published README, the revived development chat, recovered experimental code, and current decisions. It records ideas without promising that all should be built.

## Design principles recovered from the discussion

- One shared texture-state number coordinates every planned `Surface##` material.
- `Surface##` is an intentional professional convention, not an arbitrary limitation.
- Textures stay beside the SketchUp project and remain directly editable in Photoshop or another image editor.
- Replacing an image repeatedly under the same filename is a central workflow.
- Scene changes provide immediate visual feedback; a dedicated reload command is low priority.
- Organisation must remain understandable in Finder without requiring the plugin to interpret it.
- User edits should save immediately where practical; unnecessary Save or Set buttons add friction.
- Interface failure must never disable automatic switching.

## High-value backlog

### 1. Compact scene and texture overview

Already planned for version 1.2.

Useful information:

- SketchUp scene name;
- shared texture-state number;
- ready/incomplete/missing state;
- missing `Surface##` files;
- current scene;
- shared states used by several scenes;
- library location and conflicts.

### 2. Thumbnail view

Implemented for public version 1.0.0: texture-state thumbnails, per-surface
tiles, click-to-inspect, and the `z` large-preview shortcut.

#### Post-1.0 transparency refinement

Consider for the next full version:

- replace the current opaque dark preview background with a neutral
  checkerboard behind PNG images;
- use the same treatment in thumbnails and the large preview;
- preserve the PNG alpha channel rather than altering or flattening files;
- verify appearance and contrast on both macOS and Windows;
- keep the implementation entirely inside the existing HTML/CSS preview so it
  does not depend on Finder, Explorer, or another operating-system viewer.

This is visual clarification rather than a change to texture switching or file
handling, and is intentionally excluded from the frozen public 1.0.0 release.

The original thumbnail considerations were:

Potential forms:

- one representative thumbnail per texture state;
- a row showing every surface in one scene state;
- click to inspect at a larger size;
- preview without changing the active scene;
- optional selection of which surface supplies the representative thumbnail.

This should follow the dependable textual overview. Thumbnail generation and caching must not become part of switching.

### 3. Cue/state editor

The README proposed copy, delete, and preview operations. Reframed in current terminology:

- duplicate a texture state as a new number;
- preview a state;
- identify and optionally remove an unused state;
- copy a state between project libraries;
- rename or rebuild scene marker labels;
- show which SketchUp scenes use a state before deletion.

Deletion must remain explicit and recoverable.

### 4. Scene-state duplication

A useful production shortcut:

```text
Duplicate 07 as 08
```

This would copy every `Surface##` image in the state, create markers, and allow the copied images to diverge through later Photoshop work.

### 5. Project health check

Before sharing or archiving a model:

- missing textures;
- duplicate PNG/JPG alternatives;
- scene states with no scene;
- scenes with no prepared state;
- required `Surface##` materials without files;
- unused images;
- model association pointing to a missing library;
- unexpected aspect or pixel-dimension differences, reported but not automatically changed.

### 6. Assistant-ready project packaging

Create a report or verified copy containing:

- the model;
- its selected texture library;
- markers and surface guide;
- a completeness report;
- no subscription or online dependency.

This directly supports collaboration.

## Useful ideas to keep, but not prioritise yet

### Cue sheet / production table

The initial discussion proposed a table containing:

- scene name;
- texture-state number;
- filenames used by surfaces;
- notes.

The note field would expand to multiline while editing and collapse when focus leaves it. Changes would save immediately.

This remains useful, but the new scene-first folder structure and compact overview may satisfy much of the need with less interface complexity. Reassess after version 1.2 is used in production.

### Human-readable surface descriptions

Keep `Surface01` as the actual identifier while optionally displaying:

```text
Surface01 — Rear LED wall
Surface02 — Projection gauze
```

Descriptions could appear in missing-texture reports and thumbnails without making material matching configurable.

### Cue sheet export

Possible exports:

- plain text;
- CSV;
- printable production report.

Useful for handoff, meetings, and content production, but dependent on a stable underlying data model.

### Add Surface command

The early discussion proposed starting with two example surfaces and allowing more to be added. Current thinking places more planning responsibility on the user, so this should be an explicit setup aid rather than automatic creation of ten folders or materials.

Potential behavior:

- identify the next unused `Surface##` number;
- create placeholders only after confirmation;
- allow an optional human-readable description;
- never assume mapping, resolution, or content behavior.

### Optional automatic file-change detection

Because changing scene and back is already easy, a dedicated reload command or background modification-date watcher is low priority.

### Scene-change interval control

The old discussion proposed a slider for the polling interval. Since SketchUp has a frame-change observer, first determine whether polling can be reduced to a fallback. A user-facing timing control should be added only if real testing demonstrates a need.

### Human-readable folder renaming

Folders such as `02 — Hotel Room` remain an optional refinement. Stable numeric folders plus visible marker files are safer and may already solve the orientation problem.

## Later major-version ideas

### Scene State Manager movement

Version 2 may add:

- local position;
- local rotation;
- local scale;
- nested articulated transformations;
- textures within the same scene-state architecture;
- offline sharing with collaborators.

This requires the animation tool manual and separate transformation tests.

## Ideas rejected or corrected

### Apply textures to the selected face

This appeared in several failed assistant-generated rebuilds. It conflicts with the established material-based `Surface##` workflow and is not part of the product direction.

### Independent texture number per surface

Some unstable summaries claimed each surface should remember a different number. The published design uses one shared number across all controlled surfaces, allowing one scene state to coordinate projection and LED content. Independent numbers would complicate the model without a demonstrated need.

### Automatically create ten surfaces

Rejected. Most projects do not need ten controlled media surfaces, and creating them implies decisions the designer has not made.

### Use filename count as “unique/shared” status

Rejected. Status means:

- ready: every required surface has the state;
- incomplete: some do;
- missing: none do.

### Treat WebDialog/HtmlDialog failure as proof HTML is impossible

Rejected conclusion. The historic failures mixed interface experiments with damaged core code. A small isolated HtmlDialog remains appropriate for lists and thumbnails after controlled testing.
