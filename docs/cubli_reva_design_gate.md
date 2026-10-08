# Cubli Rev A detailed-design gate — 2026-10-08

Status: **STOPPED BEFORE DETAILED CAD; NOT MANUFACTURABLE**. The user explicitly
requires stopping when motor capability or important mounting information is not
established. GB54-1 does not pass the current self-righting screen, and its
mounting/thermal limits remain unresolved. Alternatives are shortlisted below,
but none is frozen as a qualified motor/brake/support/power combination.

This branch preserves the one-axis designs and earlier 31-solid Cubli clearance
study. The latter is not a constrained mechanism: grounded envelopes are not
rotor joints, a bare annulus is not a retained wheel, and a battery box is not a
selected power source. Existing Inventor mass overrides are assumed component
masses, not verified material densities or finished assembly mass.

## Confirmed reference and independent architecture

The requested SHISEIGYO-3 N1 motion is now the target; inability to identify the
earlier X video is no longer a reason to block reference selection. The author's
[brake development](https://homemadegarbage.com/reactionwheel83) describes
servo-driven band braking and successful get-up after brake changes. The
[public project](https://github.com/homemadegarbage/SHISEIGYO-3-N1) does not provide
a free mechanical CAD release in the inspected tree. No third-party CAD, code,
photos, drawings or vendor PDFs are redistributed here.

Proposed independent wheel axes are body +X, +Y, +Z. Allocation A has those axes
as columns: A=identity, rank=3, 2-norm condition number=1. Body reaction torque is
-A*u for positive torque into the wheels. This establishes torque allocation,
not contact stability, catch capability or yaw observability. Orthogonal wheels
still need individual angular momentum and speed headroom.

## Candidate sizes — Calculated from explicit assumptions

The new comparison assumes centered COM, uniform locked-body inertia and a
0.95 kg non-wheel budget. The budget is provisional and must change with frame,
driver, guards, brake, bearings and battery. These are not new Inventor values.

| Cube | Wheel OD / mass each | Total assumed mass | J each kg m² | Ideal face-edge RPM | RPM with 80% impulse transfer |
|---|---|---|---|---|---|
|160 mm|110 mm / 90 g|1.22 kg|0.00022725|5399|6749|
|180 mm|130 mm / 120 g|1.31 kg|0.00043500|3614|4518|
|200 mm|150 mm / 150 g|1.40 kg|0.00073875|2664|3330|

Annuli have 10 mm radial rim width; hub/spokes/drum change mass and inertia.
I_edge=2ma²/3 is locked inertia after braking; DeltaU=mg*a*(1/sqrt(2)-1/2).
H_required=sqrt(2*I_edge*DeltaU). A 20% impulse loss is a sensitivity assumption,
not a measurement or safety factor. New hub/support/guard clearances have not
been proved. 200 mm is a promising screening option, **not a frozen outline**.
The existing 180 mm off-center composite model is less optimistic and remains
separate; its prior requirement is 5093 ideal RPM with 90 g wheels.

GB54's catalogue KV times 24 V gives only 792 RPM before load/inverter losses.
Even these centered larger-rim options do not make that motor pass one-wheel
face-to-edge get-up. Counting the sum of three orthogonal wheel momenta as
available about a single edge is incorrect. The symmetric edge-to-point
potential barrier is also output; its two-wheel impulse, coupling and catch
are **not** solved by the face-edge calculation.

## Real motor alternatives — shortlist, not procurement selection

| Motor | Official evidence | Decision / remaining limits |
|---|---|---|
| LIGPOWER GB54-1 KV33 | 137 g, catalogue 0.33 N m, 3–6S; 12N14P | Reject for present self-righting concept. Rated duty, loaded speed, thread engagement and fixed/rotating face still unqualified. |
| LIGPOWER MN4006 EVO KV380 | 73 g; 44.1×29.3 mm; 4 mm shaft; manufacturer propeller bench curves | Lightweight higher-speed alternative. Those DC bench currents are not FOC Iq. Rotor retention, reversing duty and enclosed cooling need qualification. Micro current ceiling limits direct torque; S1 adds substantial packaging burden. |
| FAULHABER 4221 G 024 BXT H, no integrated SC | 142 g; 42 mm housing; 24 V; 112 mN m continuous at 4380 RPM; 6040 RPM no-load; 7 pole pairs; 5 mm shaft | Preferred next **qualification** candidate: documented winding, thermal and shaft limits. Do not substitute integrated speed-controller SC variant for external ODrive torque control. Drawing lists six M3 holes, max. 3 mm deep; exact selected option and dimensioned geometry must be visually checked before mount CAD. |
| maxon EC45 flat 70 W, 651614 (24 V Hall V1) | 150.4 g; 134 mN m continuous / 4750 RPM; 5600 no-load; 8 pole pairs | Documented backup. Available catalogue marks motor data provisional; verify current order variant/drawing. Shaft load rating is low; do not hang a brake-loaded flywheel directly on it. |

Sources: [GB54](https://www.ligpower.com/product/gb54-1-gimbal-type.html),
[MN4006](https://www.ligpower.com/product/ligpower-mn4006-EVO-kv380-motor-antigravity-type.html),
[FAULHABER 2026-07-28 datasheet](https://www.faulhaber.com/fileadmin/Import/Media/EN_4221_BXTH_DFF.pdf),
[maxon catalogue](https://www.maxongroup.com/medias/sys_master/root/8882563186718/EN-21-299.pdf).
Cost/stock remain TBD. Manufacturer starting/stall torque is not a usable
continuous or impact-braking limit.

## Driver and encoder qualification

ODrive Micro remains the lightweight candidate per motor: 32×32×7 mm,
3.5 A free-air at 25°C / 7 A peak, DC 10–31 V. Three independent motors require
three single-axis drivers. S1's 20 A free-air capability is unnecessary for the
FAULHABER candidate's nominal duty; its exact enclosure/mass/mount envelope
has not been selected. S1 provides resistor connections, with a separate
resistor for each S1; Micro needs a qualified external regenerative-energy path.

[Micro datasheet](https://docs.odriverobotics.com/v/latest/hardware/micro-datasheet.html),
[S1 datasheet](https://docs.odriverobotics.com/v/latest/hardware/s1-datasheet.html).
At 24 V, neither quoted motor no-load speed is a guaranteed ODrive loaded speed:
Micro lists 78% modulation depth. Current conventions must also be translated,
not copied. [FAULHABER AN190](https://www.faulhaber.com/fileadmin/Import/Media/AN190_EN.pdf)
distinguishes DC-equivalent motor current from sine RMS. Its 0.78 conversion
would map 2.87 A to about 2.24 A RMS, then 3.17 A sinusoidal peak; applying that
as ODrive's limit requires confirmation of its configured Iq convention and
motor thermal environment. No torque margin is declared from mismatched units.
The BXT family is slotted; generic slotless PWM recommendations are not blindly
applied to it. Cooling through a printed bracket does not reproduce metal-flange
thermal ratings.

AS5047P external SPI is a candidate for wheel feedback, not a released sensor
mount. Micro documentation requires AMS MOSI tied to VCC. Magnet air gap,
shaft-end availability, separate wheel bearing shaft, sensor PCB and mechanical
alignment remain open. Do not assume Hall commutation alone supplies suitable
wheel-angle feedback near zero speed. Keep STM32 outer-loop 500 Hz and CAN
1 Mbit/s as assumptions; prior three-node frame budget is 19.15%.

## Brake and shaft loads — the decisive mechanical issue

Electrical braking limited to roughly 0.1 N m cannot instantaneously overcome
the assumed 200 mm body's initial 1.373 N m gravity torque about an edge.
A band brake is the leading mechanism candidate, with a metal braking drum
and separately supported wheel shaft. A disc brake is a backup, trading caliper
mass for better two-direction operation. A band is direction-sensitive: the
tight/slack ends swap on reversal, so a one-way servo pull is not a qualified
two-direction brake. A brake resistor controls DC bus energy; it does not create
an additional mechanical wheel-brake torque path.

For the 200 mm option at 3330 RPM, one wheel stores 44.90 J and 0.25758 N m s.
T_tight/T_slack=exp(mu*wrap), brake torque=(T_tight-T_slack)*r. The sensitivity
uses mu=0.15/0.25/0.35, wrap=270 degrees, drum radius=55 mm and stop times
20/50/100 ms. Full numbers are in `mechanical/cubli_reva_review/feasibility.json`.
They are stationary-body estimates: actual rotating body changes stopping time.

At 4 N m, tension difference alone is 72.7 N. The resultant force cannot be
smaller than this difference; it exceeds the FAULHABER's stated 25 N radial
allowance (only at 3000 RPM and 5 mm from flange). Actual longer overhang and
3330 RPM are outside that stated condition. A direct cantilever wheel/band on
the motor shaft is therefore rejected. Specify a separately bearing-supported
shaft, positive axial retention and a rated torsional connection before mounts.
Servo stall torque does not qualify brake stroke force, engagement time,
continuous holding, spring return, release clearance or wear. No servo MPN is
frozen on the strength of a stall-torque advertisement.

The elementary finite-time fixed-edge screen at 3330 RPM gives:

|Constant brake|Face-edge barrier crossed in ideal model|Stop relative spin|Required contact friction peak|
|---|---|---|---|
|2 N m|No|128 ms|0.463|
|4 N m|Yes|64 ms|0.769|
|8 N m|Yes|32 ms|1.008|

This model integrates gravity while transferring momentum, then locks wheel and
body inertia. It only assumes one fixed edge. It has **no slipping/contact
transition/impact/catch model**, no measured lining friction and no servo delay.
Positive normal force alone does not ensure no slip. Stronger braking raises
required floor friction; a larger servo does not automatically solve get-up.
Time-step halving is checked in JSON; numerical agreement is not physical
validation. Edge-to-point self-righting and point-balance catch remain unsolved.

## Retention, energy and release decision

Aluminum thin-ring hoop stress at the screened 3330 RPM is about 1.85 MPa using
assumed density 2700 kg/m³. This does not check spokes, hub holes, bolt bearing,
fatigue, rotor imbalance or containment. No safe/max prototype RPM is assigned.
FDM frame/guard candidates and a metal rim remain material candidates; a fast
printed wheel is not released. Printed bearing seats need measured fit and
retaining shoulders, not assumed printer accuracy.

All three screened wheel energies sum to 134.7 J. If an isolated DC link absorbed
all of it, holding 24→30 V would require 0.832 F ideal capacitance; a 50 ms
all-electrical stop would imply about 112 A average at 24 V. These are stress
scenarios, not circuit ratings or a battery choice. Mechanical brakes put much
of that heat into drums/linings, but electrical regeneration during normal
torque reversal still needs a rated absorber and source. No RoboMaster-supercap
interconnection is authorized. Battery pack, emergency disconnect, fuse,
servo regulator and cable routing cannot yet be sized as released components.

**Stop condition reached:** GB54 fails the requested movement screen; replacing
it does not yet establish a qualified brake/support/retention/power system.
Do not turn unverified shaft loads, brake capability or mounting geometry into
manufacturing dimensions. Detailed .ipt/.iam/.idw, production BOM, drawings and
STL/DXF/PDF are intentionally not generated. Existing concept exports remain
clearly labelled. No purchase, fabrication, powered test or spin is performed.

Next single task: qualify a FAULHABER 4221 G 024 BXT H + Micro + separate bearing
shaft + bidirectional band/brake actuator module, including motor/driver current
mapping, loaded-speed headroom, shaft load/retention, exact drawings and a
face-edge-point contact model with friction/impact uncertainty. If that module
passes, detailed 200 mm cube CAD may proceed from verified interfaces; if it
fails, compare the named maxon backup or revise inertia/mass/contact geometry.
