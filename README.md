# reaction-wheel-pendulum

最新方針（2026-10-08）: [1軸を保持して3軸へ発展する案B](docs/design_direction.md)を暫定第一候補にしました。指定X機体の同一性は未確認。GB54直結の自力起き上がりは仮定付き角運動量screeningで不適合。新しい[Inventor配置概念/STEP](mechanical/cubli_concept/README.md)と固定支点simulationを追加しましたが、製作可能な機構・実機性能・起き上がりは未完成です。[検証計画](docs/validation_plan.md)を参照してください。既存1軸native設計と未コミット変更は元checkoutに保持。

以下は既存1軸PCBの基準。機構・motor・driverの採用確定を意味しません。

1自由度リアクションホイール型倒立振子を製作し、制御モデルと実機の対応を検証する開発プロジェクトです。回路、STM32ファームウェア、シミュレーション、機構、試験記録を一つのGit repositoryで管理します。

## Project overview / System concept

BLDCでホイールを加減速し、その反作用で振子の姿勢を制御します。IMU、振子角度、ホイール角度・速度を取得し、PCでログを収集します。寸法目安は振子長約220 mm、ホイール径約130 mm、ホイール質量候補約90 gです。重心・慣性・最大速度・必要トルクは未決です。

## Hardware

制御基板MCUはSTM32G431RBT6（LQFP64、128 KB Flash / 32 KB RAM）を採用。NucleoとB-G431B-ESC1を評価候補とし、初期試作では外部ESCを優先します。Task 2では安定化5 V入力、AP2112K-3.3 LDO、MCU基本回路とSWDを実装。Task 3ではTCAN3413DR CAN FD、LSM6DSLTR SPI、外付け3.3 V ABI Encoder、外部ESC PWM/ENABLE/FAULT、UART接続を追加。Encoder/ESCの型番、最高RPM、モータ電源は未決です。

KiCad 10.0.6で `hardware/kicad/reaction_wheel_controller.kicad_pro` を開きます。rootは概念ブロックの概要、階層sheetはMCU/電源/SWD、CAN/IMU、Encoder/ESC、UARTに分割した実回路です。Task 4で90×70 mm・4層・4点M3固定穴の暫定PCB配置を追加しました。Task 5で全ネットの配線とprototype範囲のPCBレビューを完了しました。DRC Error0／Warning0／未配線0。製造承認・実機検証は未実施です。ERCの合格は実回路の正しさを意味しません。

## Firmware

`firmware/stm32/` は評価方針と要件を保管します。ターゲット・ESC通信方式の決定後にCubeMX/CubeIDEプロジェクトを作成します。まだ実行可能なファームウェアはありません。

## Simulation

`simulation/` はモデル仕様の初期整理です。実測または根拠のあるパラメータを登録した後、非線形モデル、線形化、PID、状態フィードバック、LQR、swing-up、推定、同定、sim2realへ進みます。現時点で制御性能は検証されていません。

## Repository structure

```text
hardware/kicad/   KiCad project, concept overview, MCU/power/SWD and interface schematics
firmware/stm32/   Firmware scope and future STM32 project
simulation/      Model and parameter requirements
mechanical/      Geometry, inertia and fixture requirements
docs/            Architecture, pin needs, power, bring-up, evidence
test/            Verification plan
```

最初に [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md)、[requirements.md](requirements.md)、[AGENTS.md](AGENTS.md) を読んでください。環境調査は [docs/environment.md](docs/environment.md)、資料確認状態は [docs/sources.md](docs/sources.md) に記録します。

## Current status

Task5の配線・prototype範囲のレビューを完了しました。KiCad10.0.6のDRC Error0／Warning0／未配線0／回路図等価性問題0、ERC Error0／意図的Warning1。90×70mm・4層、548配線segment・155via、全部品配置と電気pin assignmentを保持しています。

[最新routing review](docs/task5_routing_review.md)、[current checkpoint](docs/task5_routing_checkpoint.md)、[検証記録](docs/validation.md)。実際のESC／Encoder、最終BOM・製造stackup・実装・安全性・熱・EMIの確認は未完了です。製造データ・注文・firmware・通電試験・Task6は未実施です。

## Roadmap

1. 機構パラメータ、電源、BLDC、双方向トルクを扱えるESCと制御指令仕様を確定。
2. 評価ボードでセンサ取得、安全停止、PC logging、モータ単体評価。
3. 必要I/Oを確定し、MCU型番・packageと物理ピン番号を公式資料・CubeMXで照合。
4. 電源・MCU・デバッグの回路を段階的に作成し、毎回ERCを実行。
5. CAN・センサ・ESC接続を追加し、要求追跡とレビューを実施。
6. シミュレーションと同定により制御を検証し、安全治具で実機評価。
7. 回路承認後にPCB設計・DRC・製造レビューへ進む。

## Publication and license

公開ファイルは本プロジェクト用の文書・設計です。回路図内のKiCad標準symbolは[ライブラリの設計成果物例外](https://www.kicad.org/libraries/license/)を確認済みです。ベンダーのPDF、SDK、HAL、独立した第三者ライブラリ集、ツールの実行ファイルは含めません。プロジェクトのライセンス選択はTBDです。公開されていること自体は第三者コードの利用許諾を意味しません。
