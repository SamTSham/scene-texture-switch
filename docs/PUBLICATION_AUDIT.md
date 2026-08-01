# Scene TextureSwitch publication audit

Audit basis: internal release candidate `1.2.0-rc.11`, 1 August 2026.

This document is the release gate for the first public version. Internal
release-candidate history remains preserved; the public release will begin at
`1.0.0`.

## Ready

- The extension adds functionality that SketchUp does not provide natively.
- Core use has been proven in four production set-design projects.
- 69 automated tests cover 318 assertions with no failures.
- The extension works without an account, payment, licence server, or network.
- The package contains an offline detailed guide, screenshots, starter images,
  and a minimal working SketchUp example.
- No packaged file contains a private user or project path.
- The release can now be rebuilt using only files stored in this repository.
- All external working files such as PSD, TIFF, and PDF are ignored safely.

## Required before public 1.0.0

- Build an Extension Warehouse-compliant RBZ containing exactly one root Ruby
  loader and one identically named extension folder.
- Remove the retired preview-extension shim from the public package.
- Replace development-facing folder and module names where appropriate.
- Confirm the final author name, copyright notice, support route, and licence.
- Change public metadata from `1.2.0-rc.11` to `1.0.0`.
- Run a clean installation after removing development builds.
- Verify the packaged example and every item in the smoke-test checklist.

## Compatibility still to establish

- Confirmed manually: SketchUp 2026 on macOS.
- Desired before broad compatibility claims: one Windows test.
- The supplied example is saved in SketchUp 2013 format for broad readability.
- Until verified, do not claim support for untested SketchUp versions.

## Publication material still needed

- Extension icon and listing images.
- 90-second demonstration using the GHOST and Er Ist Wieder Da sets.
- Public short description, full description, keywords, and release notes.
- Public GitHub repository and issue-reporting page.
- Extension Warehouse developer account and submission.
- SketchUcation Plugin Author access and submission.

## Official packaging rule

The Extension Warehouse requires an RBZ root containing one Ruby loader and one
folder with the same basename as that loader. The existing RC package is a test
installer and intentionally does not yet satisfy that final publication shape.
