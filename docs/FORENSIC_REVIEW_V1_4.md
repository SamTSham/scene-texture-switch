# Forensic review of marked v1.4 experiments

Reviewed archives supplied from the historical RBZ folder.

## Archive identity

| Filename | SHA-256 | Assessment |
| --- | --- | --- |
| `SceneTextureSwitcher_v1.4v_correct_pathscan_colorlogic.rbz` | `18e604a534ecbd396e2681835b35584f248a8bee7b5a2d88c53b383d25f54cb0` | Valid archive; unsafe experimental integration |
| `SceneTextureSwitcher_v1.4v_correct_pathscan.rbz` | `803bf3e5cc07e7b614d44596d42b81eaf19f723117c4e7a14e807c485b56f502` | Same meaningful contents as the colorlogic archive |
| `SceneTextureSwitcher_v1.4aa_iconlogic_stable.rbz` | `08e369c30cd73e1b78772b40e177f522c83d9d140b988f0131908109dbefec00` | Destructive rewrite; not a switching plugin |

The two v1.4v archive hashes differ because their ZIP packaging differs. Their loader, `core.rb`, dropdown HTML, and placeholder images have identical content hashes.

## v1.4v pathscan/colorlogic pair

### Potentially useful evidence

- Confirms the intended three-state readiness model.
- Contains the accepted compact legend.
- Demonstrates the desired immediate selection behaviour without a separate Set button.
- Attempts to derive surface folders from the model's project texture directory.
- Retains the canonical texture application, scene polling, and mapping-size preservation code beneath the experiment.

### Defects

1. It calculates the correct project texture directory at module load, but later uses:

   ```ruby
   File.join(model.path.gsub(/\.skp$/, ''), 'textures')
   ```

   For `/Project/Model.skp`, that resolves to `/Project/Model/textures`, not `/Project/textures`.

2. Path scanning runs at module load. An unsaved model or a later model change can make that data invalid.
3. The readiness calculation is duplicated several times inside `activate`.
4. `requestDropdown` is registered more than once with incompatible implementations.
5. One branch converts Ruby arrays with `to_s` rather than valid JSON.
6. It attempts `dlg.run_action`, which is not part of the canonical HtmlDialog flow.
7. When no surface folders are found, `count == surface_count == 0`, causing every item to appear ready/black.
8. `list_texture_cues` compares existing files against all 99 possible surface numbers rather than the existing controlled surfaces. A normal two-surface project therefore cannot become ready.
9. Extensive diagnostic output and repeated filesystem scans are mixed directly into dialog construction.
10. The dialog and state logic are coupled tightly enough that a rendering change can damage core behaviour again.

### Verdict

Do not transplant this `core.rb`. Preserve only its user-facing requirements and reimplement readiness scanning as an isolated service with fixtures.

## v1.4aa iconlogic stable

### What it demonstrates

- A compact selector can be generated as static HTML.
- The desired symbols and “Texture Number” terminology were present.

### Critical regressions

- Replaces, rather than patches, canonical `core.rb`.
- Removes the repeating scene check.
- Removes per-scene texture-index storage.
- Removes texture application.
- Removes scale and mapping-size preservation.
- Selection merely displays a message box.
- Scans arbitrary child directories rather than strictly controlled `Surface##` folders.
- Recognises only PNG files.
- Marks incomplete only when exactly one texture exists; two or more missing-from-some cases are misclassified.
- Changes menu registration and packaging structure.

### Verdict

Reject as an implementation source. It is useful only as historical confirmation of the intended compact labels.

## Recovered requirements

The following requirements survive review and belong in the clean implementation:

- status is calculated only from existing controlled surface folders;
- ready means present in every controlled surface folder;
- incomplete means present in at least one but not all;
- missing means present in none;
- PNG, JPG, and JPEG are supported, with canonical extension precedence retained;
- the current scene is selected when the overview opens;
- changing selection can apply/store a choice immediately;
- the window may remain open and must be compact;
- interface failure must not stop automatic switching.

