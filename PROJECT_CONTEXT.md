# Project context

2026-10-08 detailed Rev A request: SHISEIGYO-3 N1-style three-wheel cube with
self-righting / edge / point balance is now the explicit target. On
feature/cubli-3axis-mechanical-reva, feasibility was reassessed before CAD.
STOP: GB54 does not pass self-righting momentum screening; replacement motor,
brake-loaded separately supported shaft, retention and energy path are not yet
qualified. Candidate 200mm/150g rims and FAULHABER 4221 G 024 BXT H + Micro
are screening options only. Existing Inventor31occurrences are all grounded,
zero assembly constraints, confirmed by native read-only inspection; no
manufacturable Rev A or new drawings/exports are claimed. See
docs/cubli_reva_design_gate.md and mechanical/cubli_reva_review/feasibility.json.
All original one-axis CAD and three user-modified files are preserved.

2026-10-08追記: 1軸資産を保持し、独立3軸Cubli系へ発展する案Bを暫定第一候補とする。参考N1は3モータ/ブレーキ付きと確認、指定X投稿は同一性未確認。180mm直交3軸のnative概念31部品を新規保存、STEP再読込成功。仮定mass1.010461kg、未配置reserve180g込み解析1.190461kg。GB54直結によるself-rightingは仮定180mm/1.2kgの角運動量screenで不足。±1degree固定支点モデル収束は実機合格でない。motor/brake/encoder/source/guard/strength/contactモデルをfreezeせず、購入/製造/通電なし。現行判断はdocs/design_direction.md〜validation_plan.mdを優先。過去の1自由度確定事項は中間試作に引き続き適用し、3軸要求の自動確定ではない。

公開branchは安全な32a3428を基準にfeature/cubli-concept-redesign。旧private native metadataを含むancestorとユーザーの未コミット3filesは元branch27380daで保持。公開nativeファイルは除外し、独自generator/neutral STEP/reportを共有。

更新日: 2026-10-03 (Asia/Tokyo)。状態: Task5配線・prototypeレビュー完了。DRC Error0／Warning0／未配線0。製造未承認・実機未検証。

## 確定事項

- MCU: STM32G431RBT6 / LQFP64 / Flash 128 KB / RAM 32 KBをTask 2で採用。将来I/Oは暫定予約（pinout参照）。

- プロジェクト: 1自由度リアクションホイール型倒立振子。
- STM32系とBLDCを使用。Git/GitHub、KiCad、firmware、simulation、mechanical、docs、testを一つのrepositoryにまとめる。
- IMU、振子角度、リアクションホイール回転角/回転速度を取得する。
- CAN/FDCAN、UART、SWDを使用可能にする。USBの必要性を検討する。
- Task 2のMCU・電源・SWDを保持し、Task 3でTCAN3413DR、LSM6DSLTR SPI、外付け3.3V ABI接続、外部ESC論理接続、UARTを追加。PCBはTask5配線済み。firmware・製造・motor通電は未実施。
- 既存ファイル・ユーザー変更を保存する。資料未確認の回路設計、履歴改変、force push、未検証の完成扱いは禁止。

## 仮定・候補 (設計を固定する根拠ではない)

- 振子長: 約220 mm。支点からどの基準位置までかはTBD。
- ホイール径: 約130 mm、質量候補: 約90 g。材料・厚さ・質量分布・慣性はTBD。
- 現在利用可能な評価環境候補: STM32 Nucleo、B-G431B-ESC1。実物の所持・Nucleo型番・ボードrevision・動作は未確認。
- 初期試作ではパワー段を自作PCBへ統合せず、外部ESCまたはB-G431B-ESC1を優先検討する。
- センサ候補: AS5600。ただし選定確定ではなく、帯域・遅延・分解能・磁石配置・最高回転数を確認する。
- 制御基板の初号機は外部安定化5 V（connectorで4.8–5.25 V）と3.3 V LDO、Task 3出力予算180 mA（室温、bench電源limit220 mA）、室温bench用途を設計仮定とする。モータ用battery電圧はTBD。
- 将来はSTM32 + センサ + 通信 + モータ制御を自作PCBへ統合する可能性がある。初期基板にパワー段を含める決定ではない。

## 未決事項

| ID | 項目 | 決定に必要な情報 |
| --- | --- | --- |
| O-01 | 電源電圧・電流・回生処理 | モータ/ESC選定、トルク、最大回転速度、電源の吸収能力 |
| O-02 | モータ・ESC・指令方式 | 正負トルク、ゼロ付近の制御、遅延、電流/トルク指令、停止挙動 |
| O-03 | 将来pin allocation / clock / DMA | MCU/packageは決定。外部部品選定後に暫定予約とCubeMXを照合 |
| O-04 | センサ取得・角度センサ | IMU IC/SPIは決定。実測遅延・校正・振子角センサ・外付けABI module/最高RPMは未決 |
| O-05 | 制御仕様 | サンプル周期、姿勢誤差、安定化範囲、swing-up条件 |
| O-06 | 機構・治具 | 重心、慣性、摩擦、取付、最大速度、ガード、ストッパ |
| O-07 | 通信・PC logging | CAN classic/FD、速度、ノード、終端、PC変換器、ログ形式 |
| O-08 | USB | native USBまたは外部UART adapterの必要性 |
| O-09 | ライセンス | オリジナル成果物と将来のベンダーコードの条件 |
| O-10 | 安全停止 | disable/coast/brakeの比較、電源遮断、回生、手動再始動条件 |

## 将来目標

