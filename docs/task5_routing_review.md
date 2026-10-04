# Task 5 routing review — R0.5, not a manufacturing release

2026-10-03, KiCad 10.0.6. Based on feature/pcb-routing b1e6c23 and the user-approved Task4 outline/holes/connector placement. No autorouter, component relocation, schematic electrical modification, rule relaxation, exclusion or ignored check.

## Confirmed results

- PCB: 90 x 70 mm, four copper layers, 86 footprints; all component positions/rotations/part values/library IDs match the start-of-resume PCB. Four M3 NPTH/screw keepouts retained.
- 548 track segments: F.Cu349, In1.Cu0, In2.Cu82, B.Cu117. 155 through-vias,0.60/0.30mm. Vias serve actual transitions/local rail and return access; no automatic via carpet.
- All-severity native DRC with schematic parity: **Error0 / Warning0 / unrouted0 / parity0**, native exit0. No intentional remaining DRC warning.
- All-severity ERC: **Error0 / Warning1**, existing U4 SDX/GND pin-type warning required by ST unused auxiliary-bus connection. No schematic changes or suppression.
- Independently compared248 connected PCB pads to the native schematic XML: all names match. MCU/connector pin assignment preserved. No firmware, powered test, manufacturing output or order.

## Routing decisions and bounded repairs

Repair known R8 MOSI branch first, then SWD/reset/BOOT, ABI, debug UART, external ESC connector side, MCU/ESC control side; validate each group before the next. All routes were explicit manual polylines through native KiCad APIs. Each design stage used at most3 updated-layout DRC checks; one Encoder operation failed before saving due Python/SWIG object lifetime and was corrected without changing the prior PCB.

MOSI branch: keep R8 top escape to(89.0875,97.7), add0.60/0.30via there, B.Cu through(89.5875,98.2),(93.4,98.2),(95.5,96.1). Remove the two offending top segments. The original via at(95.5,96.1) became bottom-only and was removed after native dangling-via warning; this branch adds no net via count. C16 ground return remains unchanged.

MCU fine-pitch GPIO escapes were adjusted to clear actual pad shapes and local capacitor feeds. ENABLE via is(78.65,89); the adjacent MISO In2.Cu section goes from(77.75,89.15) via(77.75,88),(80.85,88) to(82,89.15), avoiding the new via. No net/pin reassignment. NRST north horizontal span crosses ABI on F.Cu rather than B.Cu, with local transitions. Low-rate UART2/fault paths take longer outer corridors to preserve existing sensor routes; they are not timing-matched high-speed buses.

## Power, ground and return review

L1 local pads/decoupling/signals; L2 uninterrupted common GND with no signal tracks; L3 common3V3 plus selected signals; L4 remaining signals. Native zone refill leaves exactly one connected polygon for each L2GND/L3+3V3 zone. Four all-copper mounting keepouts remain. No analog ground split or motor-current plane.

Input→SS14→AP2112/C1→C2→3V3 and existing local MCU/CAN/IMU/buffer supply/ground feeds retained. Capacitor local returns and MCU ground access use plane vias; VDDA/VREF remain common3V3, VREFBUF disabled. This is an LDO, with no switching node or exposed thermal pad.180mA bench budget/220mA source limit and unmeasured thermal estimate remain the limits, not a600mA board rating.

SPI main trunks on In2.Cu reference L2 GND. Short top escapes also reference L2. R8/R9 pull branches include bottom stubs; their MHz edge behavior remains unmeasured. Bottom-layer signals have L3 power as nearest plane, with local power-plane clearances around inner signals; therefore no claim of a uniform bottom GND reference or controlled impedance. L2 GND remains continuous beyond ordinary pad/via anti-pads. Reviewed four native layer plots: no signal-cut GND slots, disconnected copper islands, unexpected plane split or mounting interference. Supplier stackup/plane spacing and EMI/edge-rate qualification remain before release; DRC does not prove signal integrity.

CAN bus routing/protection remains from the previously validated stage: transceiver→TVS/connector, paired where practical, selectable120ohm at physical bus ends only. TVS ground has its local connector-side ground access. Short PCB stubs and lack of exact length matching are accepted for this prototype, without guaranteeing a final CAN-FD bitrate/ESD immunity. Common ground references at all connectors do not carry motor current.

## Safety, access and visual review

R19/R20/R22/R18 pulls, U5 active-high OE gate, R21 enable series link, R24 fault input and all connector pin order are retained and now PCB-connected. Reset/unpowered default-low intent is preserved; no actual ESC behavior verified. Debug halt can retain outputs; fault-wire disconnect can read inactive. Independent motor isolation and qualified timeout/watchdog/arming are still mandatory before motor tests.

All approved header locations/pin1 and power polarity remain. TP1/GND, TP4/3V3, TP5/NRST, TP7/8 CAN, TP15/PWM and TP16/EN remain exposed top probe pads. SWD/UART accessed at headers. Mounting/copper edge rules pass native DRC; mating housings/spacer height/enclosure access need mechanical confirmation.

U4 remains(90,92),rotation0, MCU(80,82); no sensor movement. Official ST Figure1/Figure17 previously reviewed: native+X right,+Y upper edge,+Z out of component face. Added explicit top silk axes in free area near(99,101); actual pendulum transform/sign calibration still TBD. Updated board legend toR0.5 and ROUTED / NOT RELEASED. Four native layer plots visually inspected; no obvious footprint/polarity/silk collision found. A new3D assembly qualification was not performed.

## Remaining release gates

Exact passive/header MPNs and capacitor effective capacitance; supplier4layer stackup/copper weights/0.15mm IMU pad spacing and stencil/reflow; THT solid-plane solderability/thermal-relief decision; LDO thermal/current/ripple measurements; actual encoder/RPM/PPR/ESC signal and shutdown contract; connector housing/strain relief/final mechanics; HSI CAN bitrate; sensor/control latency and fault policy. Do not manufacture/power/order solely because DRC is zero. Task6 is not started.

[Native top review](images/task5-routed-top.svg). Full native ERC/DRC and temporary layer PDF/PNGs are local ignored reports under hardware/kicad/outputs/task5; not fabrication files.
