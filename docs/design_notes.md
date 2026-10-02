# Design notes and decisions

## 2026-10-02: initial scope

**確定**: 一つのrepositoryでhardware/firmware/simulation/mechanical/docs/testを管理。今回の停止地点は初期構築。

**候補**: STM32G431、外部ESC/B-G431B-ESC1、3.3 V logic、補助5 V、AS5600。exact part/package、motor、sensor、bus方式は未選定。

**判断理由**: モータ・機構・正負トルク・センサ遅延が未確定のため、power stageや最終MCU pin配置の作り込みを先行しない。

## KiCad initialization

新規の `.kicad_pro` と `.kicad_sch` を作成。回路図の矩形・文字・破線は概念ブロックで、接続netや部品ではない。既存のKiCadファイルは編集していない。新規ファイルもnative CLIで読み込み、SVG出力とERCを検証する。

ブロック: Power input、input protection、5 V/3.3 V regulation、STM32G431、SWD、UART debug、CAN/FDCAN、IMU、encoder interface、motor/ESC interface、LEDs、buttons、test points。

PCBファイルは未作成。board outline・stackup・placement・routing・製造物は未実施。

## ERC warnings

意図的なwarning除外は設定しない。実行結果は `validation.md` に記録する。部品/netがない段階の0件は概念ファイルの初期チェックに過ぎず、電源/通信/実装の安全性検証ではない。次にsymbolsを追加した時点で改めて全severityのERCを実行する。

## Open design issues

通常のhobby ESCの速度commandだけで倒立制御の必要な正負トルク・低速応答を満たせるかは未確認。ホイールの速度飽和、回生、command timeout、sensorlessの低速挙動を評価する。AS5600をホイール高速測定に使えるとも仮定しない。

## 2026-10-02: Task 2 MCU / power / SWD

### Confirmed selection and package verification

- U1: **STM32G431RBT6**、LQFP64、10x10 mm body、0.5 mm pitch、64 lead、exposed padなし。Flash 128 KB、SRAM 22 KB + CCM SRAM 10 KB。ordering codeはDS12589 Table 101で照合。
- LQFP48 STM32G431CBT6も候補だが追加GPIO・clock・将来I/Oの余裕を優先しLQFP64を採用。BGA/QFNよりleadを目視でき、手実装・修理が容易。LQFP80/100は今回不要。
- KiCad 10.0.6 `MCU_ST_STM32G4:STM32G431RBTx` を使用。aliasの親symbolを解決して全64 physical pinをDS12589 Figure 10/Table 12のLQFP64列と照合。**64/64一致**。PG10はpin 7のNRST機能として使用し、BOOT0はPB8 pin 61。全番号はpinout表に記録。
- `Package_QFP:LQFP-64_10x10mm_P0.5mm`: 64 pad、pitch 0.5、pin 1はtop view左辺上端（角印）、番号は反時計回り、EPなし。DS12589 §6.5の10 mm body/12 mm lead spanと照合。padはleadの外側へ伸びるsolder landでありbody寸法と同一ではない。PCB設計時に採用実部品のdrawingと再照合する。
- 予約済み機能は同時使用可能なGPIOへ配置。PA13/14とPB3をdebug用に維持。PA11/12はFDCANの予約で、USBも同じpairを使うため同時使用には再割当が必要。CubeMX/DMA/clock詳細は後続タスク。

### MCU supplies and analog strategy

VDD 16/32/48/64、VBAT 1、VDDA 29、VREF+ 28を+3V3へ直結。VSS 15/31/47/63、VSSA 27をGNDへ接続。専用VREF-は外部padなし（内部でVSSAへbond）。VCAP/VDDIO2はこのpackageにないため追加しない。

DS12589 Figure 16のdevice-specific値を採用: VDD各100 nF + bulk 4.7 uF、VDDA 10 nF + 1 uF、VREF+ 100 nF + 1 uF。AN5093の一般例（bulk 10 uF / VDDA 100 nF）との値の違いはdevice datasheetを優先する。VBATはbattery未使用として100 nFを追加（AN5093 §2.1.3）。全capacitorは無極性ceramic。

