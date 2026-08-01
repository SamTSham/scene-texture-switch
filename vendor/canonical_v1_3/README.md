# Canonical v1.3 import

The exact published working v1.3 RBZ has been imported here unchanged.

Do not place a later experimental build here.

Import record:

- Original filename: `SceneTextureSwitcher_v1.3.rbz`
- Original location: external release folder supplied by the user
- Size: 4,081 uncompressed bytes across six archive entries
- SHA-256: `597ac446fc10de01732f3483601180cfcdd97e843c937847ddadab3e5844e2ba`
- Archive date: 28 May 2025
- Historical working environment: SketchUp 2024 on macOS

## Version interpretation

`v1.3` identifies the internal development/release-candidate lineage of the preserved archive. The loader's `1.0.0` is intentional: it was meant to be the first public-facing release number, leaving a conventional sequence for later published updates. The README's older `v1.1` heading is documentation drift and is not used for package identity.

Archive manifest:

```text
SceneTextureSwitcher.rb
scene_texture_switcher/core.rb
scene_texture_switcher/html/dropdown.html
scene_texture_switcher/textures/image_01.jpg
scene_texture_switcher/textures/image_02.jpg
scene_texture_switcher/textures/image_03.jpg
```

`tools/verify_canonical.rb` verifies both the original archive and the three meaningful extracted source files.

The binary archive itself is ignored by Git so it cannot be casually modified and recommitted as though it were the baseline.
