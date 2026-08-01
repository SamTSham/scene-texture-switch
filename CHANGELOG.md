# Changelog

## 1.2.0-rc.8

- Prevented thumbnail previews from covering their texture-number button when
  the palette has insufficient room above or below the row.
- In constrained palettes, the preview now opens beside the number and narrows
  only as much as necessary.

## 1.2.0-rc.7

- Replaced the illustrated setup screenshots with compact, purpose-sized PNGs.

## 1.2.0-rc.6

- Added an illustrated explanation showing exactly where SketchUp material
  names such as `Surface01` are entered.
- Included both guide images in the installed detailed guide and packaged
  README.

## 1.2.0-rc.5

- Changed the macOS menu label to `Settings + Quick Guide…` because SketchUp
  consumes ampersands as menu formatting characters.

## 1.2.0-rc.4

- Changed scene detection to SketchUp's native frame-change notification so
  destination textures apply at the start of a scene transition.
- Retained a one-second object-based safety check for initial loading and
  observer fallback.
- Added coverage for long transitions, repeated animation frames, and separate
  scenes with duplicate names.

## Unreleased

- Created guarded continuation project.
- Documented published v1.3 as the immutable canonical baseline.
- Specified scene-name folder sanitising, duplicate suffixes, and stable identity mapping.
- Specified compact scene status overview and regression gates.
- Deferred all menu polish until core behaviour and the first two organisational features pass regression testing.
- Imported and checksum-locked the published v1.3 RBZ.
- Added an isolated scene-folder sanitiser with point-suffix duplicate handling.
- Added automated tests for unsafe characters, reserved names, duplicates, and length limits.
- Recorded the distinction between internal build v1.3 and intended public release v1.0.0.
- Forensically reviewed three marked v1.4 experiments and documented reusable requirements and rejected code paths.
- Added a plain-language public version roadmap from 1.0.0 through the future Scene State Manager 2.0.0.
- Revised version 1.1 around stable numeric scene-state folders, strict `Surface##` images, and regenerable scene-name markers.
- Preserved and documented the installed SketchUp 2026 build as a four-project production baseline separate from canonical v1.3.
- Added the read-only version 1.1 scanner, conflict checks, migration planner, report renderer, demo preview, and automated tests.
- Revisited the published README and original discussion to create an evaluated feature backlog covering thumbnails, cue editing, exports, health checks, packaging, and rejected detours.
- Made visual mockups and rendered interface previews a standing project rule in place of ASCII wireframes.
- Added the isolated read-only scene overview companion, stable page snapshot,
  compatible library discovery, corrected readiness checks, and exact rendered
  interface preview for `1.1.0-dev.1`.
- Repaired the live HtmlDialog snapshot callback after `dev.1` passed its action
  context in place of the dialog reference.
- Added palette-lifetime scene observation and debounced live refresh for scene
  renames, additions, and removals in `dev.3`.
- Combined overview and assignment in `dev.4` with an internal scrollable cue
  picker, off-scene editing, undoable writes, and immediate application only for
  the current scene.
- Compressed the verified palette in `dev.5`, removing redundant chrome and
  reducing row height while retaining selected-row details in the footer.
- Replaced the generic texture-folder label in `dev.6` with a compact colour
  legend and contextual hover guidance.
- Made the reload arrow reapply current-scene images from disk and added
  deliberate row double-click scene activation in `dev.7`.
- Added verified scene-first copying, marker generation, explicit model-library
  association, dual-layout readiness, and reversible scene-first switching in
  `dev.8`.
- Added continuous create-before-remove scene marker synchronisation and
  numbered marker filenames in `dev.9`.
- Preserved cue-matched working files silently during migration and added
  literal hover/large texture previews in `dev.10`.
- Made the `z` preview shortcut close the currently open preview before opening
  another, clarified the lowercase shortcut hint, and added relative path,
  pixel dimensions, and file size to the large preview in `dev.11`.
- Added a compact cross-platform texture-folder reveal control and amber
  per-surface pixel-dimension consistency warnings in `dev.12`.
- Unified switching, assignment, migration, previews, and settings behind one
  Scene Textures submenu for `1.2.0-rc.1`; added an offline Quick Guide,
  project-carried surface descriptions, a retirement shim for the former
  companion extension, and publishable RBZ packaging.
- Renamed the public tool Scene TextureSwitch and reduced `1.2.0-rc.2` to two
  commands; rewrote help from a beginner's problem, accepted any texture-folder
  suffix, added visible surface-description markers, removed public copy and
  migration machinery, and packaged the original six PNG placeholders by scene.
- Restored the native-menu ampersand, added full project-aware preview paths,
  and compacted described thumbnail labels to `S01 - description` in
  `1.2.0-rc.3`.