初号機はVDDA/VREF+を同じ3.3 Vに直結しferrite/RC/LCは追加しない。AN5093 Table 10はferriteをoptionalとし直結を許容する。VDD/VDDAの起動差を作らず簡単に実装できる。ADC絶対精度はLDO ripple・基準誤差・ground returnの影響を受けるため未保証。**VREFBUFは無効/high impedanceのまま**（外部railへdriveしない）。精度要求と実測noiseに応じ将来見直す。

### Clock / reset / boot

- 外部HSE/LSEなし。内部HSI16と必要に応じPLLを使用する方針。初期起動・SWDには十分でcrystal/load-cap選定を省ける。制御周期、UART baud、FDCANのbit timingと温度範囲は未検証。将来FDCAN導入前にclock toleranceを評価し必要ならPF0/PF1にHSE追加。PC14/15もLSE予備として予約。USB clock対応を保証しない。
- NRST: MCU内部pull-up + C13 100 nF（AN5093 §2.2.3）、J2 pin 5からST-LINK reset、TP5で測定。external pull-up/reset buttonは初号機に追加しない。NRST_MODE=3（reset I/O default）を維持しPG10 GPIOへの変更を禁止。
- BOOT0: R1 10k pulldown、TP6でアクセス。通常flash起動の設定はnSWBOOT0=0/nBOOT0=1をbring-upで確認する。hardware pulldownはpin-controlled boot時にもlowを保つ。未書込flashのempty-checkによるsystem bootloader移行は故障ではない。実際のoption bytesは未設定。nBOOT1/BOOT_LOCK/RDPを不用意に変更しない。

### Power selection / protection / thermal assumptions

- 外部安定化5 V入力を採用、**J1実測4.8–5.25 V**、benchで供給側current limit <=150 mA。モータpower stageは分離、battery電圧は未確定のまま。
- U2 **AP2112K-3.3TRG1** / SOT25（SOT-23-5）、device rating 600 mAだがboard初期load budgetは**100 mA**。MCP1700級低電流LDOやbuckも比較対象とし、手実装できる5-lead package、簡単なEN接続、1 uF ceramicで安定するAP2112を採用。buckの効率は高いが100 mA初期条件には部品・switching noise・配線負担が増える。調達在庫は未確認。
- 公式AP2112 pinoutとKiCadを照合: 1 VIN、2 GND、3 EN、4 NC、5 VOUT。ENはVINへ直結、NCはno-connect。標準footprint SOT-23-5、5 pad、0.95 mm pitch、EPなし。top view pin 1左上/2左中央/3左下/4右下/5右上。
- D1 **Vishay SS14-E3/61T**、SMA/DO-214AC。anode pad 2=+5V_IN、cathode pad 1=+5V_PROTECTED。datasheet VF max 0.5 V @1 Aを保守的headroom計算に使用: 4.8−0.5=4.3 V、3.3 Vに1.0 V margin。AP2112 max dropout 0.4 V @600 mA以下。保護後VINは6 V recommended maximum以下とする。
- 最悪5.25 V、diode dropをゼロとしてLDO loss=(5.25−3.3)*0.1≈0.195 W。datasheet SOT25 thetaJA 184 °C/Wからrise≈36 °C（reference PCB依存）。室温25 °Cで約61 °Cの見積り。高温・600 mA・実PCB温度を保証する値ではなく、負荷追加時に再予算化する。
- C1/C2 nominal 4.7 uF /10 V/X7R/0805を使用。AP2112指定のeffective >=1 uFをDC bias・tolerance・温度込みで満たす実MPNを調達時に確認する。4.7 uF nominalだけでは条件充足を保証しない。
- 直列Schottkyで逆接対策を行う。current-limited short bench supply前提のためpolyfuse/TVSは追加しない。長い配線、motor rail、surge/ESD/独立電源からのbackfeedは未対策。VTrefから給電しない。電源未投入時にSWD信号をdriveしてphantom powerを起こさない。

