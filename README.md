# Scene TextureSwitch

Scene TextureSwitch makes named SketchUp materials show different image files
in different scenes.

It supports set-design workflows involving projections, LED screens and video
walls, scenic graphics, signage, exhibition displays, presentation boards,
material variants and image cueing across SketchUp scenes. It works locally without an account, subscription, licence check,
telemetry, or internet connection.

## The basic idea

Name controlled SketchUp materials `Surface01`, `Surface02`, and so on. Keep a
folder beginning with `textures` beside the saved `.skp` model. Each scene then
chooses a numbered picture set:

```text
My Project/
├── My Set.skp
└── textures — My Set/
    ├── 01/
    │   ├── Surface01.png
    │   └── Surface02.png
    └── 02/
        ├── Surface01.png
        └── Surface02.png
```

Change scenes and the destination pictures appear immediately.

## Install

1. Download the [prepared 1.0.1 maintenance build](release/SceneTextureSwitch_1.0.1.rbz?raw=true). See its [release notes and validation status](docs/RELEASE_NOTES_1.0.1.md) and [checksum](release/SHA256SUMS-1.0.1.txt).
2. In SketchUp, open **Extensions → Extension Manager**.
3. Click **Install Extension** and choose the downloaded RBZ.
4. Restart SketchUp if requested.
5. Open **Extensions → Scene TextureSwitch**.

## Quickest test

Open **Settings + Quick Guide**, click **Show supplied starter folder**, and
open `Texture_Test.skp` beside its supplied `textures - Starter` folder. Change
between its three scenes to see the two example surfaces switch pictures.

The example model is saved in SketchUp 2013 format.

## Features

- Assign picture sets to every scene from one compact palette.
- Switch destination textures when a scene transition begins.
- Organise pictures by scene or by surface.
- See ready, incomplete, missing, and conflict states.
- Preview textures as thumbnails or in a large view.
- Add readable descriptions while retaining strict `Surface##` names.
- Keep PSD, TIFF, PDF, and other working files beside exported pictures.
- Work entirely offline.

The complete illustrated guide is included inside the extension and in
[`docs/USER_GUIDE.md`](docs/USER_GUIDE.md).

## Compatibility

Designed for desktop SketchUp on macOS and Windows, with explicit UTF-8 path
handling. Confirmed manual testing of the project is on SketchUp 2026/macOS;
Windows hardware testing remains unconfirmed. The current 1.0.1 corrections
pass automated tests, but a fresh SketchUp installation, open/close-without-editing
check and scene-switching check still need manual confirmation. Do not treat
this GitHub build as proof of Extension Warehouse approval.

## Support

Please use this repository's Issues page to report a problem. Include your
SketchUp version, operating system, texture-folder layout, and the smallest
example that reproduces the problem.

## Licence

Copyright © 2026 Sam Madwar. Released under the [MIT Licence](LICENSE).
