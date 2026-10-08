# One-wheel module assembly instructions — Rev A REVIEW/HOLD

This document describes the modeled prototype, not authorization to manufacture
or rotate it. Coordinates are mm: frame XY, wheel axis +Z, frame rear face Z=0.
Overall native envelope180×180×113.5mm, Z=-46..67.5. Four Ø4.2 common-interface
holes are on168mm square. Three copies require a new shared-frame packaging
study; the depth and repeated frame/guard masses do not fit an assumed ideal cube.

## Geometry / material / fit register

| Part | Defined geometry | Classification and hold |
|---|---|---|
| Motor | Ø42,22long;Ø16pilot1.5long;Ø5shaft13long;6M3PCD22,maxdepth3 | A manufacturer drawing; shaft steel/connector option not specified. Cable exit may extend26mm radius, not fully modeled |
| Rim | 6061 proxy;OD150/ID136,t7;6Ø3.2PCD142,start30° | B dimension; certified temper/finish and balance HOLD |
| Spider | Al148OD rim-cross,t1.5;6rim holes;4Ø3.2PCD28 | B geometry; printed alternative NOT qualified |
| Hub | Ø24core,bore10;Ø36flanges;rear4M3PCD32/front4M3PCD28 | B geometry; tap drillØ2.5 modeled, actual threads/engagement and key tolerance HOLD |
| Brake disc | OD110/ID90,spokes,centralØ30,t1.5;4Ø3.2PCD32 | C stainless library proxy; actual grade/flatness/finish/friction pairing HOLD |
| Shaft | Ø10seats;Ø12shoulderZ14..26;Z-10..57 | B stress sizing; proposed k5 bearing seats/h6other surfaces, grade/fillets/fatigue HOLD |
| Key | custom3×3×12,shaftcutdepth1/hubdepth2 | C non-standard key depth; positive torque transfer modeled, machining fit HOLD |
| Retention | front spacer/shims/washer/external clip;Ø9.2×1.1groove | C custom clip envelope; qualified standard, groove root/edge margin and axial preload HOLD |
| Bearings | 2SKF6000-2Z,10×26×8,centersZ10/30 | A dimensions; CAD solid rings are mass/inertia proxies, not rolling contacts |
| Housing | 52square,Z6..34;2Ø26×8seats;Ø22relief;4M4clearat±22;4M3tap at±16 | B geometry; H7 seats/coaxiality0.02 proposed, locating/floating scheme HOLD |
| Motor plate | 52square,t3;Ø16.1pilot;6Ø3.2PCD22;4Ø4.2at±22 | B geometry;6M3x6+0.5washer yields2.5engagement, verify<=3.0 on real stack |
| Coupling | OD18,5/10bores,16long,slotted | C geometry ONLY; clamp fasteners/locking/compliance absent, torque path is manufacturing blocker |
| Caliper | opposing pads at49mm radius,guide pins at(49,±32);base2M3tap(65,±8) | B geometry; bracket stiffness and actuator force/duty HOLD |
| Pads/carriers | 10×14×2linings;carriers16×72;release0.35each | C linings use PET density proxy ONLY, never use printed PET as qualified friction material |
| Actuator interface | flange holes at(76,-12)/(84,12),Ø4.2 | C configurable prototype holes; no selected or installed actuator/linkage/spring |
| Encoder | 5×2magnet atZ57..59;20squareboardZ60.5..62.1 | C PCB,magnet and die position unknown;1.5face-to-PCB gap is NOT measured die gap |
| Frame/guard | 180square,t4frame;guard176inside/180outside | C PET library density; FDM resin/process/impact containment HOLD |

## Assembly order after HOLD items are closed

