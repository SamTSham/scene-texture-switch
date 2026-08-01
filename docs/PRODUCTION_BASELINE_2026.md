# Production-proven SketchUp 2026 baseline

The plugin copy installed in SketchUp 2026 has been used without a functional switching problem on four set-design projects. It is therefore preserved separately from the historically published v1.3 archive.

## Identity

| File | SHA-256 |
| --- | --- |
| `SceneTextureSwitcher.rb` | `541a98e7bb7b778c9e9bf683a66ad84a224995f071f38dc90d6ce95f6f16060b` |
| `scene_texture_switcher/core.rb` | `dd23876bf04ffce0417bfcd356bf2a7a960e80fb1731e91fe1b40d95e9f55cbf` |
| `scene_texture_switcher/html/dropdown.html` | `0e0eab634ca29c3fce20fe2516d0d05a1a24c9278d22d9aaafc8dded0c74cc73` |

No historical RBZ in the supplied archive collection had the same `core.rb` hash. This installed copy is therefore retained directly as its own known artifact.

## Proven behaviour

- Per-scene texture numbers remain stored in SketchUp scene attributes.
- Scene changes trigger texture application.
- Texture files are read from `textures/Surface##/NN.ext` beside the active model.
- PNG, JPG, and JPEG are supported.
- Existing texture width and height are reapplied after replacement.
- The interface can remain open and selection applies immediately.
- The build has been used in four production design projects without a switching failure.

## Known interface defect

Every dropdown entry appears ready/black. The readiness code calculates one path correctly at module load but later scans:

```ruby
File.join(model.path.gsub(/\.skp$/, ''), 'textures')
```

For `/Project/Model.skp`, this becomes `/Project/Model/textures` instead of `/Project/textures`. No surface folders are found, making both `count` and `surface_count` zero. The code then misclassifies `0 == 0` as ready.

This defect does not affect actual switching because `apply_all_textures` independently uses `File.dirname(model.path)`, which is correct.

## Other cautions

- The dropdown code repeats the same scanning logic several times.
- The same callback name is registered more than once.
- It contains an unused or invalid dialog-action attempt.
- The dropdown lists all 99 theoretical states and becomes taller than the display.
- Scene polling runs every 0.25 seconds rather than every second.

## Development consequence

The historical v1.3 remains the immutable published reference. This installed copy becomes the practical production reference. Future builds must be tested against both:

1. reproduce v1.3 switching and mapping behaviour;
2. reproduce the production build's immediate selection and long-term reliability;
3. replace readiness and interface code with isolated tested services;
4. never repair the colour logic by restructuring the switching engine.