### Debug, indicator and test access

J2はcustom 1x6/2.54 mm header。ARM 10-pin/1.27 mmはcompactで標準adapter向きだが、初号機はST-LINK個別wire接続が容易な2.54 mmを採用。標準ARM cableを直接挿すものではない。pinoutはdocs/pinout.md。SWOをPB3から追加。SWDIO/SWCLKは内蔵pullを使用（AN5093 §6.4）、external pullなし。PCBシルクに1/VTref/IO/GND/CLK/RST/SWOを明記する予定。

D2はKingbright **APT2012SECK** orange 0805。pad 1 cathode=GND、pad 2 anode=LED_A。R2 2.2kで、datasheet Vf typical 2.1 V（20 mAでの値）を参考とすると(3.3−2.1)/2200≈0.55 mA。低電流のVfは未保証なのでbrightnessは実測する。保守的Vf=0、rail上限3.3495 V・抵抗1%下限2178 ohmでも約1.54 mA、抵抗loss約5.2 mW以下（0.125 W級で十分）。

TP1 GND、TP2 input、TP3 protected input、TP4 +3V3（VDDA/VREFと同rail）、TP5 NRST、TP6 BOOT0。SWDIO/SWCLKはJ2でprobe可能。TestPoint_Pad_D1.5mmはprobe padで部品不要。

### Validation and unresolved issues

既存overviewは図形UUIDを保存して階層sheetを追加。標準symbolの継承を解決し、native parser/netlist/SVG/ERCで検証してから記録する。最初のERCのpower-output競合と重複stacked-pin wire warningは修正済み。意図的warning、exclusion、ignored checkは**なし**。最終結果はvalidation.md。

未決: actual passives/headers MPN、調達在庫、全load budget、PCB熱/ADC品質、ST-LINK adapter実配線、clock精度、CubeMX/DMA、silicon revisionに対応するerrata、option bytes実設定。Task 3前に人間が電源条件、SWD pinout、MCU/package、予約pinとCAN/USB競合をreviewする。PCB/routing/DRC/firmwareは今回実施しない。

### Errata review supplement

ES0431 Rev9 System limitations were checked for this circuit. SWD is used instead of full JTAG, and HSE-bypass/LSE are absent. For §2.2.6 backup-domain power-reset limitation, the initial bench power-cycle procedure requires both VDD and VBAT to fall below100 mV for >200 ms before reapplying power; otherwise a documented software backup-domain reset is required. The circuit alone cannot guarantee this discharge condition. Future firmware must handle reset/startup and revision-specific errata; these are not covered by ERC.

## Task 3 interfaces — 2026-10-02

Task2 branch was not merged into main. `feature/interfaces-sensors` is based on `a77dee8`; all implemented MCU/power/SWD connections retained. No power stage, PCB or firmware added. User confirmed RPM/encoder/ESC remain unknown and approved the external 3.3V ABI / PWM+active-high ENABLE+active-low open-drain FAULT connector contracts. These are controller specifications, not verified properties of an unidentified external device.

### AF correction and pin conflict review

DS12589 Table13 shows **PB6 has no I2C1_SCL**; Task2's reserved PB6/SCL entry was wrong. Impact: reservation/documentation only, pin was NC. Minimal fix: move reserved SCL to PA15 AF4, keep PB7 SDA AF4; PB6 free. Alternatives PB8/SCL would conflict with BOOT; PA13/SCL would conflict with SWD. No connected pin moved. SPI1 PA5/6/7 AF5 plus PA4 GPIO CS; FDCAN1 PA11/12 AF9; wheel TIM3 PB4/5 AF2; ESC TIM1 PA8 AF6; USART1 PA9/10 AF7; optional USART2 PA2/3 AF7 are separate. PC2 standby/PC3 index newly used. PB4's UCPD1_CC2 dead-battery behavior must be disabled per RM0440 before encoder input use; full JTAG is not enabled. Pin count:35used/12reserved/17free. CubeMX/DMA/interrupt co-allocation remains a firmware gate.

