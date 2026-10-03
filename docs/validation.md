# Initial KiCad validation

実行日: 2026-10-02 18:27 JST。KiCad CLI 10.0.6。

| Check | Result | Scope |
| --- | --- | --- |
| Native schematic parser / SVG export | exit 0、SVG生成成功 | 新規 `.kicad_sch` の読込・図面出力 |
| ERC (all severities) | exit 0、errors 0、warnings 0、exclusions 0 | 部品・電気netのない概念図 |
| Ignored ERC rules | 0 | 標準設定でignoredだった4種をwarningへ設定 |
| Project JSON | 構文確認、ERCでprojectルール反映を確認 | `.kicad_pro` 初期構成 |
| Visual review | PNGへrenderして確認済み | 全ブロック/文字/タイトル枠の重なりを修正し再確認 |
| PCB DRC | N/A | PCBファイル未作成 |
| Firmware build / hardware test | 未実施 | target/source/実回路未作成 |

## Reproduce from repository root

```powershell
kicad-cli sch erc --severity-all --exit-code-violations --format json -o hardware/kicad/outputs/initial-erc.json hardware/kicad/reaction_wheel_controller.kicad_sch
kicad-cli sch export svg -o hardware/kicad/outputs/svg/ hardware/kicad/reaction_wheel_controller.kicad_sch
```

PATH未登録の場合はインストール先のCLIをフルパスで使用する。reportは `$schema: https://schemas.kicad.org/erc.v1.json`、included severitiesはerror/warning/exclusion、`ignored_checks: []`、root sheetの `violations: []` を確認済み。CLIの日本語保存メッセージに「DRC」と出るが、実際に行ったのは `sch erc` であり、PCB DRCではない。

生レポート・SVG・preview PNGは `hardware/kicad/outputs/` にあり、生成物としてGit追跡対象外。

## Task 1 validated source SHA256 (historical)

```text
reaction_wheel_controller.kicad_sch
ff4426d8ec1548a288f97964ef6f0d839b755667b9a65d90777f06bf1accabb8

reaction_wheel_controller.kicad_pro
e2ffee8faa5aa9ddeb898359a70e3ef065406705cf6465623fd94f6c4529c3c9
```

## Task 1 limits (historical)

**ERC 0件は完成回路の合格ではない。** この回路図にはsymbols・電源net・AF割当・footprintsがなく、電圧/電流/部品/実配線の安全性を検証していない。回路部品を追加するごとに資料/物理pin reviewとERCを再実行し、PCB作成後にDRCを行う。意図的なwarning除外はない。

## Task 2 MCU / power / SWD validation — 2026-10-02

KiCad10.0.6 native schematic parser, two-sheet SVG export and KiCad XML netlist export passed. Final all-severity ERC: **Errors0 / Warnings0 / Exclusions0 / Ignored checks: None**, exit0. Report path `hardware/kicad/outputs/task2/erc.rpt` is intentionally ignored; the complete final summary is:

```text
Report includes: Errors, Warnings, Exclusions
Sheet /                         no messages
Sheet /MCU POWER SWD/           no messages
ERC messages: 0  Errors 0  Warnings 0
Ignored checks: None
```

Reproduce from repository root with installed KiCad CLI:

```powershell
kicad-cli sch erc --severity-all --exit-code-violations --output hardware/kicad/outputs/task2/erc.rpt hardware/kicad/reaction_wheel_controller.kicad_sch
kicad-cli sch export netlist --format kicadxml --output hardware/kicad/outputs/task2/netlist.xml hardware/kicad/reaction_wheel_controller.kicad_sch
kicad-cli sch export svg --output hardware/kicad/outputs/task2/ hardware/kicad/reaction_wheel_controller.kicad_sch
```

Ensure output directory exists first; use the installed CLI's absolute path if it is absent from PATH. No global PATH change was made.

