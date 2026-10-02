# reaction-wheel-pendulum

1自由度リアクションホイール型倒立振子を製作し、制御モデルと実機の対応を検証する開発プロジェクトです。回路、STM32ファームウェア、シミュレーション、機構、試験記録を一つのGit repositoryで管理します。

## Project overview / System concept

BLDCでホイールを加減速し、その反作用で振子の姿勢を制御します。IMU、振子角度、ホイール角度・速度を取得し、PCでログを収集します。寸法目安は振子長約220 mm、ホイール径約130 mm、ホイール質量候補約90 gです。重心・慣性・最大速度・必要トルクは未決です。

## Hardware

STM32系、第一候補STM32G431。NucleoとB-G431B-ESC1を評価候補とし、初期試作では外部ESCを優先します。センサ、電源、CANトランシーバ、MCUの正確な型番・packageはTBDです。AS5600は候補に留まります。

KiCad 10.0.6で `hardware/kicad/reaction_wheel_controller.kicad_pro` を開きます。現状の回路図は非電気的なブロック配置と境界の説明のみで、部品・配線・PCBはありません。ERCの合格は実回路の正しさを意味しません。

## Firmware

`firmware/stm32/` は評価方針と要件を保管します。ターゲット・ESC通信方式の決定後にCubeMX/CubeIDEプロジェクトを作成します。まだ実行可能なファームウェアはありません。

## Simulation

`simulation/` はモデル仕様の初期整理です。実測または根拠のあるパラメータを登録した後、非線形モデル、線形化、PID、状態フィードバック、LQR、swing-up、推定、同定、sim2realへ進みます。現時点で制御性能は検証されていません。

## Repository structure

```text
hardware/kicad/   KiCad project and conceptual schematic
firmware/stm32/   Firmware scope and future STM32 project
simulation/      Model and parameter requirements
mechanical/      Geometry, inertia and fixture requirements
docs/            Architecture, pin needs, power, bring-up, evidence
test/            Verification plan
```

最初に [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md)、[requirements.md](requirements.md)、[AGENTS.md](AGENTS.md) を読んでください。環境調査は [docs/environment.md](docs/environment.md)、資料確認状態は [docs/sources.md](docs/sources.md) に記録します。

## Current status

初期構築段階。仕様・ブロック構成・I/O要件を整理しています。部品選定、実回路、実機試験、PCB routing、製造データは未実施です。検証の範囲と結果は [docs/validation.md](docs/validation.md) を参照してください。

## Roadmap

1. 機構パラメータ、電源、BLDC、双方向トルクを扱えるESCと制御指令仕様を確定。
2. 評価ボードでセンサ取得、安全停止、PC logging、モータ単体評価。
3. 必要I/Oを確定し、MCU型番・packageと物理ピン番号を公式資料・CubeMXで照合。
4. 電源・MCU・デバッグの回路を段階的に作成し、毎回ERCを実行。
5. CAN・センサ・ESC接続を追加し、要求追跡とレビューを実施。
6. シミュレーションと同定により制御を検証し、安全治具で実機評価。
7. 回路承認後にPCB設計・DRC・製造レビューへ進む。

## Publication and license

公開ファイルは本プロジェクト用に作成した文書・初期設計のみです。ベンダーのPDF、SDK、HAL、第三者ライブラリ、ツールの実行ファイルは含めません。プロジェクトのライセンス選択はTBDです。公開されていること自体は第三者コードの利用許諾を意味しません。
