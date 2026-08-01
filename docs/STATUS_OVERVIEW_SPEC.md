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
- select a row to make its scene current after explicit confirmation of the command path;
- refresh status;
- reveal the associated texture folder;
- show missing surface names.

Not in the first milestone:

- thumbnails;
- drag-and-drop reordering;
- animation controls;
- elaborate menu styling;
- editing texture-switching rules inside the view.

## Isolation contract

The overview receives a serializable snapshot from Ruby. Closing it, resizing it, or encountering a rendering error cannot unregister the observer or stop automatic switching.
