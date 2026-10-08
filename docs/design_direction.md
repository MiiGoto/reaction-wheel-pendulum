# Development direction — provisional, 2026-10-08

Recommended: **B, preserve the 1-axis demonstrator and develop a separate 3-axis Cubli-style demonstrator**. The requested X post could not be fetched. SHISEIGYO-3 N1 is confirmed as a related three-wheel project, not confirmed as the exact posted machine. No irreversible replacement or procurement is justified.

| Option | Reference behavior | STM32 / CAN | GB54-1 | ODrive | Inventor assets | Difficulty / cost / likelihood |
|---|---|---|---|---|---|---|
| A finish 1 axis | limited-angle balance only; no point balance | reuse baseline | retain candidate pending data | one candidate driver | M1/M2 preserved | lowest added cost; highest staged completion prospect |
| B retain 1 axis, add 3 axes | edge/point balance and eventual get-up | shared CAN bus; new firmware | not accepted for direct-drive get-up | three drivers, model pending motor | reuse principles and PCB envelope; new frame | higher cost/control difficulty, manageable with staged gates |
| C substantially alter old machine | geometry incompatible with cube contacts | partial reuse | unchanged data gaps | three drivers likely | major changes to arm/pivot | high rework, little benefit over B |

Reuse is assessed by subsystem, not an invented percentage: controller PCB/CAN/debug/IMU architecture reusable in principle; whole physical integration and firmware unverified. Existing M1/M2 documents and native CAD remain untouched. Bearing/mount/PCB-carrier design practice is reusable, but the 220 mm arm geometry is not a cube frame. GB54 remains unpurchased and unqualified. No driver has been physically tested.

Original checkout: feature/odrive-mechanical-integration, HEAD27380da; user-modified KiCad project and two M1 assemblies retained. New branch starts at public32a3428 (b15af28 electrical ancestor) because private Inventor paths exist in unpublished old ancestors; copying that ancestry to a public branch is unsafe. Old design commits remain local. Main is not merged.

Major blocker: GB54-1 + prior90g annulus cannot establish self-righting momentum in the screened180mm/1.2kg geometry. Motor/encoder/brake/power/guard decisions precede manufacturing CAD. Current new CAD is a native clearance study, not fabrication drawings. See [motor selection](motor_selection.md), [validation](validation_plan.md) and [mechanical design](mechanical_design.md).