1. Inspect certified shaft/key/clip, bearing fits, housing coaxiality and all threads.
2. Press bearings with support on the race being fitted. Never transmit press force through balls.
3. Fit the shaft, shoulder/spacer, front hub and shim stack; retain axially with the qualified clip. Resolve rear bearing thermal float and front preload before assembly.
4. Attach the disc to rear hub PCD32 and spider to front PCD28; rim uses six PCD142 screws. Confirm hole patterns and measured engagement; balance complete rotating stack including magnet, key and fasteners.
5. Mount motor using six M3 screws limited to3mm insertion. Install a qualified torsionally compliant5-to10 coupling; current native slotted shape cannot yet carry torque safely.
6. Assemble caliper guide pins, carriers and qualified friction linings. Define retained return springs/stops, equal-pad actuation, fail-release behavior and verified actuator before any brake operation.
7. Install encoder PCB/bracket and mechanically retain magnet; qualify concentricity, die gap, electrical interface and cable exit. Motor feedback is ODrive's responsibility.
8. Bolt frame and guard to a rigid fixture with known mating thickness. Preserve access to all nuts, motor screws and probes; most fasteners are BOM entries, not modeled installed solids.
9. Route phase wires behind the motor with strain relief, independently from encoder/CAN. Verify motor's26mm-radius cable exit. Micro32square and board/cable clearances must be integrated in a later host assembly.
10. No powered test until electrical regen protection, driver current units, overspeed cut-off, fully enclosed fragment guard and independent isolation are reviewed.

## Brake qualification requirements

Opposing disc pads are symmetric under direction reversal. T=2µN r_eff.
At4Nm,r_eff49mm,µ=.15/.25/.35,each pad needs272/163/117N.
Design interface requires>=350N EACH pad (not350N sum),>=1.2mm total closing
travel including estimated plate compliance, and a target<20ms engagement.
Those are required capabilities, not tested actuator data. An actuator remains
unselected: servo stall torque is insufficient as qualification. Release springs,
lining supplier, wear, retention, stops, response and repetitive duty are HOLD.
Approximate bracket compliance atµ=.15 is0.13mm per plate before joint/frame
compliance. A simple0.7mm rigid-body closure does not establish loaded brake travel.

Nominal3330rpm stop is~42ms after full4Nm engagement;~29.3J kinetic energy including
modeled rotor stack/catalogue motor inertia. Single uniform-disc temperature rise
~1.1K with assumedcp500J/kg/K says nothing about contact flash temperature.
At10stops/min average heating is~4.9W; no repetitive thermal validation exists.
4Nm is a candidate requirement, never a certified safe brake rating.

## Strength / safety / manufacturing blockers

- Shaft nominal bending~6.9MPa,torsion~20.4MPa. Combined3×shock andKf2 screen~216MPa; fatigue/material/fillets/FEA absent. Torque loading is deliberately conservative; motor shaft must NOT carry disc radial loads.
- Bearing nominal front~115N/rear~34N,3×shock~346/101N. Compare608-2Z8×22×7,C3.45kN/C01.37kN against6000-2Z10×26×8,C4.75/C01.96kN catalogue screening. Larger shaft stiffness favors6000. Specific2Zspeed rating, preload,axial load/life and shock duty still require supplier freeze; open-bearing speed was NOT used as2Zrating.
- Thin-ring centrifugal hoop stress~1.85MPa at3330rpm/~4.16MPa at5000rpm,6061density assumption. Bolted spokes/key/groove and impact/burst containment dominate uncertainty; no permissible overspeed is certified.
- Wheel imbalance of0.1mm at3330rpm generates~1.85N; assembly balancing/retention inspection are required. No wheel test performed.
- Proposed prototype3330rpm and4Nm are analysis points, not enabled firmware limits.5000rpm is a stress sensitivity only. FDM guard is a clearance envelope, not a burst-rated guard.
- Fastener lengths/counts are a preliminary stack plan; no tightening torque specified without material/thread/locking qualification. Brake guide pins need positive axial retention; pad fasteners/bonding and installed hardware access remain incomplete.
- Drawings contain views, two native dimensions and selected notes, not a complete manufacturing dimension set. Full detail drawings for retention, coupling, carriers/fasteners, actuator and calibrated fits are required before release.

No machining/printing order,purchase,energizing,spin or brake physical actuation is authorized by these files.
