# Regression checklist

Run against the known `Texture_Test.skp` model and a copy of its texture tree.

## Installation

- [ ] RBZ is a valid nonempty ZIP archive.
- [ ] Archive manifest contains the expected loader and extension directory.
- [ ] A clean installation leaves no obsolete files from previous versions.
- [ ] Extension appears once in Extension Manager.
- [ ] Menu command appears once.

## Canonical switching

- [ ] Open Scene 1; expected textures are applied.
- [ ] Open Scene 2; expected textures are applied.
- [ ] Return to Scene 1; mapping and scale match the original baseline.
- [ ] Cycle scenes at least twenty times; no progressive mapping drift occurs.
- [ ] Missing image produces a report and does not stop other surfaces or later scenes.
- [ ] Restart SketchUp; automatic switching resumes.

## Scene folders

- [ ] Slash and backslash names resolve safely.
- [ ] Wildcards are literal and cannot escape the texture root.
- [ ] Duplicate names produce stable `.2`, `.3` suffixes.
- [ ] Renaming a scene renames only its associated folder.
- [ ] A destination collision stops safely without merging.
- [ ] Deleting a scene preserves textures in `Orphaned Scenes`.
- [ ] Undo/redo and model reopening do not corrupt the registry.

## Overview

- [ ] Ready, incomplete, and missing calculations match the filesystem fixture.
- [ ] Long scene lists scroll.
- [ ] Long names do not make controls inaccessible.
- [ ] Dialog reopening does not duplicate callbacks or menu commands.
- [ ] Closing or breaking the overview does not stop scene switching.
- [ ] Normal and enlarged display scaling remain usable.