### CAN selection / termination / protection

| Candidate | Logic / supply / package | Decision |
| --- | --- | --- |
| TI TCAN334G | single3.3V, FD5Mbps, SOIC8, ±14V bus fault | simpler but insufficient margin with selected 24V TVS clamp |
| **TI TCAN3413DR** | VCC3.0–3.6V, VIO1.7–3.6V, SOIC8 D, ±58V fault, ±30V receiver common-mode | selected: VCC and VIO both3.3V, robust robot CAN |

Classical CAN and FD supported; TI describes certified EMC up to5Mbps and possible8Mbps in simpler networks. This board's bitrate remains TBD pending topology, cable, HSI16 tolerance and measurement; no8Mbps guarantee. TI ordering table lists TCAN3413DR active; distributor stock/pricing not verified. U3:1TXD,2GND,3VCC,4RXD,5VIO,6CANL,7CANH,8STB. STB high standby, R4=10k up; firmware pulls low only after initialization. R5=10k TXD up keeps recessive at reset. C14/C15=100nF each near corresponding supply pin (§8.4).

R3=120ohm1%, >=0.25W1206 with J4 shunt in series between CANH/CANL. 120ohm matches nominal twisted-pair characteristic impedance; fit only at the two physical bus ends to reduce reflections. Two ends measure about60ohm bus-wide. Intermediate nodes leave shunt absent (default OFF); permanently enabled termination would overload multi-node buses. At3.6V differential, dissipation=3.6²/120=0.108W, below0.25W; transient/thermal qualification remains physical testing.

D3=Nexperia PESD2CANFD24V-T, dual **bidirectional** CAN FD TVS, SOT23. Pins1 K1 CANH,2 K2 CANL,3 CC GND. 24V stand-off, typical6pF; specified maximum42V clamp at1A8/20us gives16V static margin to U3 ±58V absolute limit at that test condition. This does not guarantee higher-energy pulses or PCB overshoot. Place by J3 with short low-inductance GND path. No common-mode choke initially: short internal harness, no measured EMC need; avoid unqualified resonance/extra assembly. Revisit after noise/ESD tests. Neither isolation nor 24V CAN bus power interface provided.

### IMU selection / SPI / axes

| Candidate | Interface / ODR / ranges | Noise / buffering / package / availability |
| --- | --- | --- |
| **LSM6DSLTR** | SPI up to10MHz, I2C400kHz; accel/gyro up to6.664kHz; gyro±125..2000dps; accel±2/4/8/16g | gyro4mdps/sqrtHz, accel80ug/sqrtHz at2g typical;4KB FIFO,2INT; LGA14 3x2.5mm; ST active; selected |
| LSM6DSO | SPI/I2C/I3C, high-rate6-axis and same useful full-scale class | gyro3.8mdps/sqrtHz typical, larger FIFO; LGA14 same assembly class; current official datasheet/product, stock TBD; not needed for first prototype |

DSL selected for documented mature interface and sufficient rate; FIFO/noise/interrupt capability is not a measured control-loop result. IC is reflow LGA, **not** easy through-hole hand soldering; contract assembly or qualified reflow required. ST active-product status is not a purchasing guarantee. Choose four-wire SPI1 for deterministic burst access and bandwidth; a13-byte burst at8MHz takes13us wire time versus roughly0.3ms at400k I2C. Transaction setup, sensor filtering/group delay and ISR age are additional. Start1MHz mode3; final ODR/control rate TBD (1.666kHz is a planning point, not a requirement). IRQ INT1 active-high push-pull; disable unused INT2/DEN and sensor-hub functions. WHO_AM_I0x0F expected0x6A; use software reset, no external reset pin exists.

