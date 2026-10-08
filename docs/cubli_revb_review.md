# Cubli one-wheel Rev B review — 2026-10-08

Status: **PARTIAL prototype engineering review; manufacturing and self-righting release HOLD**.
Actual Inventor2026.2 COM parts/IAMs were created; Rev A source was preserved.
Native absolute references are local-only. Public STEP/STL are independently authored neutral geometry.

## Confirmed native CAD, with material/envelope assumptions

|Item|Rev A|Rev B|
|---|---:|---:|
|Module mass|892.97g|695.96g|
|Wheel assembly mass|151.85g|159.23g|
|Wheel polar inertia|0.00047409kg m2|0.00063732kg m2|

Module reduction 22.06%; wheel inertia gain 34.43%.
19g SKF bearing mass overrides save17.96g by correcting a solid-ring proxy, NOT geometry lightening.
Remaining change includes smaller aluminium housing/caliper, open ribbed frame, thinner guard,
steel rim with lightweight spokes, and newly added actuator/wedge/return envelopes.
Detailed per-part descending mass is in mass_comparison.json.

B3 has53 parts/155 healthy native constraints, one grounded module frame.
Axis mate plus axial flush leaves wheel rotation free. InputStroke0..10mm drives
slider+Y, lower pad+0.065 input, upper pad-0.035 input. Total closing1.0mm;
pad-to-disc clearances0.65/0.35mm. The legacy1.2mm requirement is replaced for
this modeled disc stack only; wear/travel reserve is NOT yet qualified.
OPEN/PARTIAL/CLOSED and five wheel angles were analyzed.
Released/wheel poses:0 interference. PARTIAL/CLOSED:four carrier/spring solid
envelope overlaps, representing unmodeled spring compression. Real spring wire,
solid height and clearance still HOLD. Discrete sampling is not a swept-volume proof.

## Wheel alternatives actually modeled

A original151.85g/J0.00047409; B aluminium rim169.70g/J0.00067718;
C separate steel rim+aluminium spider159.23g/J0.00063732 (selected review baseline);
D steel rim+polymer spider151.98g/J0.00061214 (creep/joint fatigue HOLD).
All OD150mm; B rim13mm, C/D5.5mm, A7mm. Whole wheel thickness is larger due to hub/disc.
Native wheel IAMs and wheel_comparison.json are actual CAD mass properties.
C provides34.4% inertia increase with4.9% mass increase; more inertia also increases spin-up time/energy.
Rim grade, joining screws, balance, guard containment and maximum qualified RPM are unresolved.

## Calculated motor/brake/strength

FAULHABER4221G024BXTH remains the motor geometry; Micro is a conditional driver candidate.
The24V/.78 utilization/DC-equivalent model is explicitly an assumption, not a measured
Micro waveform/loaded speed curve. 3000/4000rpm conditional acceleration is in motor_analysis.json;
5000/6000rpm do not pass that voltage screen. Current conventions are kept separate.
Thermal steady operation is not qualified; no hardware limits or commission settings are approved.

Opposed-disc torque4Nm requires approximately256.6N
per pad at assumedmu0.15. PQ12/wedge input approximately36.7N,
10mm input at6mm/s takes1.67s. This is a **slow force/motion proof actuator, NOT an impulse brake**.
No claim of successful self-righting. See brake_actuator_selection.md.
Shaft, bracket, rim and bearing first-order screens are strength_analysis.json. FEA NOT RUN.
Material certificates, fatigue, fastener prying and real brake contact stiffness remain HOLD.

## Integration and highest milestone

Actual standalone/shared three-axis IAMs with orthogonal axes and staggered origins exist.
Shared modeled mass2.69129kg; 150g missing hardware/harness reserve makes
2.84129kg estimate. Shared docking saves62.02g.
Host-frame load-path joints and electronics mounting are provisional envelopes, not final manufacturing parts.
Static released integration interference0; nesting keeps module constraints but the top-level
placements are grounded fixture states, not a full robot dynamics assembly validation.
CAD-derived simulation_handoff.json excludes rotor groups from body inertia.

Face-to-edge loss sensitivity demands approximately9506..17111rpm in the selected launch
orientation; edge-to-point two-wheel screen7677..13818rpm. These exceed the current conditional
speed envelope and may exceed coupling/motor/guard limits. Contact transition simulation NOT RUN.
**Highest milestone: lightened native one-wheel review module plus actual three-axis packing IAM,
not a qualified self-righting robot or fabrication release.**

Native paths: mechanical/cubli_revb/local_native_b3/ and local_study_b2/.
Dimensioned IDW/PDF/STEP/STL/BOM are review artifacts with HOLD annotations, not manufacture approval.
No purchase, order, energized test or physical movement was performed.

## Drawing verification limitation

20 IDW/PDF review sheets were generated.16 sheets contain2 native dimensions;
4 (rim, hub, coupling envelope and clevis) have geometric views/notes but no associative
dimensions. Additional dimension/layout COM attempts did not complete reliably and were
stopped; the existing saved sheets were kept. The sampled wedge PDF is readable as a
review preview but its small-scale views and duplicate dimension placement require
production-drawing cleanup. Do NOT treat these as finalized manufacturing drawings.

## Bounded lightweight motor comparison (not a geometry replacement)

[FAULHABER3216W024BXTH official](https://www.faulhaber.com/fileadmin/Import/Media/EN_3216_BXTH_DFF.pdf):65.3g,38mNm continuous,6250rpm catalogue no-load. Saves about77g per motor but loses torque and still does not establish the required launch speed.
[maxon ECX FLAT42M ECXA42MZF50E8ILACO1Y519A official](https://www.maxongroup.com/maxon/view/product/motor/ecmotor/ECX-Flat/ECX-Flat-42/ECXA42MZF50E8ILACO1Y519A?download=show):127g,24V,213mNm continuous,6470rpm nominal,8050rpm no-load; nominal7.31A catalogue current exceeds Micro free-air envelope without convention/thermal qualification. Configurable variant requires exact flange/shaft freeze. Neither is selected or claimed self-righting-capable. Current4221 native motor model retained.
