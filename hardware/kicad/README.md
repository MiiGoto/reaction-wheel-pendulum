# reaction_wheel_controller

KiCad 10.0.6で `reaction_wheel_controller.kicad_pro` を開く。9.0.4も環境調査で見つかったが、今回は10.0.6を検証対象とする。

`reaction_wheel_controller.kicad_sch` は矩形・文字・破線の概念図。電気的symbol、net、footprint、PCBはない。全13ブロックを配置し、Power → protection → regulation → MCU、およびsensor → MCU → ESC interface → external ESC/BLDC/wheelの関係を整理している。

SWD、UART、CAN/FDCAN、IMU、encoder、LEDs、buttons、test pointsの境界も示す。信号方式、電源、部品、値、physical pin番号はTBD。破線は電気配線ではない。

```powershell
kicad-cli sch erc --severity-all --exit-code-violations --format json -o outputs/initial-erc.json reaction_wheel_controller.kicad_sch
kicad-cli sch export svg -o outputs/svg/ reaction_wheel_controller.kicad_sch
```

PATHにCLIがない場合はインストール先の `bin/kicad-cli.exe` をフルパスで呼ぶ。生成物・backup・lock・user設定はignored。新規生成後にnative parser/export/ERCを実行済み。検証結果の範囲は `../../docs/validation.md` を参照。
