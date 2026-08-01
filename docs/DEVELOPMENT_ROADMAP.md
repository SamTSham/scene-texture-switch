# Scene Texture Switcher development roadmap

This roadmap assumes that the preserved internal v1.3 archive is the intended public **version 1.0.0**.

The central rule is simple:

> Every new version must still perform the basic texture switching as reliably as version 1.0.0.

New features will be added in small releases. We will not attempt the folder system, status window, animation system, and menu redesign simultaneously.

## How version numbers will work

Public versions use three numbers:

```text
1.0.0
│ │ └─ small repair
│ └─── new feature that remains compatible
└───── major redesign or major new product stage
```

Examples:

- `1.0.1`: repairs a problem without changing how the plugin is used.
- `1.1.0`: adds scene-named texture folders.
- `1.2.0`: adds the organisational overview.
- `2.0.0`: eventually introduces scene-controlled movement as a major expansion.

During development we will also use labels such as:

```text
1.1.0-dev.1
1.1.0-dev.2
1.1.0-test.1
```

These labels make it clear that a file is not a finished release. We will never call an experiment “stable” merely because one new feature appears to work.

## Version 1.0.0 — protected starting point

This is the existing release.

It already:

- notices scene changes;
- remembers a texture number for each scene;
- changes every applicable `Surface##` material;
- reads textures beside the SketchUp project;
- preserves the existing texture dimensions and mapping scale;
- provides the original texture-number selector.

No feature work begins until this exact package has been reconfirmed in the original test model.

### Your test

1. Install the preserved v1.0.0 release.
2. Open the known working model.
3. Change through its scenes several times.
4. Confirm that the expected images appear and their mapping does not shift.
5. Open the selector and assign a different texture number to a scene.
6. Restart SketchUp and confirm that switching still works.

This becomes our human-confirmed reference result.

## Version 1.0.1 — development safeguards

This release should make no visible creative change. It establishes safer foundations around the existing engine.

Planned work:

- give the internal parts clear responsibilities without rewriting them;
- report an unsaved model clearly instead of silently doing nothing;
- prevent two repeating scene checks from being started accidentally;
- improve diagnostic messages;
- add an About entry showing the public version and internal build identity;
- establish reliable packaging and archive validation.

Where possible, safeguards will be added beside the existing code rather than by restructuring it.

### Your test

The plugin should feel the same as 1.0.0. The full starting-point test is repeated. Any behavioural difference blocks release.

## Version 1.1.0 — scene-first folders and visible labels

This is the first important functional release.

The original structure shows one surface across all its parallel scene states. Version 1.1 instead groups every controlled surface belonging to one scene state. Stable numeric folders avoid moving images when a scene is renamed; a lightweight `.txt` marker makes the scene name visible at a glance.

Example:

```text
Textures — Project Name/
├── 01/
│   ├── Opening.txt
│   ├── Surface01.png
│   └── Surface02.png
├── 02/
│   ├── Kitchen - Evening.txt
│   ├── Surface01.png
│   └── Surface02.png
└── 03/
    ├── Finale.txt
    ├── Surface01.png
    └── Surface02.png
```

The number is the stable technical texture-state identity. `Surface##` remains the strict planned-media identifier. The marker filename is the disposable human-readable layer.

Planned behaviour:

- discover `Textures` or `Textures — Project Name` beside the model;
- group images by stable texture number and scene state;
- retain strict `Surface01`, `Surface02`, and similar filenames;
- generate a visible `.txt` marker from each SketchUp scene name;
- sanitise slashes, wildcards, and forbidden marker characters;
- update only the marker when a scene is renamed;
- support several scenes sharing one texture number;
- rebuild markers on command;
- retain the original structure until a copied migration is verified.

### Migration principle

The first test versions only preview the proposed mapping. Migration then copies into a separate library and never rearranges the only working textures.

Only after the copied structure and markers are confirmed will the model adopt the new library. A migration report records every old and new path.

### Your test

You will receive a deliberately awkward test model containing:

- normal scene names;
- duplicate scene names;
- a scene containing `/`;
- a scene containing wildcards;
- renamed scenes and scenes sharing one texture number.

You will confirm that the scene-oriented folders and marker names are understandable and that the correct textures still appear.

## Version 1.2.0 — compact texture overview

This version adds the organisational view we previously failed to complete safely.

Each scene appears in a scrollable list with a readable status:

```text
● Opening                         ready
● Kitchen - Evening              incomplete
○ Finale                          missing
```

Meanings:

- black: every required surface texture exists;
- red: at least one exists, but the scene is incomplete;
- grey: none exists;
- amber: a naming conflict or external folder problem needs attention.