PID、状態フィードバック、LQR、swing-up、状態推定、パラメータ同定、PC logging、sim2real。達成済みではない。

## 状態管理

候補は候補のまま記録する。確定時は判断根拠・資料・試験を `docs/design_notes.md` に追記し、関連requirementとpinoutを同じcommitで更新する。

## Task 3 confirmed / assumptions / open items

確定（設計）: TCAN3413DR+PESD2CANFD24V-T、120ohm shunt、LSM6DSLTR SPI1、外付けABI connector、PWM logic gating+EN/FAULT、USART1 debug/optionalUSART2。Task2 branchはmain未mergeのためa77dee8から依存を保持。PB6の誤ったI2C予約をPA15へ訂正。

仮定（ユーザー承認済み）: external module3.3V push-pullABI <=20mA、ESC3.3V PWM/active-highEN/active-lowODFAULT。型番と最高RPMは未定。180mA/220mAは新たな室温bench設計予算で実測未完。

未決: actual encoder/ESC/magnet/RPM/PPR、正負torque/停止/回生、CANbitrate/clock、sensor制御周期/axis mapping、電源熱/EMC/配線/connectorkey、PCB/firmware。ERConewarningはST指定SDX接地によるpin-type warningで抑制なし。Task4への自動移行なし。

## Historical Task4 snapshot — 2026-10-03

確定（設計）: Task3 cc09087からfeature/pcb-placement、Task2/3依存保持、main未変更。回路の電気接続とMCU35used/12reserved/17freeを保持。全86footprints配置、4層、配線/via/zoneなし。ERC0error/1intentional warning、baselineDRC0配置違反/0parity/173未配線。

仮定:90x70mm暫定外形、M3四点/端から5mm/頭部半径4mm、板厚1.6mm、generic2.54header。メーカーstackup/機構/ねじ/ケーブル/IMU姿勢の最終確定ではない。

未決: 実機ESC/encoder/RPM、安全停止/正負トルク/回生、debughalt中出力保持への対策、IMU die-axis mappingと振子機構、0.15mmIMU内部pad間隔/assembly、供給熱/HSI CAN-FD精度、製造会社stackup。Task5へ自動移行しない。

## Historical Task5 power checkpoint — superseded

Confirmed: user approved90x70mm/holes/connectors, authorized Task4 net class/check restoration and delegated IMU orientation. feature/pcb-routing retains Task4 751b09e and prior tasks. Manual power/ground/decoupling stage,147tracks/78vias, filled L2GND/L3+3V3,4mounting keepouts. PhysicalDRC0/parity0; overallDRC73Errors/0Warnings from37unrouted signal nets. ERC0Errors/1intentionalWarning. C1 rotated180degrees, other placements kept.

Assumptions: provisional4layer supplier stackup/1.6mm thickness, existing bench budget180mA, external3.3VABI/ESC contracts. U4 physicalrotation0 retained; native sensor axes not guessed.

TBD/blocker: official IMU Fig1/page18 readable pixels not obtained after bounded attempts; final axes/silk unverified. All signal routing/fullreturnpath/CAN discharge/finalDRC/silkscreen review still outstanding. Task5 not complete, no fabrication outputs/orders/firmware/powered tests; do not enter Task6.

## Historical Task5 stopped draft — superseded

Official LSM6DSL PDF graphical source verified. CAN connected; IMU routed draft still has2MOSI/GND physical errors. Current DRC47Errors/0Warnings,45unconnected items on26nets,0parity; ERC0Errors/1intentionalWarning.318tracks/108vias,90x70mm/4layers, existing placements preserved. Stop after3IMU checks per user limit. Task5 incomplete; see docs/task5_routing_checkpoint.md. Encoder/SWD/UART/ESC routing, full return-path/silk review remain outstanding. No manufacture or powered tests.

## Current Task5 accepted routing scope — supersedes historical checkpoints above

Confirmed: all intended nets connected; nativeDRC0Error/0Warning/0unrouted/0parity, ERC0Error/1intentionalWarning.548segments/155vias,90x70mm/4layers,86footprints unchanged. R0.5 silk/nativeIMUaxes, no manufacturing output or powered verification. See docs/task5_routing_review.md.

Assumptions: supplier-independent4layer concept/1.6mm nominal, bench180mA/220mA limits, external3.3V ABI/ESC contracts. TBD: actual parts/mechanics/encoderRPM/ESC/safe-state, assembly/stackup/thermal/EMI/control performance. Task6 is not authorized by this completion.

## Current one-wheel Inventor CAD — 2026-10-08

Actual2026.2COM native module now exists:36IPTs,104constraints,1groundedframe,7discreteposes/0interference. Wheel151.85g/Jz0.00047409,module892.97g with material proxies and excluded actuator/hardware. PreferredqualificationmotorFAULHABER4221G024BXTH(non-SC),Micro,independent6000bearings and opposeddisc pads. Former3330rpm/1.40kgget-up claim invalidated by actual inertia/mass. Manufacture/powered-test HOLD; see docs/one_wheel_module_review.md. Nativefiles stay local, neutralexports public. Existing1axisCAD preserved.

## Rev B review update — 2026-10-08

Native one-wheel Rev B and three-axis packing IAM created. See docs/cubli_revb_review.md.
Old1.40kg/3330rpm and1.2mm brake travel are historical, not current qualified requirements.
Current modeled shared assembly2.691kg plus150g reserve; self-righting and manufacture HOLD.
No purchase, energized testing or manufacturing release. Existing one-axis and Rev A CAD retained.
