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
