# Texture and motion alignment

## Why this is being designed now

Scene Texture Switcher and scene-based keyframe animation solve two sides of the
same set-design problem. A SketchUp scene can describe both:

- which prepared image each controlled `Surface##` displays; and
- where a recorded group or component is positioned, rotated, and scaled.

They should therefore share a scene list, identity system, status language, and
event handling. They should not yet share one large implementation. The proven
texture switcher remains protected while motion is developed and tested as a
separate layer.

Reference reviewed: Regular Polygon's Keyframe Animation 2.2 user guide.

## Useful behaviour from the reference tool

The reference workflow is compact:

- scenes act as keyframes;
- Record stores the transforms of selected groups and components in the current
  scene;
- Select finds the objects already recorded in the current scene;
- Erase removes recorded data for selected objects;
- Play enables or disables animation;
- each scene can have its own transition time and delay;
- nested objects are recorded relative to their immediate parent;
- translation, rotation, and scale are interpolated between scenes.

Export formats, tween-scene generation, licensing, and movie rendering are not
part of our first motion implementation.

## Shared foundation to establish during texture work

### Stable scene identity

Data must not be located only by the visible scene name. Names are labels and
may be changed or duplicated. The plugin needs a persistent internal scene key,
with the current name stored separately for display and marker-file generation.

This is an intentional improvement over a name-bound design where renaming a
scene can disconnect its recorded information.

### One serializable scene snapshot

The Ruby side should be able to describe each scene using a plain record. Fields
are introduced only when their feature exists, but the record can grow without
replacing the interface contract:

- stable scene key;
- current visible scene name;
- texture-state number;
- texture readiness and missing surfaces;
- current-scene flag;
- later: recorded-object count;
- later: transition duration into this scene;
- later: hold or delay after arriving at this scene.

Texture folders continue to use stable numeric state folders and human-readable
scene marker files. Motion data belongs in the SketchUp model, not among the
image files.

### One observer, separate services

A single SketchUp scene-change signal may notify both systems in the future.
The work remains divided internally:

- texture service finds and applies images;
- motion service restores or interpolates transforms;
- interface reads status and sends explicit editing commands;
- neither interface failure nor future motion failure may stop texture
  switching.

## Compact interface handover

The initial palette stays texture-focused:

- status;
- scene name;
- texture-number selector;
- subtle current-scene marker;
- a small details/action menu.

Rows are editors, not scene buttons. A single click selects a row. A double
click has no secret behaviour. Scenes are activated with SketchUp's existing
tabs or Scenes panel.

When motion becomes real, the same window can gain a simple `Textures | Motion`
view switch. Motion mode can expose four recognisable actions:

- Play on/off;
- Record selected objects in the active scene;
- Select recorded objects in the active scene;
- Clear selected objects' recordings, with confirmation.

The selected row may also expand to show:

- recorded objects: `4`;
- transition into scene: `2.5 s`;
- hold after arrival: `1.0 s`.

The words “into scene” and “after arrival” avoid the ambiguity of two generic
time fields. Timing can be edited from the list without opening the scene.
Recording cannot: it depends on the current object selection and actual active
scene. Selecting a different row will never silently navigate there.

## Development boundary

### Build now

- scene-first texture folders and marker files;
- stable scene identity;
- read-only scene snapshot;
- compact texture assignment and readiness list;
- clean extension points for later timing and motion status.

### Prototype separately later

1. Record and restore one group's exact transform with no animation.
2. Record several groups and component instances.
3. Prove nested local transforms with an articulated test object.
4. Interpolate translation.
5. Interpolate shortest-path rotation.
6. Add scale and mirrored-object tests.
7. Add per-scene transition and hold timing.
8. Connect motion status to the shared scene palette.

Only after those tests pass should texture and motion playback run together.

## Decisions still requiring a real SketchUp prototype

- the most reliable persistent identity for pages, groups, and component
  instances across supported SketchUp versions;
- whether scene-change observers fully replace the legacy repeating check in all
  supported versions;
- how per-scene timing should interact with SketchUp's own scene transition
  settings;
- undo behaviour while recording and clearing transform states;
- safe interpolation of nested transforms containing reflection or combined
  non-uniform scale and rotation.
