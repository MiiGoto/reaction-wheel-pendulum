# Project context

更新日: 2026-10-02 (Asia/Tokyo)。状態: Task 3 CAN・IMU・Encoder/ESC接続・UART回路図、ERC検証済み（Error0 / 意図的Warning1）。

## 確定事項

- MCU: STM32G431RBT6 / LQFP64 / Flash 128 KB / RAM 32 KBをTask 2で採用。将来I/Oは暫定予約（pinout参照）。

- プロジェクト: 1自由度リアクションホイール型倒立振子。
- STM32系とBLDCを使用。Git/GitHub、KiCad、firmware、simulation、mechanical、docs、testを一つのrepositoryにまとめる。
- IMU、振子角度、リアクションホイール回転角/回転速度を取得する。
- CAN/FDCAN、UART、SWDを使用可能にする。USBの必要性を検討する。
- Task 2のMCU・電源・SWDを保持し、Task 3でTCAN3413DR、LSM6DSLTR SPI、外付け3.3V ABI接続、外部ESC論理接続、UARTを追加。PCB・firmware・製造・motor通電は未実施。
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

## Task 4 current state — 2026-10-03

確定（設計）: Task3 cc09087からfeature/pcb-placement、Task2/3依存保持、main未変更。回路の電気接続とMCU35used/12reserved/17freeを保持。全86footprints配置、4層、配線/via/zoneなし。ERC0error/1intentional warning、baselineDRC0配置違反/0parity/173未配線。

仮定:90x70mm暫定外形、M3四点/端から5mm/頭部半径4mm、板厚1.6mm、generic2.54header。メーカーstackup/機構/ねじ/ケーブル/IMU姿勢の最終確定ではない。

未決: 実機ESC/encoder/RPM、安全停止/正負トルク/回生、debughalt中出力保持への対策、IMU die-axis mappingと振子機構、0.15mmIMU内部pad間隔/assembly、供給熱/HSI CAN-FD精度、製造会社stackup。Task5へ自動移行しない。
