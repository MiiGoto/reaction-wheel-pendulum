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
