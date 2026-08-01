# Recovered development history

## Last trusted baseline

The revived ChatGPT history identifies the published v1.3 package as the last trusted version. It reportedly contained:

- a working scene observer;
- automatic texture switching when scenes changed;
- preservation of texture scale and mapping;
- stable loading and menu registration;
- the original selector.

The archive name `v1.3` represents its internal development lineage. Its loader version `1.0.0` was deliberately reserved as the first public release number. These two version tracks should remain distinct.

## Desired but unfinished organisation feature

The attempted selector enhancement classified a texture number by checking every existing `Surface##` folder:

- ready: the image exists in every surface folder;
- incomplete: it exists in some but not all surface folders;
- missing: it exists nowhere.

Accepted indicators were black, red, and grey/white square glyphs. Terminology was changed from “Cue” to “Texture Number” because theatrical cue numbers have a different meaning.

## Failure pattern

Later attempts repeatedly reconstructed rather than patched the plugin. Reported regressions included:

- missing menu registration;
- missing or noninteractive dialogs;
- selector content not reaching the rendered page;
- every entry receiving the same status;
- loss of the legend;
- loss of automatic texture switching;
- loss of mapping-preservation logic;
- invalid or empty RBZ archives;
- obsolete HTML remaining after installs.

The historical claims that WebDialog or HTML was categorically incapable were not established by controlled tests. Several failed packages also omitted unrelated core code, so interface failure and package regression were confounded.

A later forensic comparison confirmed this. Two v1.4v packages preserved the baseline engine but combined correct and incorrect path calculations, repeated readiness scans, duplicate callback registration, and incompatible data-transfer attempts. The build labelled `iconlogic_stable` was a full rewrite that removed scene polling and texture application entirely. See `FORENSIC_REVIEW_V1_4.md`.

## Consequence for current work

The interface will be tested as a disposable shell against a read-only fixture before it is connected to v1.3. The canonical switching engine will not be modified to make a selector render.
