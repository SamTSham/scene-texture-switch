# Version 1.1.0 development progress

## dev.1 — read-only scanner and migration planner

Completed:

- scans the original `Surface##/NN.ext` structure;
- recognises PNG, JPG, and JPEG;
- derives required surfaces from actual `Surface##` folders;
- classifies existing texture states as ready or incomplete;
- lists missing surfaces;
- detects several extensions competing for one surface/state;
- ignores unrelated files safely, including future marker files;
- proposes `NN/Surface##.ext` destinations;
- accepts scene labels as separate input when they become available inside SketchUp;
- renders a human-readable report;
- contains no copy, move, rename, or delete operation.

Automated coverage:

- recovered demo library: two surfaces, three complete states, six files;
- incomplete state;
- duplicate-extension conflict;
- unrelated marker file;
- scene-first destination mapping;
- explicit confirmation that the plan is not writable.

Next:

1. Wrap the scanner in a SketchUp-only preview command.
2. Read scene names and their stored texture numbers from the open model.
3. Feed those labels into the report.
4. Display/save the preview without altering the library.
5. Package as `1.1.0-dev.1` for testing alongside—not over—the production baseline.

## dev.1 overview companion

Completed:

- added a read-only scene snapshot using SketchUp page persistent IDs where
  available;
- discovers `Textures` and project-labelled dash variants beside the model;
- treats several compatible libraries as a conflict rather than guessing;
- reports ready, incomplete, missing, and duplicate-extension conflict states;
- fixes the former zero-surfaces-equals-ready error;
- renders all scenes in a compact, resizable, scrollable palette;
- keeps row selection separate from SketchUp scene activation;
- marks the actual current scene without navigating to it;
- packaged as a standalone companion extension with no timer, texture
  application, or model-writing callback.

The companion package is deliberately separate from the production extension.
It can be installed alongside the working switcher for interface testing, then
removed without replacing production files.

### dev.2 callback repair

The first live SketchUp test loaded the palette but remained at “Reading…”. The
HTML callback context had incorrectly been passed to the refresh method as if it
were the HtmlDialog itself. `dev.2` retains the actual dialog reference and uses
the callback context only as the event notification. A source-level regression
check covers both the standalone preview and future integrated code.

### dev.3 live scene-list refresh

The second live test confirmed that renamed scenes were correct after reopening
the palette but not while it remained open. `dev.3` attaches SketchUp's
`PagesObserver` only while the palette is open. Scene renames, additions, and
removals schedule one short delayed refresh so clustered notifications do not
cause repeated redraws. Closing the palette detaches the observer. This observer
updates interface data only; it does not participate in texture switching.

### dev.4 combined assignment palette

The verified overview now becomes a development editor:

- clicking a row's texture number opens an internal scrollable 01–99 picker;
- picker entries carry the same ready, incomplete, missing, and conflict marks;
- selecting a number writes the established `texture_index` attribute to that
  scene without activating it;
- the write is one SketchUp undo operation;
- editing the current scene also calls the production switcher's proven texture
  application method;
- editing any other scene prepares its assignment without moving the camera;
- the palette refreshes immediately after assignment.

The picker replaces the unwieldy native 99-item dropdown. This development
companion now writes scene assignments, but it still never creates, replaces,
moves, or deletes texture image files.

### dev.5 compact production layout

The successful combined palette is compressed for SketchUp screen economy:

- removes the redundant internal title row;
- shortens the operating-system window title;
- places the manual rescan control in the texture-library strip;
- reduces the library strip and footer to 25 pixels each;
- reduces ordinary scene rows from 39 to 30 pixels;
- hides repetitive ready/missing sentences from every row;
- shows the full status sentence in the footer when a row is selected;
- reduces the default window to 360 × 420 with a 300 × 180 minimum.

The rescan button remains because external Finder and Photoshop file changes do
not reliably generate SketchUp scene events.

### dev.6 contextual legend strip

The compact strip no longer spends permanent space displaying the generic
folder name `textures`. It normally shows the four status colours. Hovering a
scene row, texture-number control, or rescan button temporarily replaces the
legend with a concise explanation. Missing or ambiguous library warnings take
priority over the ordinary legend.

### dev.7 explicit reload and optional scene navigation

The circular arrow now has one concrete production purpose: it reapplies the
current scene's assigned textures from disk, then refreshes all readiness data.
This is useful after replacing an image in Photoshop without switching away and
back. Selecting the already-current SketchUp scene tab does not change the
legacy poller's scene-name state and therefore is not a dependable reload.

Scene rows gain an explicit double-click action:

- single click selects the row and shows details;
- double click activates that SketchUp scene;
- clicking or double-clicking the texture-number button never activates the
  scene.

### dev.8 verified migration and adoption

The development companion gains a separate Extensions-menu command to create a
scene-first copy. It requires a saved model and exactly one legacy `Surface##`
library, refuses an existing destination, and asks before writing.

The copy operation:

- copies PNG, JPG, and JPEG alternatives into `NN/Surface##.ext`;
- verifies every copy by size and SHA-256;
- creates sanitised scene marker files containing scene recovery information;
- writes a complete report inside the copied library;
- leaves the legacy library unchanged;
- removes only its own new destination if verification fails.

After successful verification, a second confirmation offers to associate the
model with the copy. Adoption is undoable. An explicitly associated scene-first
model routes automatic production switching through a reversible development
bridge; unassociated models continue through the untouched legacy method.

If adoption is declined after copying, a separate **Adopt Existing Scene-First
Texture Copy…** command permits later adoption. It accepts exactly one
scene-first candidate carrying the generated verification report, so inspection
does not force an immediate decision or require another migration.

### dev.9 continuous numbered scene markers

Marker names now include their texture-state number, for example
`04_strangely long name.txt`. Opening the palette repairs earlier `dev.8`
markers to the new convention.

The synchronizer runs after assignment and debounced scene-list edits. It:

- creates the desired marker before removing an obsolete one;
- moves a marker when its scene is reassigned;
- renames it when the scene name changes;
- removes managed markers for deleted scenes;
- creates a missing numeric folder when a scene is assigned to it;
- removes a vacated numeric folder only when it is completely empty;
- identifies managed markers by their exact header and persistent scene key;
- never edits texture images or unrelated text files.
