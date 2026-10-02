# Task 4 preliminary PCB placement

Date: 2026-10-03. Base: Task3 `cc09087`; Task2/3 not merged into main. This is an unrouted feasibility board, not a fabrication release.

## Strategy and mechanical assumptions

Review connectors/mounting first, then power, MCU/local decoupling, IMU, CAN, encoder, ESC, debug and probes. Board outline is **90 x 70 mm preliminary**, coordinate origin (40,40)mm in KiCad. Four M3 3.2mm NPTH centers: (45,45), (125,45), (45,105), (125,105)mm. Reserve radius4mm for screw head/spacer/tool access; actual screw, washer and spacer dimensions TBD. Hole centers are5mm from edges. This is not a final enclosure or pendulum mounting pattern. No mechanical CAD redesign.

Components are on top for rework; through-hole headers accessible from above, cables leave via nearby edge with controlled strain relief. No high-current motor wiring crosses this controller. Connector mating housings and assembly height are still TBD; bare headers have no mechanical key, so silk, pin1 markings and cable checking are required.

## Layer and routing rules (planning only)

4-layer chosen over2-layer: easier continuous GND return, short local decoupling returns, SPI/CAN routing separation and noise control around IMU/ADC.2-layer costs less and is feasible but makes return-plane continuity and crossings harder on this prototype. Planned F.Cu signals/components, In1.Cu GND, In2.Cu power/slow signals, B.Cu signals. No plane/pour is created in Task4. Nominal board thickness1.6mm is a placeholder; vendor stackup/copper weights/dielectric and any impedance target remain TBD.

| Rule / class | Preliminary value | Purpose |
| --- | --- | --- |
| Default signal width / clearance |0.20 /0.20mm | general traces; U4 internal pad exception below |
| POWER width |0.50mm |3.3V/5V rails, <=180mA normal budget; not BLDC current |
| CAN width / nominal pair gap |0.25 /0.25mm | same-region pair planning, not impedance-qualified |
| Via diameter / drill |0.60 /0.30mm | ordinary through-via; no microvia |
| Copper to board edge |>=0.50mm | outline/connector tolerance |
| Hole-to-hole |>=0.25mm | fabrication placeholder, vendor review required |

Net classes: Default, POWER, CAN only. SPI/SWD use Default; no unnecessary separate classes. Native custom rules enforce minimums in baseline DRC. Net-class and manufacturer-rule review must be repeated before routing/fabrication.

## Planned block locations

Power J1/D1/U2 at left upper edge; U2 input/output caps local. MCU U1 centered at(80,82)mm with VDD-specific C3–C6 at physical pads16/32/48/64, VBAT C8 and analog C9–C12 beside the associated edge. Small100nF/10nF caps first in future short pin-cap-return loops; bulk caps support locally. Nearby positions alone are not completed electrical loops until routing/vias are reviewed.

IMU U4 at(90,92)mm, near MCU SPI pins, inside mounting rectangle and away from board edge/connector strain, CAN and LDO. LDO is linear (no switching node); motor power is external. Rigid mounting, vibration and pendulum-axis relation require mechanical review. Native package pin1 is preserved; drawing-frame +X right/+Y up/+Z out is explicit on Dwgs.User. Native sensor-axis arrows must be checked against ST Fig1 before final silk and mechanical transform are approved; a drawing-frame arrow is not a claimed die-axis mapping.

CAN U3→D3→J3 flows toward right upper edge; TVS is connector-side, selectable termination adjacent. Encoder J5 on upper edge, ABI passives between header and MCU upper pins. ESC J6 on right edge, U5/pulls near it; J1 is opposite side to reduce power/signal confusion. SWD J2 and UART J7 on upper edge with distinct printed pin legends. Test points placed by target circuits; header GND also serves as local scope reference.

Ratsnest review, actual placement measurements, DRC classification and any adjustments are recorded in the Task4 validation section. No tracks, vias, filled zones, Gerbers or firmware are produced.

## Final placement review for Task 4

U4 standard0.5mm pitch pads are0.35mm wide, leaving0.15mm gap. Explicit U4-to-U4 clearance0.15mm is the sole local exception; general routing clearance stays0.20mm. Manufacturer acceptance is TBD, no suppression/exclusion used. All86footprints placed;0tracks/vias and0zones. DRC0physical violations/0parity,173unrouted. Full coordinates and pad dimensions: [footprint_review.csv](footprint_review.csv).

C3/C4/C5/C6 positive pad to corresponding MCU VDD16/32/48/64 distances2.46/1.89/2.38/2.48mm; C8VBAT3.98mm, C9VDDA2.43mm, C11VREF3.10mm. These are straight placement distances, not routed loop lengths. Ground via positions/return path await routing. SPI block next to MCU lower-right pads; CAN TX/RX travels toward right upper transceiver, then connector-side TVS. Encoder routes from upper edge toward PB4/PB5. Power is left, ESC logic/right connector opposite; no extreme selected-signal airwire crossing cluster. Actual routing feasibility/return paths are not certified by ratsnest review.

[Native pad/silk/outline export](images/pcb-placement.svg) and [selected-net airwire review](images/pcb-ratsnest-review.svg) are original review artifacts. Airwire SVG uses simplified component markers and straight connections from actual pads; it is not a KiCad track layer or assembly drawing. Native3D top view was inspected locally; missing IMU/header models mean body/mating height needs separate mechanical review. Reference fields are on F.Fab to avoid provisional silk clutter; connector/polarity legends remain on F.Silkscreen. Final fabrication references/IMU sensor-axis silk await review.