The words or shapes will supplement colour so the information does not depend on colour alone.

Planned actions:

- select a scene;
- reveal its texture folder;
- see which surfaces are missing;
- refresh the list;
- keep the compact window open while working.

The overview will read a snapshot of plugin status. It will not contain the automatic switching engine. If the window fails to open or is closed, scene switching must continue.

### Interface development rule

The view will first be tested with invented sample data. It will not be attached to the live plugin until scrolling, resizing, selection, and colour display work in the supported SketchUp versions.

### Your test

You will primarily assess usability:

- Is the window small enough to leave open?
- Can a long scene list be scanned quickly?
- Are missing textures obvious?
- Are long scene names still understandable?
- Does the interface behave correctly at your normal display scaling?

The normal switching regression test is repeated separately.

## Version 1.2.1 and later — practical refinements

Small refinements can follow real production use:

- remember window position and size;
- show the current scene more clearly;
- reveal a missing surface directly;
- improve conflict explanations;
- reduce unnecessary folder scanning;
- add optional manual refresh;
- improve Windows and high-resolution display behaviour.

These will be repairs and usability improvements, not occasions to redesign the engine.

## Version 1.3.0 — menu and workflow polish

Only after the scene folders and overview are dependable should we polish the menu system.

Possible improvements:

- a compact native toolbar for essential actions;
- a small in-model status strip while a plugin tool is active;
- simplified wording and help;
- clearer first-use setup;
- preference controls for automatic folder renaming and migration;
- optional scene-folder repair commands.

This stage deliberately follows the functional work. A visually polished menu is not useful if switching is fragile.

## Version 1.4.0 — production conveniences

Candidates to evaluate after using 1.2 and 1.3 in real work:

- duplicate a scene together with its texture setup;
- copy texture assignments between scenes;
- import or export a scene-texture report;
- identify unused texture files;
- preview texture thumbnails;
- package a model and its required textures for an assistant;
- provide a read-only health check before sharing a project.

We should select from this list based on actual production friction rather than implement all of it automatically.

## Version 2.0.0 — Scene State Manager

Scene-controlled movement is a major expansion and deserves a major version.

The future plugin could store, per scene:

- material or texture;
- local position;
- local rotation;
- local scale;
- possibly visibility.

Nested objects would retain transformations relative to their immediate parent, allowing articulated scenery such as a robot arm, folding unit, curtain system, or nested revolve.

This stage begins only after reviewing the animation plugin manual and building separate transformation tests. It must not be inserted prematurely into the dependable texture engine.

Possible development sequence:

1. Record and restore one object without animation.
2. Support several objects.
3. Support nested groups and component instances.
4. Interpolate position.
5. Interpolate rotation safely.
6. Handle scale and mirrored objects.
7. Combine movement and texture states.
8. Create a shareable offline player/editor plugin.

## How each development cycle will work

For every version:

1. **Define one result.** We agree what the version should accomplish.
2. **Preserve the starting point.** Its archive and checksum remain untouched.
3. **Create a development branch.** Experimental work cannot overwrite the working release.
4. **Implement isolated logic first.** Folder and status calculations are tested outside SketchUp where possible.
5. **Connect with a narrow patch.** The smallest practical part of the live plugin is changed.
6. **Run automated checks.** Naming, scanning, archive structure, and source safeguards are verified.
7. **Build a clearly labelled test RBZ.** It cannot be confused with a public release.
8. **Run your SketchUp test.** You report what you see in ordinary language; Ruby knowledge is not required.
9. **Record the result.** Screenshots, console output, and observations belong to that exact build.
10. **Release or revert.** A failed build is abandoned cleanly rather than patched repeatedly without a known base.

## What I will ask from you

I will avoid asking you to diagnose Ruby. Useful reports from you are things such as:

- “Scene 4 showed the Scene 3 texture.”
- “The image changed, but its scale became smaller.”
- “The list opened, but clicking a row did nothing.”
- “Renaming the scene renamed the wrong folder.”
- “Automatic switching stopped after I closed the window.”

When technical information is needed, I will provide exact steps for copying it from SketchUp’s Ruby Console or locating a file. I will explain why it is needed and what it tells us.

## Recommended immediate order

1. Reconfirm public 1.0.0 in the original model.
2. Complete safeguards for 1.0.1.
3. Confirm the numbered scene-folder and marker layout with a realistic example.
4. Build a read-only migration preview and test marker generation for 1.1.0.
5. Build the overview independently for 1.2.0.
6. Use the result in a real production before choosing menu polish and convenience features.
