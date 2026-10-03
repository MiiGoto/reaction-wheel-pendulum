# Initial power tree

状態: ブロック案。部品・電圧範囲・定格・回路値はTBD。

```mermaid
flowchart LR
  Input[Battery / bench supply TBD] --> Protect[Input protection TBD]
  Protect --> Logic[Logic branch regulation TBD]
  Logic --> Aux[5 V optional]
  Logic --> VDD[3.3 V candidate]
  VDD --> MCU[STM32 / sensors / CAN logic]
  Protect --> Cut[Independent motor power isolation]
  Cut --> ESC[External ESC]
  ESC <--> Motor[BLDC / wheel: regenerative energy]
  ESC -. return current .-> Return[Power return topology TBD]
```

| Domain | Candidate | TBD before circuit |
| --- | --- | --- |
| Input | Battery or current-limited bench supply | min/nom/max voltage、polarity、connector、peak current、fuse |
| ESC branch | External power stage | operating range、inrush、bulk capacitance、wire gauge、regen absorption |
| Logic supply | 3.3 V | MCU/sensor/transceiver budgets、ripple、startup、dropout、thermal loss |
| Auxiliary | 5 V if required | required loads、source、level shifting、backfeed prevention |
| Analog | filtered VDDA/reference concept | datasheet supply scheme、ADC accuracy、ground return |
| Debug/PC | VTref or adapter | USB/ESC/bench多重給電・GND loop・逆流・絶縁要否 |

減速時の回生energyは電源を過電圧にする可能性がある。電源が吸収できるとは仮定しない。motor power isolation時のESC残留energyと停止挙動も検討する。GND共通化または絶縁は選定したinterfaceに基づき決定する。

## Task 2 implemented control-board branch

上記は全systemの初期案。以下のみ実回路化した。ESC/battery/回生domainはTBDのまま。

```mermaid
flowchart LR
 J1["J1 external regulated 5 V / 4.8–5.25 V"] --> D1["D1 SS14 reverse protection"]
 D1 --> VIN["+5V_PROTECTED >=4.3 V"]
 VIN --> U2["U2 AP2112K-3.3 / EN tied VIN"]
 U2 --> Rail["+3V3 / Task 3 budget 180 mA"]
 Rail --> VDD["U1 VDD 16/32/48/64 + VBAT 1"]
 Rail --> Analog["VDDA 29 + VREF+ 28 directly tied / VREFBUF off"]
 Rail --> Debug["J2 VTref sense only"]
 Rail --> LED["R2 2.2k + D2 indicator"]
```

| Ref | Value | Purpose / placement for future PCB |
| --- | --- | --- |
| C1 | 4.7 uF 10 V X7R | U2 VIN/GND local input, after D1; effective >=1 uF |
| C2 | 4.7 uF 10 V X7R | U2 VOUT/GND local output stability; effective >=1 uF |
| C3 | 100 nF | U1 VDD16/VSS15 local decoupling |
| C4 | 100 nF | U1 VDD32/VSS31 local decoupling |
| C5 | 100 nF | U1 VDD48/VSS47 local decoupling |
| C6 | 100 nF | U1 VDD64/VSS63 local decoupling |
| C7 | 4.7 uF | U1 VDD bulk near MCU |
| C8 | 100 nF | VBAT1 local supply decoupling, no separate battery |
| C9 / C10 | 10 nF / 1 uF | VDDA29 to VSSA27, DS12589 Figure 16 |
| C11 / C12 | 100 nF / 1 uF | VREF+28 to VSSA27, VREFBUF off |
| C13 | 100 nF | NRST7 to GND, AN5093 recommended external reset capacitor |

All capacitors are non-polarized ceramics. Analog/digital rail is electrically common; keep analog capacitor return paths local at VSSA and away from noisy currents. No PCB placement is performed yet. Practical load allocation: <=70 mA preliminary MCU allowance + <=1.6 mA LED + <=28.4 mA future reserve =100 mA. MCU allowance must be recalculated from actual clock/peripheral mode and datasheet current tables before firmware/high-speed operation. The 600 mA LDO rating is not a board power budget.

TP4 measures the common +3V3/VDDA/VREF rail. Probe pads and J2 do not provide isolation or reverse-current protection. Do not power from J2 VTref; use current-limited J1 supply. See design_notes.md for headroom/thermal calculations and unresolved surge/ESD/backfeed cases.

## Task 3 rail budget (supersedes Task 2's 100mA budget)

J1 remains regulated4.8–5.25V; U2 remains AP2112K-3.3, motor power separate. Proposed room-temperature bench rail budget **<=180mA**, supply current limit **220mA**; this current limit is a test setting, not a board fuse. Preserve1uF-effective minimum for C1/C2 after DC bias. No module supply from ESC BEC/debug adapter.

| Load | Allowance | Basis / limits |
| --- | --- | --- |
| MCU |70mA | preliminary engineering allowance; actual clock/peripherals calculation still required |
| TCAN3413 VCC+VIO |60.3mA | datasheet worst normal dominant with50ohm load60mA +0.3mA VIO |
| LSM6DSL |5mA | conservative engineering allocation, not a datasheet max claim |
| External ABI module |20mA | connector contract; module must be selected within budget |
| LED |1.6mA | prior worst-case allowance |
| Pulls / logic |5mA | engineering allocation, U5 static typ low; dynamic/cable load TBD |
| Remaining margin |18.1mA |180-161.9mA |

Upper conservative LDO dissipation ignoring diode loss: `(5.25-3.3)*0.18=0.351W`; using Task2 datasheet thetaJA184C/W gives64.6C rise, about89.6C junction at25C ambient. This is a preliminary estimate tied to datasheet PCB conditions; actual copper/ambient/cooling not yet specified. Recalculate and measure temperature before a board/load is approved; no600mA board rating. CAN bus-fault current can reach130mA and may trigger bench limit; fault operation is not guaranteed within normal budget.

C14/C15 100nF at U3 VCC3/VIO5; C16/C17 100nF at U4 VDDIO5/VDD8; C18 100nF+C19 1uF at J5 supply; C20 100nF at U5 VCC5. All ceramic non-polarized, with short local ground returns. CAN/ESC are not isolated; logic GND and motor-current return wiring must be reviewed. NoPCB placement is performed. Shared VDDA/VREF+ means CAN/sensor rail noise may affect ADC; confirm ripple and ADC requirement before deciding to add filtering.

## Task 5 power/ground routing checkpoint

Current PCB power nets are routed/plane-connected. C1 same position rotated180degrees; input→D1→C1/U2→C2→3V3. Local MCU/IMU/CAN/buffer capacitors use short plane-access vias, analog rails remain common3V3. In1.Cu continuous GND and In2.Cu+3V3 filled; no analog split or BLDC return.147track segments/78local plane/return vias total,37signal nets still incomplete. Thermal/capacitor-effective-value/backfeed and supplier stackup tests remain TBD;600mA LDO rating is not board budget. This is not a complete/tested PCB.
