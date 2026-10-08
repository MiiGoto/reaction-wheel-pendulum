# Repository rules

## Before editing

1. Read `PROJECT_CONTEXT.md`.
2. Read `requirements.md` and affected design documents.
3. Run `git status`; inspect relevant diffs and current branch.
4. Never overwrite or discard uncommitted user changes. Preserve existing files.
5. Separate confirmed facts, assumptions and open issues; do not silently fix TBDs.

## Hardware changes

1. Verify official datasheets, reference manuals, errata and board manuals before designing a circuit. Record revision, section and verification status in `docs/sources.md`.
2. Check actual part/package, physical pin numbers, alternate functions, supply pins, voltage limits and footprint orientation. Logical GPIO names are not physical pin numbers.
3. Prefer native KiCad editing. Any new generated schematic must pass native parser/export and ERC before commit. Do not make unvalidated direct edits to existing KiCad designs.
4. Run `kicad-cli sch erc --severity-all --exit-code-violations` after schematic changes. Resolve violations; explain intentional warnings in `docs/design_notes.md`. Never suppress errors to claim completion.
5. Run `kicad-cli pcb drc --severity-all --exit-code-violations` after PCB changes. Do not declare completion without reviewing the report.
6. Update pinout, power tree, requirements and bring-up documentation as applicable.
7. Conceptual blocks and empty ERC checks are not an electrically complete schematic. Routing and fabrication require a reviewed circuit and mechanical constraints.

## Git

- Use small meaningful commits; group related documentation updates.
- Inspect `git status`, `git diff`, `git diff --staged` before committing and pushing.
- Never force push, rewrite published history, use `git reset --hard` or `git clean -fd`.
- Never delete user files or discard uncommitted changes.
- Check staged files and all unpublished commits for credentials, personal data, machine-specific secrets, private URLs, proprietary content and third-party licensing before public push.
- Use a public noreply or project-local neutral commit identity; do not publish personal email addresses from global Git settings.
- Track primary KiCad design files. Exclude user preferences, caches, backups and generated outputs.
- Never commit downloaded tool binaries, credentials or vendor PDFs/SDKs without an explicit licensing review.

## Validation and safety

New or revised copper must use45degree bends or arcs; no90degree bends or acute-angle copper. Preserve net/width/clearance/return path and avoid unnecessary vias. A passing DRC does not validate trace geometry. Keep reference-machine identification and engineering assumptions explicit; no copying third-party CAD from a software-license declaration alone. Native CAD containing private paths stays local; publish independent generators and validated neutral geometry instead. Preserve the existing1axis design when exploring3axes.

Document what was actually tested and the limits of the test. Unknown voltage, motor limits or braking behavior block powered motor testing. Use a current-limited supply, guarded wheel, mechanical fixture, independent power isolation and an agreed safe-state policy. Do not assume zero command or communication loss means zero torque.
