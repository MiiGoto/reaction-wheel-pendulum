# One-wheel native Inventor module — 2026-10-08

**PARTIAL prototype. Actual Inventor CAD exists; NOT manufacturing approved.**

Inventor 2026.2 was visible and controlled through its official COM API. The
10×10×2 mm write/close/reopen test returned one solid and 200 mm³. Computer Use
failed before any UI operation. Captures here are actual Inventor viewports,
not fabricated UI screenshots. Browser-tree, Mass Properties dialog and
Interference dialog screenshots remain unavailable; machine-readable results
come from the native API.

Current local native directory: `local_native_v4/` (intentionally excluded from
public Git because native reference metadata contains workstation paths).
36 valid single-solid IPTs, one IAM and 14 IDWs are present. The IAM reopened
with all36 references,104 healthy unsuppressed constraints and only the frame
grounded. Shaft axis+axial constraints preserve rotation. `BrakeStroke`
drives two opposed pads/carriers from0 to0.35 mm; these are driven coordinates,
not an installed actuator. Five rotor angles and released/contact pad states
were analyzed natively; all seven had zero interference pairs. This is discrete
geometry checking, not a continuous sweep, load/contact simulation or physical test.

Public independent exports:37 STEP files (36 parts+assembly),3 STL files and14
PDF review drawings. Each PDF has native dimensions but is deliberately HOLD;
they do not fully specify every manufacturing tolerance/thread/finish. No
third-party model or vendor PDF is redistributed. See assembly instructions,
BOM, design calculations and verification reports for limitations.

## Reproduction

On a Windows host with Inventor2026 running, use a **fresh PowerShell process**
for each script. `build_module.ps1 -PartsOnly -NativeDirectory <new path>` then
`add_retention_parts.ps1` and `finalize_module.ps1` build the geometry. Check the
NativeDirectory parameter/default before running any step; scripts refuse to
replace existing native outputs. The historical `correct_interfaces.ps1`
copies v3 into a new v4 and replaces only own hub/bracket geometry; it is not
needed for a clean build using the corrected generator.

The default current directory in all generation scripts is v4. The initial builder creates parts only; use the finalizer for assembly.
`drawings_exports.ps1` creates native IDW/PDF/STL. `dimension_drawings.ps1`
adds linear dimensions; `diameter_drawings.ps1` adds rim/hub diameters.
`evidence_views.ps1` captures native geometry and verifies reopen/references.
Running dimension scripts twice would duplicate annotations, so use only on
new output or deliberately inspect the existing generated drawing first.

The 2025 interop DLL supplies enum definitions only; scripts verify that the
COM server is2026.2. This is not a claim of using Inventor2025 for geometry.

## Status

| Work | State |
|---|---|
| Native write test,36parts/IAM,104constraints,STEP/STL | COMPLETED |
| Native mass and seven discrete interference poses | COMPLETED within stated scope |
| Bidirectional brake hardware, actuator, coupling and tolerances | PARTIAL/HOLD |
| Drawings/BOM and native viewport evidence | PARTIAL; actual files, not release-approved |
| Whole-cube self-righting, FEA, thermal/physical qualification | BLOCKED / NOT STARTED |

No purchase, order, energizing or physical brake/motor test occurred.
