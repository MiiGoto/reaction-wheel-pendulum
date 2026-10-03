# Task 5 power/ground routing checkpoint

**Task5 incomplete; not fabrication-ready.** User approved outline/holes/connectors and restoring Task4 rules. Native explicit manual routing, no autorouter. C1 rotated180degrees at same location to face VIN toward LDO; other placements unchanged.

| Item | Current result |
| --- | --- |
| Size/layers |90x70mm,4layers,4M3NPTH|
| L1 |power/decoupling/local GND only; signal routes pending|
| L2 |one continuous refilledGNDpolygon; no analog split|
| L3 |one refilled+3V3polygon; supplier stackup TBD|
| L4 |signal routing pending|
| Vias |78through-vias0.60/0.30mm, local rail/return access|
| Tracks |147segments, explicit power/ground paths|
| Physical DRC/parity |0/0|
| Overall DRC |73Errors/0Warnings, all unconnected|
| Unrouted |37distinctsignalnets/73items|
| ERC |0Errors/1intentionalST-SDX-groundWarning|

[Power-stage SVG](images/task5-power-stage.svg), [GND plane SVG](images/task5-ground-plane.svg), [manual route record](routing_power_stage.csv). Plane continuity/short local cap returns reviewed for current stage; signal integrity and completed return paths remain outstanding. Four radius4mm mounting keepouts protect metal spacers. Power via/neck clearance issues corrected without relaxing general clearance. Exact capacitor MPN/DCbias, thermal rise, return-current external cabling and stackup remain unqualified.

Source blocker: official ST LSM6DSL Figure1/page18 graphical axes not inspected. urllib and PowerShell PDF downloads timed out, browser PDF blocked-by-client; web text alone cannot establish arrows. Keep verified package pin1/rotation0, do not invent die-axis silk. Stop repeated retrieval under user§46; need accessible official page image/PDF. No statement that manufacturing outputs/fullrouting/physical tests are complete. Task6 not entered.

Remaining signal nets:

- `/CAN IMU/CANH`
- `/CAN IMU/CANL`
- `/CAN IMU/CAN_TERM`
- `/ENCODER ESC/ENC_A_EXT`
- `/ENCODER ESC/ENC_B_EXT`
- `/ENCODER ESC/ENC_Z_EXT`
- `/ENCODER ESC/ESC_EN_OUT`
- `/ENCODER ESC/ESC_FAULT_EXT_N`
- `/ENCODER ESC/ESC_PWM`
- `/ENCODER ESC/ESC_PWM_DRV`
- `/MCU POWER SWD/BOOT0`
- `/MCU POWER SWD/NRST`
- `/MCU POWER SWD/SWCLK`
- `/MCU POWER SWD/SWDIO`
- `/MCU POWER SWD/SWO`
- `CAN_STB`
- `ENC_A`
- `ENC_B`
- `ENC_Z`
- `ESC_ENABLE`
- `ESC_FAULT_N`
- `ESC_RX_EXT`
- `ESC_TX_EXT`
- `ESC_UART_RX`
- `ESC_UART_TX`
- `FDCAN_RX`
- `FDCAN_TX`
- `IMU_CS_N`
- `IMU_INT1`
- `IMU_MISO`
- `IMU_MOSI`
- `IMU_SCK`
- `MOTOR_PWM`
- `UART_RX`
- `UART_RX_EXT`
- `UART_TX`
- `UART_TX_EXT`
