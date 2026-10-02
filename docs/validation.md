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
