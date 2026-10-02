# reaction_wheel_controller

KiCad 10.0.6で `reaction_wheel_controller.kicad_pro` を開く。9.0.4も環境調査で見つかったが、今回は10.0.6を検証対象とする。

`reaction_wheel_controller.kicad_sch` は矩形・文字・破線の概念概要とMCU POWER SWDへの階層リンク。全13ブロックでPower → protection → regulation → MCU、およびsensor → MCU → ESC interface → external ESC/BLDC/wheelの関係を整理している。電気的symbol、net、footprint割当は階層sheetに実装。PCBはない。

SWD、UART、CAN/FDCAN、IMU、encoder、LEDs、buttons、test pointsの境界も示す。MCU・電源・SWDはTask 2で具体化し、その他の周辺回路はTBD。破線は電気配線ではない。

```powershell
kicad-cli sch erc --severity-all --exit-code-violations --format json -o outputs/initial-erc.json reaction_wheel_controller.kicad_sch
kicad-cli sch export svg -o outputs/svg/ reaction_wheel_controller.kicad_sch
```

PATHにCLIがない場合はインストール先の `bin/kicad-cli.exe` をフルパスで呼ぶ。生成物・backup・lock・user設定はignored。新規生成後にnative parser/export/ERCを実行済み。検証結果の範囲は `../../docs/validation.md` を参照。

## Task 2

Open the existing reaction_wheel_controller.kicad_pro, then hierarchical sheet **MCU POWER SWD**. mcu_power_swd.kicad_sch contains the implemented MCU/power/debug circuit; the root remains the whole-system concept overview. Unused/reserved MCU pins are explicitly NC for this stage. No PCB exists. ERC/export instructions and results are recorded in docs/validation.md.
