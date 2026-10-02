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

## Validated source SHA256

```text
reaction_wheel_controller.kicad_sch
ff4426d8ec1548a288f97964ef6f0d839b755667b9a65d90777f06bf1accabb8

reaction_wheel_controller.kicad_pro
e2ffee8faa5aa9ddeb898359a70e3ef065406705cf6465623fd94f6c4529c3c9
```

## Limits

**ERC 0件は完成回路の合格ではない。** この回路図にはsymbols・電源net・AF割当・footprintsがなく、電圧/電流/部品/実配線の安全性を検証していない。回路部品を追加するごとに資料/物理pin reviewとERCを再実行し、PCB作成後にDRCを行う。意図的なwarning除外はない。