Independent cross-checks: DS12589 LQFP64 physical map versus resolved standard symbol **64/64 match**; all64 pins accounted (17used,26reserved,21free). Native XML verified every implemented U1 power/reset/SWD/BOOT pin, U2 1VIN/2GND/3EN/4NC/5OUT, J1/J2 pinout, D1/D2 polarity, R1/R2 and all13 capacitor connections. Remaining MCU pins are physically NC. Footprint pad count/pitch/pin1 orientation verified for LQFP64/SOT25/SMA/0805 LED/debug header. Ceramic capacitors are non-polarized. No external clock fitted. Physical definitions were separately compared with datasheets; ERC cannot validate ordering-code selection.

Visual review: rendered both native SVG pages to PNG; checked hierarchy, MCU labels, power/decoupling/reset/BOOT/SWD/indicator/probe grouping. Label alignment and title-block clearance corrected. No peripheral interface beyond this scope, no PCB, no DRC, no firmware or physical measurements. Zero ERC is schematic connectivity validation only, not manufacturing or electrical-performance approval.

Validated primary-file SHA256:
- `reaction_wheel_controller.kicad_sch`: `dd4f0c6b13738b5a284c19c06aec189cd0c93755a733b1e2642264909a611458`
- `mcu_power_swd.kicad_sch`: `d5324fdd7098aac2c133b82a741a608af91464afc869caeb0ca1b45fdcfd42a6`
- `reaction_wheel_controller.kicad_pro`: `5ca29a6e5faf34205469db95e0d0c058c8554f3bf0c78b19a8ad6dc867b3045b`

## Task 3 final validation — 2026-10-02

Base `a77dee8` (Task2 not merged into main), branch `feature/interfaces-sensors`. KiCad10.0.6 native ERC with **all severity**, no exclusions/ignored checks: **Error0 / Warning1**, CLI exit5 because the intentional warning remains visible. It is not an all-green exit0 result. SDX is grounded exactly as ST LSM6DSL §7.1 requires for an unused auxiliary bus; explanation in design_notes.md. NoPCB/DRC or firmware/physical test.

```text
Sheet /                  no messages
Sheet /MCU POWER SWD/     no messages
Sheet /CAN IMU/
[pin_to_pin] warning: U4.2 SDX (Bidirectional) -> GND #FLG02 (Power output)
Sheet /ENCODER ESC/       no messages
Sheet /UART/             no messages
ERC messages:1 Errors0 Warnings1
Ignored checks:None
```

Reproduce after creating `hardware/kicad/outputs/task3/`:

```powershell
kicad-cli sch erc --severity-all --exit-code-violations --output hardware/kicad/outputs/task3/erc.rpt hardware/kicad/reaction_wheel_controller.kicad_sch
kicad-cli sch export netlist --format kicadxml --output hardware/kicad/outputs/task3/netlist.xml hardware/kicad/reaction_wheel_controller.kicad_sch
kicad-cli sch export svg --output hardware/kicad/outputs/task3/ hardware/kicad/reaction_wheel_controller.kicad_sch
```

Native XML independently checked all new connected component pins and all64 U1 pins:35used,12reserved,17free. Preserved U2 power/EN, all13 prior capacitors, SWD/reset/BOOT and rail nets; linked +3V3/GND across sheets. Verified U3 all8 official pins, TVS1H/2L/3GND,120ohm+J4 series termination, U4 full14-pin map (6/7 stacked GND,9/10/11NC), SPI connections, TIM3 ABI+PC3 index, U5 OE/A/Y/VCC/GND, default pulls, J3–J7 signal order, series resistors and UART cross-sheet continuity. MCU AF plan rechecked against DS12589; PB6 false reservation corrected to PA15 without moving connected pins. Logical review covered reset defaults, open fault-wire limitations, logic references and external-device voltage contracts. No 5V-tolerance shortcut, unnecessary NoERC or disconnected-but-used signal.

