# Project rules

## Source of truth

1. The published working v1.3 package is the canonical source.
2. Do not recreate `core.rb` from conversation summaries.
3. Do not replace the loader, menu registration, observer, texture application, or mapping-preservation code merely to add a feature.
4. Preserve an untouched copy of the canonical package and record its checksum.

## Change discipline

1. One behavioural change per branch or patch.
2. Inspect before editing; patch the smallest coherent area.
3. New responsibilities go into new modules where the existing architecture permits it.
4. UI code consumes a read-only state snapshot and sends explicit commands. It does not perform texture switching itself.
5. Folder-name logic does not infer scene identity from the visible folder name alone.
6. No release archive is produced until every baseline regression check passes.
7. A failed experiment is reverted as a patch; it is never repaired by regenerating the plugin.

## Release gates

A build cannot be labelled usable unless all of the following are confirmed:

- plugin loads without Ruby errors;
- menu item appears exactly once;
- selector opens;
- scene change is detected;
- correct textures are applied;
- scale and mapping are preserved;
- repeated scene changes do not progressively alter materials;
- missing textures are reported without disabling future switching;
- saved scene-folder associations survive restart;
- the status overview can fail or close without stopping automatic switching.

