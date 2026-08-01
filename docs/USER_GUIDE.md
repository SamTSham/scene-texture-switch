# Scene TextureSwitch

## What is this?

SketchUp scenes cannot normally make one material show different image files in
different scenes. **Scene TextureSwitch adds that missing switch.**

Keep the saved `.skp` file and a folder beginning with `textures` together in
the same project folder. Each scene chooses a numbered set of pictures.

Edit or replace those pictures, and the textures, projections or LED content in
the model change with the scenes.

## The basic idea

A SketchUp scene chooses a numbered folder. Every controlled material loads its
matching picture from that folder.

**Folder number = when the picture appears. Surface number = where the picture
appears.**

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

The texture folder may be called `textures`, `textures — Hamlet`, or anything
else beginning with the word `textures`. The rest of its name is only for your
orientation.

## Three-minute setup

**Fastest test:** In **Settings + Quick Guide**, click **Show supplied starter
folder**. Open `Texture_Test.skp` beside its supplied `textures - Starter`
folder, then change between its three scenes. The pictures should switch
immediately.

1. Save the SketchUp model.
2. Put the supplied starter texture folder beside the `.skp` file.
3. Name controlled SketchUp materials `Surface01`, `Surface02`, and so on.
4. Edit or replace the placeholder pictures while keeping their filenames.
5. Open **Extensions → Scene TextureSwitch → Open Scene TextureSwitch** and
   choose a picture-set number for each scene.

## Where to enter the Surface name

`Surface01` is the name of the **SketchUp material**, not the face, group,
component, tag or image file.

1. Open SketchUp's **Materials/Colors** panel and choose **Colors In Model**.
   Select the material used on the surface you want Scene TextureSwitch to
   control.

   ![Select the surface material in Colors In Model](guide/01-select-material-in-model.png)

2. Open **Edit Material** and enter `Surface01` in the **Name** field. Name the
   next controlled material `Surface02`, then `Surface03`, and so on. Use two
   digits and do not add spaces.

   ![Enter Surface02 in the material Name field](guide/02-name-material-surface-number.png)

The exact buttons vary slightly between SketchUp versions and operating
systems, but the material **Name** field is the important part.

## Everyday use

- Click a number to assign pictures without visiting that scene.
- Double-click a row to visit its SketchUp scene.
- Hover a number for thumbnails; press `z` or click for a large preview.
- Use the folder button to open the complete texture folder.
- After editing the current pictures, change scene and return—or click reload.

Scene TextureSwitch creates small `.txt` labels inside numbered folders so you
can see which SketchUp scenes use them. Optional surface descriptions create
similar labels at the texture-folder root.

## Organise by scene or by surface

Scene TextureSwitch normally keeps all pictures for one scene together:

```text
01/Surface01.png
01/Surface02.png
```

If you prefer to keep all versions of one surface together, this also works:

```text
Surface01/01.png
Surface01/02.png
```

The extension recognises either arrangement automatically. It does not move,
convert or duplicate your pictures.

## Picture files

- PNG, JPG and JPEG work. PNG is preferred.
- PSD, TIFF, PDF and other working files may remain and are ignored.
- All versions of one `Surface##` should normally have matching dimensions.
- Different surfaces may have different shapes and sizes.
- 1024 pixels is the safest common SketchUp baseline. Larger pictures depend on
  graphics settings and hardware.

Status colours are black for ready, red for incomplete, grey for missing and
amber when files need attention. Hover the row to read the explanation.

Scene TextureSwitch never resizes, repairs, deletes or overwrites your artwork.
The simplest workflow is ordinary Finder copying, editing and replacing.