Footprint pad counts/numbers/order/pitch: SOIC8 (1.27mm), SOT23(3), SOT23-5(5), LGA14(0.5mm), no exposed/central extra pad. Original custom symbols matched the project-local library in native ERC. Standard cached symbol pin names/numbers compared to manufacturer tables. Native SVGs rendered and visually reviewed for all5 pages; power-label rotation, component reference clearance and A3 overview hierarchy corrected. PCB orientation/axes, solder/paste and real connector keying remain human review gates.

Initial ERC had0errors/3warnings:2 local/global power label naming warnings corrected by making common rail labels consistently global. One intentional SDX warning remains; no repeated attempts to hide it. Report/export images/netlist stay ignored under outputs. Publication checks examine staged files/history for credentials, personal/non-public data, binaries/third-party content and broken document links; vendor files/tool binaries excluded.

Validated source SHA256:
- `reaction_wheel_controller.kicad_sch`: `cf63191d80b73b6f0aca1115e3e4a188e9273959d80975163d2542797726bbfd`
- `mcu_power_swd.kicad_sch`: `95121839df55a0a4d6b6d534f677bf558cc88d5a4b73fe96eea38d87f9774df6`
- `can_imu.kicad_sch`: `9382cc5126a209855c3391e811d487ae0704b3f184b65925abc2543e7b504114`
- `encoder_esc.kicad_sch`: `9e375abe3bf05172b123201e2c05a97c43f4ba6993e31e65eb6e3f6369accdb3`
- `uart_interfaces.kicad_sch`: `49be91342c4a911e477873a35d964da86ceb9ff81111ee2e1bfb34d5941e9b98`
- `rwp_interfaces.kicad_sym`: `ee484b067c763b17b49c608470ba0d68151c124793324e265a915f07d077c9ea`
- `sym-lib-table`: `9badf35df2adc37dd17b40410c4c925b6be1224a0d817eff3d2b856d543362ee`
- `reaction_wheel_controller.kicad_pro`: `30270bb33d13d7de6a1b42568ec290d565c1b0eaa5489de47c3f03d0a6ed6e78`

## Task 4 final validation — 2026-10-03

KiCad10.0.6 native CLI, final all-severity ERC: **Error0 / Warning1**, exit5 for visible intentional U4 SDX-ground type warning. No exclusions, NoERC markers or ignored checks. Native PCB DRC with schematic parity: **0physical violations,0parity issues,173unconnected items**; exit5 because unrouted items remain. No routing to clear those items. Baseline is not fabrication approval.

Native schematic XML vs PCB independently checked every connected physical pad.86footprints,4copperlayers,0tracks/vias,0zones. Mounted-hole symbols and16test-pad BOM exclusions now match schematic/PCB. Native footprints match installed libraries; no courtyard/pad short/clearance/silk violations remain. Initial placement overlaps/legends were corrected; IMU0.15mm internal pad gap has an explicit justified local rule.

Read-only native pad distances and original selected-airwire review support placement feasibility; native SVG and local3D top rendering visually reviewed.3D IMU/header models missing, so connector housing/height and native IMU axes need human review. No physical hardware tests, return-loop routing, final planes, final DRC closure, Gerbers or BOM ordering.

Reproduce (create ignored output folder first):

```powershell
kicad-cli sch erc --severity-all --exit-code-violations --output hardware/kicad/outputs/task4/erc.rpt hardware/kicad/reaction_wheel_controller.kicad_sch
kicad-cli sch export netlist --format kicadxml --output hardware/kicad/outputs/task4/netlist.xml hardware/kicad/reaction_wheel_controller.kicad_sch
kicad-cli pcb drc --schematic-parity --severity-all --exit-code-violations --format json --output hardware/kicad/outputs/task4/drc_final.json hardware/kicad/reaction_wheel_controller.kicad_pcb
```

Reports/temporary PNG/3D are ignored under outputs. Published SVG/CSV review artifacts are project-original, no vendor PDFs/models/tools copied. Publication audit checks staged files and reachable history for credentials/private keys/local PC secrets/personal information and local links.