U4 pin1=SDO/MISO (not a strapped I2C address in SPI),2SDX and3SCX tied GND per ST §7.1 unused auxiliary-bus requirement;4INT1;5VDDIO;6/7GND;8VDD;9INT2/DEN NC;10/11NC unconnected but pads soldered;12CS;13SPC/SCK;14SDI/MOSI. VDD/VDDIO=3.3V within1.71–3.6V /1.62–3.6V ranges. C16/C17=100nF at each supply. R6=10k CS up; R7=100k SCK up (mode3 idle); R8/R9=100k MOSI/MISO down; R10=100k IRQ down at power-on. Input voltages must not exceed VDDIO+0.3V; no5V signals.

Placement constraints only: rigid mounting, low board strain, consider center near mounting datum; away from motor vibration, high-current returns and switching regulators. No placement performed. Define board frame +X toward right of board drawing, +Y upward, +Z out of component face (right handed); retain sensor-native X/Y/Z per DS Fig1. The final rotation matrix to pendulum/mechanical frame is **TBD** until board/mechanical orientation is chosen. PCB silk must show native sensor axes and pin1; physical axis/sign calibration and rotation review mandatory before manufacture/control. Do not silently equate the drawing frame with die axes.

### Encoder selection / speed requirements

| Candidate | Resolution / acquisition | Suitability / limits |
| --- | --- | --- |
| AS5600 |12bit, I2C/PWM/analog; sampling150us; slow-filter settling about2.2..0.286ms | no ABI; latency/wrap tracking need RPM budget; not automatically selected |
| AS5047P-class external ABI module |14bit SPI /12bit ABI, official selector max28000RPM, typical15mA | ABI timer avoids repeated serial polling; suitable candidate, **IC/module not fixed** |

Official AS5047P selector and indexed DS checked; full current DS URL failed to open. Air-gap, magnet/alignment tolerances, module supply strapping and actual logic outputs have not been verified, so no AS5047P IC circuit is placed. Candidate magnetic encoders require diametrically magnetized on-axis magnet and qualified field/alignment; AS5047P indexed field range35–70mT, mechanical gap depends on magnet and cannot be invented. Hall/ESC speed feedback has lower/unknown resolution and protocol/latency, so not the default measurement path. RPM/PPR and mechanical wheel safety remain TBD, confirmed by user.

Selected implemented **interface** is external board-powered3.3V push-pull A/B/Z, J5 with <=20mA port budget. R11–R13=100ohm series, R14–R16=100k down for defined disconnected levels; C18=100nF+C19=1uF local port supply. No5V, RS422 differential or open-drain module accepted without redesign. TIM3 encoder mode TI1/TI2 and PC3 index; signed count/overflow handling are future firmware. No RC on edges; timer digital-filter settings must preserve rate. `edge_rate=4*PPR*RPM/60` where PPR means cycles/channel/rev:4096counts/rev at28000RPM would be1.91MHz edges, not a tested capability. Actual module/cable/rate/filter must be verified before operation. Pendulum angle sensor remains unimplemented on reserved TIM2.

### ESC / UART / startup contract

Generic external ESC only:3.3V PWM, active-high enable, active-low open-drain fault, common logic ground, optional USART2. Motor power is separate. PWM rate/pulse encoding/direction/torque command/timeout are TBD. U5=SN74LVC1G126DBVR non-inverting **logic buffer**, not a gate driver:1OE,2A,3GND,4Y,5VCC3.3V; C20=100nF. R19=10k OE down; R20=100k PWM input down; OE0 gives high impedance, R18=10k on J6.1 holds PWM low. R17=100ohm series. Enable output R21=100ohm+R22=10k down. Reset drives neither command nor enable high; partial-power-down Ioff supported by U5. This defaults the controller outputs low, **does not prove the unknown ESC stops** or supply independent power isolation.

