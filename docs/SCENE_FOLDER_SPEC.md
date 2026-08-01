# Scene-named texture folder specification

## Goals

- Make texture storage understandable without maintaining a separate numeric list.
- Mirror SketchUp scene renames safely.
- Preserve associations even if names collide or are sanitised.
- Never delete user textures as an automatic consequence of a scene rename or deletion.

## Identity model

Each SketchUp scene receives a plugin-owned stable identifier stored in model attributes. A registry associates:

```text
scene stable ID -> current SketchUp scene identity -> current display name -> folder name
```

The visible folder name is for humans; it is not the sole database key.

## Sanitising rules

Starting with the scene display name:

1. Normalize Unicode consistently.
2. Replace `/` and `\\` with ` - ` so a scene cannot create unintended nested folders.
3. Replace control characters and filesystem-reserved separators with a space or hyphen.
4. Collapse repeated whitespace.
5. Trim leading and trailing spaces and dots.
6. Replace an empty result with `Untitled Scene`.
7. Protect platform-reserved names where necessary.
8. Limit the visible portion to a conservative length while retaining the full display name in metadata.

Examples:

| SketchUp scene name | Folder name |
| --- | --- |
| `Kitchen / Evening` | `Kitchen - Evening` |
| `Act 1\\Scene 4` | `Act 1 - Scene 4` |
| `  Finale  ` | `Finale` |
| `...` | `Untitled Scene` |

Wildcards such as `*` and `?` are treated as literal user text and sanitised for cross-platform compatibility; they are never interpreted as matching instructions.

## Duplicate names

The first scene uses the base folder name. Subsequent collisions use point suffixes:

```text
Kitchen
Kitchen.2
Kitchen.3
```

Suffix allocation is stable. Reordering scenes does not renumber existing folders.

## Rename behaviour

1. Detect that the scene display name changed.
2. Resolve a new safe, unique folder name.
3. Verify that source and destination are inside the configured texture root.
4. If the destination is unused, rename atomically.
5. If a conflicting external folder exists, stop and present a conflict; never merge silently.
6. Update the registry only after the filesystem operation succeeds.
7. If the folder is missing, update the expected name and show a missing status without disabling switching.

## Deleted scenes

Move their associated folder to a plugin-managed `Orphaned Scenes` location, preserving its stable identifier and former scene name. Permanent deletion is always a separate explicit action.

## External folder renames

An external rename is detected as a mismatch. The plugin offers to relink the folder or restore the expected name. It does not silently rename the SketchUp scene.

