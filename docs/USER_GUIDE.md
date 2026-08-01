# Scene Textures 1.2

Scene Textures is an offline SketchUp extension for changing coordinated
projection, LED, scenic, or other planned material images with SketchUp scenes.

## The principle

Name controlled SketchUp materials `Surface01`, `Surface02`, and so on. Every
SketchUp scene stores one numbered texture state. All controlled surfaces use
the files belonging to that number, while their existing SketchUp material size
and mapping remain unchanged.

Replace the image files repeatedly as the design develops. Scene Textures does
not take ownership of the artwork.

## Scene-first library

Keep one texture library beside the saved `.skp` model:

```text
Textures — Project Name/
├── 01/
│   ├── 01_Opening.txt
│   ├── Surface01.png
│   └── Surface02.png
└── 02/
    ├── 02_Hotel.txt
    ├── Surface01.png
    └── Surface02.png
```

The numbered folder is the stable technical state. The generated `.txt` marker
makes scene names visible in Finder and is safely updated after scene edits.

Legacy `textures/Surface01/01.png` projects remain supported. Use **Create
Verified Scene-First Copy** when you want to migrate; the existing library is
never rearranged.

## Palette

- Open **Extensions → Scene Textures → Open Scene Textures**.
- Click a scene's number to assign a texture state without changing scene.
- Double-click a scene row to activate that SketchUp scene.
- Hover a number to inspect its surface thumbnails.
- Press `z` or click a thumbnail for a large preview.
- Use the folder button to reveal the texture-library root.
- Use the circular arrow after replacing the current scene's image in an editor.

Status: black is ready, red is incomplete, grey is missing, and amber indicates
a conflict or housekeeping warning. Hover the row to read the explanation.

## Image files

PNG, JPG, and JPEG are output textures. PNG takes precedence. If several output
alternatives exist for the same surface and state, the palette reports a
conflict. PSD, TIFF, PDF, and other working files may remain in the library and
do not affect readiness.

All numbered versions of one `Surface##` should use identical pixel dimensions.
Different surfaces may use different dimensions and aspect ratios. SketchUp's
conservative shared baseline is 1024 pixels; larger textures depend on graphics
settings and hardware.

## Settings and surface descriptions

Open **Settings & Quick Guide** to add optional descriptions such as
`Surface01 — Rear LED wall`. The strict material and image names do not change.
Descriptions are saved in `_Scene Texture Settings.json` inside the library so
they travel with the project.

## Safety

- Texture images are never renamed, resized, repaired, or deleted automatically.
- Assigning an empty number may create its folder and scene marker, but no image.
- Migration writes a separate verified copy and produces a report.
- Automatic switching continues without the palette being open.