Fault R23=10k up3.3V at port, R24=100ohm intoPB0. External open-drain low means fault; disconnected wire reads inactive high, so this is not a broken-wire-safe safety channel. Require device communication/health checks before arming; no combinational FAULT-to-OE kill path and no firmware implemented. Reverse-torque/coast/brake, power-off behavior, regeneration and an independent manual motor isolation must be reviewed with actual ESC. OptionalUART2 idle TX R31=10k up, RX R30=100k up, R28/29=100ohm; do not enable until protocol/arming behavior known. Headers are exposed logic interfaces, not qualified ESD-isolated field ports.

B-G431B-ESC1 UM2516: board J3.4 accepts PWM3.3/5V, J3.5 GND. Its own CAN J1 and UART are alternative firmware-controlled paths; termination is board/firmware-dependent. No generic enable/fault interface on J3 is assumed. Example490Hz, Ton1060..1860us speed command requires appropriate MCSDK firmware; board not supplied with turnkey application. It does not establish bidirectional torque or low-speed control suitability. Connect PWM/GND only via reviewed adapter initially; never wire BEC +5V to this3.3V port. Actual board revision/adapter UART pinout remain TBD.

USART1 debug J7=TX,RX,GND,3.3V TTL USB-UART adapter only; R25/R26=100ohm, R27=100k RX up. No adapter power pin, no USB circuitry, no RS232 and no implicit5V-tolerance assumption. Different3-pin header from6-pin SWD; future silk must mark connector name, pin1, direction and voltage.

### Symbol / footprint / logical cross-check

Project-original `RWP:TCAN3413` and `RWP:PESD2CANFD24V-T` symbols have explicit official pin maps above and passive TVS terminals; no guessed alias or modified third-party standalone library. Project-local sym-lib-table uses `${KIPRJMOD}` only. Cached standard LSM6DSL (resolved alias),74LVC1G126 match physical14/5-pin tables. Native XML cross-check covers every new connected component pin, all64 MCU pins and preserved Task2 power/debug/capacitor nets; checks TVS mapping,120ohm shunt series path, SPI, ABI and PWM gate independently of ERC.

Footprints: SOIC8 3.9x4.9mm1.27mm pitch: pin1 upper-left,4 lower-left,5 lower-right,8 upper-right top view; no exposed pad. TVS SOT23 pins1/2 on one side,3 opposite (manufacturer top view). Buffer SOT23-5 pins1/2/3 down left,4/5 opposite. IMU LGA14 3x2.5mm border layout: pin1 left upper;1–4 left,5–7 bottom,8–11 right,12–14 top,0.5mm pitch, no extra central pad. Native installed footprint pads counted8/3/5/14, numbers complete. NC10/11 still soldered. Non-polarized ceramics; header pin1 square. Actual solder-land tolerances/paste/assembly axes are manufacturing-review items, not validated by ERC.

### ERC warnings and remaining gates

Intentional **one** pin_to_pin WARNING: U4.2 SDX (standard symbol bidirectional) tied to GND flagged as connected to power-output #FLG02. ST §7.1 explicitly requires unused SDX/SCX to GND or VDDIO; GND is selected. Do not leave SDX floating merely to clear ERC. No NoERC marker, excluded check or changed rule severity used; power PWR_FLAG is retained for the real supply. U4.9/10/11 NCs reflect disabled output/physicallyNC functions; unused MCU pins alone have NC. Final count in validation.md.

Firmware gates: ES0431 Rev9 SPI §2.14 BSY behavior on disable/slave (use master and bounded completion); FDCAN §2.15 edge filtering desynchronization (disable EFBI) and mixed dedicated/FIFO ordering (choose documented workaround), timer/UART restrictions against purchased REV_ID. No workaround implemented. HSI16 tolerance/FD bitrate, sampling latency, input edge-rate, power temperature and motor disable remain unmeasured. No PCB/DRC/manufacturing approval claimed.
