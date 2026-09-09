# Scene TextureSwitch 1.0.1 — prepared maintenance build

This build corrects internal loading for Warehouse-encrypted packages and prevents an automatic startup poll from modifying an already-open model. User-initiated scene changes still apply their assigned textures.

- Uses `Sketchup.require` for internal extension loading.
- Removes the startup safety poll that could cause an unexpected save prompt.
- Handles file paths explicitly as UTF-8 for Windows compatibility.
- Expands the guide for projection design, LED screens/video walls, theatre and event scenery, signage, exhibition graphics, presentations, material variants and image cueing.
- Packages the illustrated guide and starter project with the extension.

Install `SceneTextureSwitch_1.0.1.rbz` through SketchUp’s Extension Manager.

Validation on 9 September 2026: 79 tests and 438 assertions passed; the public package verifier passed for 44 entries. The archive passes integrity checks. Manual confirmation of a clean installation, closing an unchanged model without a save prompt, and normal scene switching remains outstanding in the latest development handoff. Windows runtime testing is not confirmed. This is a prepared maintenance build, not a claim of Warehouse approval.

The prior stable release remains available in GitHub Releases. Older `1.2.0-rc.*` entries in the development changelog use internal development numbering and are not newer public releases.
