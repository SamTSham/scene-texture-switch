# Compact status overview

## Purpose

Provide an always-readable, scrollable overview of scene texture readiness without coupling the interface to texture application.

## Rows

Each row represents a scene and contains:

- status indicator;
- SketchUp scene name;
- stable texture number and marker label;
- count of present and required surface textures;
- current-scene marker.

Example:

```text
● Opening                         4/4
● Kitchen / Evening              3/4
○ Finale                          0/4
```

Colour meanings:

- black: all required textures present;
- red: at least one but not all required textures present;
- grey: none present;
- optional amber: folder conflict or invalid external change, kept distinct from ordinary incompleteness.

Colour is supplemented by text or shape so the overview remains understandable without colour perception.

## Interaction

First milestone:

- scroll the complete scene list;
- select a row for editing without activating the SketchUp scene;
- assign or change that scene's texture number from the row;
- refresh status;
- reveal the associated texture folder;
- show missing surface names.

SketchUp's scene tabs and Scenes panel remain the ways to activate scenes. The
overview does not add a third navigation system. The current SketchUp scene is
shown with a quiet marker, but clicking or double-clicking a row has no hidden
scene-changing action.

Not in the first milestone:

- thumbnails;
- drag-and-drop reordering;
- animation controls;
- elaborate menu styling;
- editing texture-switching rules inside the view.

## Isolation contract

The overview receives a serializable snapshot from Ruby. Closing it, resizing it, or encountering a rendering error cannot unregister the observer or stop automatic switching.

## Future Scene State handover

The list is deliberately shaped so it can later display scene-controlled motion
without changing its basic behaviour. Texture assignment remains the compact
default. A future Motion view may add a recorded-object count and per-scene
timing, while the same scene rows and selection rules remain in place.

Recording motion is different from assigning a texture: it must capture the
actual objects in the active SketchUp scene. If a non-active row is selected,
the interface will explain that the scene must first be opened in SketchUp; it
will not activate the scene automatically.
