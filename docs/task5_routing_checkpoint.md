# Task 5 interface routing checkpoint — incomplete, not for manufacture

Current branch: feature/pcb-routing, based on Task4 placement. User-approved90x70mm/fourM3holes/connectors retained. No routing acceptance or manufacturing release.

## Actual verification

- Native KiCad10.0.6 DRC: **47Errors/0Warnings** =2physical errors+45unconnected items on26distinct signal nets;0schematic parity issues. All severities enabled, no excluded/ignored checks.
- ERC:0Errors/1intentionalWarning (U4 SDX/GND pin-type warning), no schematic electrical modifications.
-318track segments,108through-vias0.60/0.30mm,86footprints. In1.Cu GND and In2.Cu+3V3 each refill to one connected polygon. Four existing all-copper mounting keepouts retained.
- Power/GND and CAN nets are connected. IMU nets appear connected geometrically but are **not electrically acceptable because MOSI is shorted to GND**.
- F.Cu and SPI In2.Cu routes reference uninterrupted In1.Cu GND; bottom slow CAN/interrupt routes use the existing power plane as the nearest copper reference. Full signal-return/EMI/thermal/sign-off review is outstanding. No signal routing cuts the GND plane into slots.

## Remaining physical errors and stop

1. IMU_MOSI R8 pull branch at y97.7mm shorts C16 GND via at(90,97.4).
2. Same branch violates0.20mm clearance against C16 GND return track; actual0.10mm.

Initial IMU stage had14violations. Second stage reduced to3; third cleared the MISO-pad interaction but introduced the above two GND interactions. Stop per user2–3attempt condition; no rule relaxation or another routing attempt. Proposed human review: take R8 pull branch through a short local layer bridge instead of the narrow surface corridor bounded by C16 GND and R9 MISO pad. Check via clearance, existing routes and return reference before approving implementation. No claim this untested proposal passesDRC.

CAN bus stage initially had crossing/short errors. Automatic approval stopped another attempt; user explicitly approved one extra local correction. That check had0physical violations. CAN TX/RX/STB stage subsequently passed0physical violations after its own bounded checks. Do not confuse the earlier resolved CAN gate with the present unresolved IMU gate.

## Review artifacts

[Top-copper draft](images/task5-interfaces-draft.svg) is the native export, visually reviewed; it is an incomplete view, not a final PCB image. [Manual-route manifest](routing_interfaces_draft.csv) records deliberate polylines only; not an autorouter result or fabrication output. Source PCB remains authoritative for vias/zones/pad connectivity. No Gerber/drill/PnP files generated.

## Still unrouted

`/ENCODER ESC/ENC_A_EXT`, `/ENCODER ESC/ENC_B_EXT`, `/ENCODER ESC/ENC_Z_EXT`, `/ENCODER ESC/ESC_EN_OUT`, `/ENCODER ESC/ESC_FAULT_EXT_N`, `/ENCODER ESC/ESC_PWM`, `/ENCODER ESC/ESC_PWM_DRV`, `/MCU POWER SWD/BOOT0`, `/MCU POWER SWD/NRST`, `/MCU POWER SWD/SWCLK`, `/MCU POWER SWD/SWDIO`, `/MCU POWER SWD/SWO`, `ENC_A`, `ENC_B`, `ENC_Z`, `ESC_ENABLE`, `ESC_FAULT_N`, `ESC_RX_EXT`, `ESC_TX_EXT`, `ESC_UART_RX`, `ESC_UART_TX`, `MOTOR_PWM`, `UART_RX`, `UART_RX_EXT`, `UART_TX`, `UART_TX_EXT`.

SWD/reset/BOOT, ABI encoder, UART and ESC interfaces are outstanding. ESC safety circuit intent is preserved in schematic, but incomplete PCB routing cannot establish or validate the intended safe state. No firmware, hardware power-up or motor test.

## IMU source and orientation

User-supplied official ST LSM6DSL DocID028475 Rev7 Figure1/page18 and Figure17/page110 were rendered and visually checked. Pin1/top-versus-bottom package view verified. U4 rotation0 maintained. Combining the top-view sensor diagram and package geometry gives native+Xright/+Yupperedge/+Zout of component side; this is a board-frame interpretation, not a measured mechanical transform. Pendulum mounting/sign verification and final axis silkscreen remain TBD.

## Next review gate

Resolve the R8 branch safely with explicit permission for further IMU troubleshooting or a human-edited route, then finish remaining interfaces and repeat all-severity DRC/parity/return-path/visual review. Task5 remains incomplete. Do not start Task6/manufacture/order/powered tests.