Task4 validated source SHA256:

- `reaction_wheel_controller.kicad_sch`: `2f66de22c669626a202b91802ec765303255b1f45f492840096e2e9396be2121`
- `mcu_power_swd.kicad_sch`: `c8160fba73fed5f125ad53bf448bc42822b512bc4d224271a91b790e55c956ac`
- `can_imu.kicad_sch`: `8d5caeec8840d44874e166b6a836e7ff6a03a08785f6b29a8c6232ddc596bc64`
- `encoder_esc.kicad_sch`: `f1016d4dbbe4229bcf954c48416b852ee4a8ed366572b9dd7d0a8552cacb3f0e`
- `reaction_wheel_controller.kicad_pcb`: `c054036d2c4b3eab9c1d8cd77fbab7e5559ba981cc4ecd77cf8b85d1d5d8bb5e`
- `reaction_wheel_controller.kicad_pro`: `feecf14ada0ca7ed8340619ba5ac35b09e11ee880f10a083ac2d9518b4813c61`
- `reaction_wheel_controller.kicad_dru`: `2597194a4bca9e2f34bac71cd7f5d681ede94ab4daf9add32734efa9e5c735cf`
- `fp-lib-table`: `8190612078a59ec8c5b2027a1b021e0b729aa9685271197d779b9357b0d15179`

## Task 5 power/ground checkpoint — not final routing acceptance

Native KiCad10.0.6, absolute board/project paths, restored Task4 classes/checks plus narrowly justified U1/U4 neck rule. Final power-stage DRC: **73Errors /0Warnings overall**, all73Errors are unconnected items on37distinct signal nets; **0physical-rule violations /0schematic parity issues**. No exclusions/ignored checks. Final all-severity ERC:0Errors/1Warning, same official unused-SDX-to-ground type warning; no schematic electrical changes. Checks do not prove complete routing.

Power5V/protected5V/3V3/GND/LED do not occur in the unconnected list.147tracks/78vias, two refilled copper zones (L2GND/L3+3V3), each one connected polygon;4all-copper rule-area keepouts. All86footprints retained, only C1 rotated180degrees. Physical repairs verified, no rule widening to conceal clearance failures. Straight-loop/plane review covers current power stage only; signal return paths and full mechanical/IMU axes/silkscreen review outstanding.

Native power/ground SVGs visually inspected and original review copies published. Vendor PDF/temporary reports/images remain ignored; failed PDF retrieval not evidence of axis review. No Gerber/drill/PnP/finalBOM/order/firmware/hardware measurements. Earlier unfilled/invalid intermediate checks are not final results.

Reproduce after creating ignored output folder:

```powershell
# Pass absolute paths to the project board and output report.
kicad-cli pcb drc --refill-zones --save-board --schematic-parity --severity-all --exit-code-violations --format json --output <absolute-output>/drc.json <absolute-project>/reaction_wheel_controller.kicad_pcb
kicad-cli sch erc --severity-all --exit-code-violations --output <absolute-output>/erc.rpt <absolute-project>/reaction_wheel_controller.kicad_sch
```

Both violation-checking commands return nonzero while their reported unconnected/intentional warning remains. Inspect the report and ensure project classes/checks survived native save. Task5 routing not complete; Task6 not entered.

Task5 source SHA256:
- `reaction_wheel_controller.kicad_pcb`: `bc91bb2bb896b2814d012d3cb9cb6b302b9ae27607493e950abc491588d2c8ff`
- `reaction_wheel_controller.kicad_pro`: `f73c222c6cb4dbafcb44ea111dfe846ec9f0b3b416c2ca0ca39970168cc3976e`
- `reaction_wheel_controller.kicad_dru`: `84937101d07bf79b12adb07b2f9045fad0bf693af1e4cb08060eb2edd6cb5bd2`
