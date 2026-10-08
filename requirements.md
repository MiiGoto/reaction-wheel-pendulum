# Initial requirements

## Requested detailed Cubli Rev A — superseding provisional target identity

2026-10-08: confirmed user target is three independently driven wheels, edge
and point balancing, self-righting, momentum saturation handling and future yaw
rotation. Retain one-axis assets. The requested output is constrained Inventor
parts/assembly, qualified interfaces, native mass/inertia, interference and
motion review, drawings/BOM/manufacturing exports. The present31solid envelope
assembly does not meet that requirement. Safe maximum RPM, capture/disturbance
criteria, brake duty/contact conditions and power source remain TBD. Stop
before detailed manufacture dimensions when actuator/retention/mounting/power
gates fail; do not buy, order or energize. Current gate is failed/open, with
motor alternatives and force/energy calculations in docs/cubli_reva_design_gate.md.

## Historical provisional expansion — superseded target identity

従来1軸のF-01等は中間試作で保持。3軸要求は追加候補で、参考Xの機体同一性/性能を未確認のため確定しない。候補:3独立reaction wheelsで辺/点倒立、段階的self-righting、正負torqueとmomentum/thermal/regen監視、guard/impact安全性。3軸のcapture域・外乱・保持時間・安全RPM・self-righting成功基準はTBD。1軸の過去受入値を無条件に3軸へ流用しない。180mmcube/90gannulus/24V/1.2kgはscreening仮定で購入/製造仕様ではない。docs/design_direction.md、motor_selection.md、validation_plan.mdを参照。

状態: 初期版。Mustは要求、Candidateは候補、TBDは未決。数値のない項目はまだ受入判定できないため、実回路設計・実機評価前に基準を確定する。

| ID | Category | Requirement / status | Verification / open criterion |
| --- | --- | --- | --- |
| F-01 | Functional requirements | Must: 1自由度の姿勢とホイール運動を観測し、BLDCの反作用で姿勢を制御する | 治具付き実機。許容姿勢誤差・保持時間・外乱TBD |
| F-02 | Functional requirements | Must: IMU、振子角、ホイール角/速度を時刻付きで取得 | 静的校正、既知角度・速度、同期誤差TBD |
| F-03 | Functional requirements | Must: 固定周期の制御と飽和監視を実装 | WCET、jitter、sample period、遅延予算TBD |
| E-01 | Electrical requirements | Must: 電源入力、保護、電圧変換、電流予算を定義 | 入力範囲・連続/peak電流・ripple・温度TBD |
| E-02 | Electrical requirements | Candidate: 3.3 V logicと必要に応じ5 V補助rail | 部品仕様、startup、負荷・降圧損失試験 |
| E-03 | Electrical requirements | Must: ESC powerとlogic powerの分岐・GND・回生・逆流を検討 | ESC資料、電源吸収能力、配線レビュー |
| E-04 | Electrical requirements | Must: ESD・逆接・過電流・外部信号levelを確認 | 保護部品/定格TBD、回路レビュー・低energy試験 |
| M-01 | Mechanical constraints | Candidate: 振子約220 mm、wheel径約130 mm、質量約90 g | 基準寸法・材料・形状・許容差・balanceTBD |
| M-02 | Mechanical constraints | Must: 重心、慣性、摩擦、固定方法を記録 | CAD/実測/同定。支点・wheel軸の定義 |
| M-03 | Mechanical constraints | Must: ガード・固定治具・可動域制限を設ける | 最大rpm・保存energy・耐荷重・clearanceTBD |
| C-01 | Communication | Must: CAN/FDCAN controllerと外付けtransceiverを検討 | classic/FD、bitrate、電圧、終端・bus-off復帰TBD |
| C-02 | Communication | Must: UART loggingとSWDを使用可能にする | logic level、baud、connector、debug adapterTBD |
| C-03 | Communication | TBD: USB採用 | native USBのピン競合、clock、外付けadapterとの比較 |
| S-01 | Sensors | Must: IMU、振子角、wheel角/速度の仕様を定義 | range・分解能・帯域・遅延・校正・axis/signTBD |
| S-02 | Sensors | Candidate: AS5600、I2C/SPI/ABZ等 | 候補ごとの公式資料と最大wheel速度を比較 |
| S-03 | Sensors | Must: 欠測・古い値・不整合を検出 | age limit・異常threshold・fault injectionTBD |
| MO-01 | Motor interface | Must: 初期構成は外部ESC/B-G431B-ESC1を優先 | ボードrevision、motor適合、電源・connection確認 |
| MO-02 | Motor interface | Must: 正負トルク・回生・速度飽和を評価 | 電流/トルクcommandの可否・latency・braking試験 |
| MO-03 | Motor interface | TBD: PWM、UARTまたはCAN command | pulse幅/rate、protocol、timeout、enable、fault signal |
| D-01 | Debug interface | Must: SWDIO、SWCLK、NRST、VTref、GNDを設ける | debug/programming・reset・recover試験 |
| D-02 | Debug interface | Must: BOOT、clock、ログUART、test pointを検討 | option bytes、起動mode、probe接続、pin conflict確認 |
| SA-01 | Safety | Must: 電源投入/reset/通信切断時に意図しない始動を防ぐ | explicit arm、watchdog、timeout、故障注入 |
| SA-02 | Safety | Must: 手動電源遮断とmotor limitを設ける | speed/current/温度limit、遮断後回生処理TBD |
| SA-03 | Safety | Must: fault後は原因確認と明示操作で復帰 | 自動再始動を禁止。disable/coast/brake方針TBD |
| T-01 | Testability | Must: 電源・GND・reset・bus・motor interfaceを観測可能にする | test point、logging、scopeアクセスレビュー |
| T-02 | Testability | Must: schematic ERC、PCB DRC、段階bring-upを実施 | 全severity報告を確認。PCB作成まではDRC N/A |
| T-03 | Testability | Must: パラメータ・firmware・配線・試験条件を追跡 | run metadataとcommit ID、公開ログの匿名化 |
| X-01 | Future expansion | Target: PID、state feedback、LQR、swing-up、estimation、identification、sim2real | modelと実機の比較。性能基準TBD |
| X-02 | Future expansion | Candidate: センサ/通信/モータ制御のcustom PCB統合 | 初期評価後にscopeを決定。power stage別review |

## 実回路への移行条件

O-01～O-04を整理し、電圧/電流/インターフェース/必要I/Oを確定する。公式資料とpin/footprintを照合し、受入基準を設定してから部品と値を回路図へ追加する。一般的なESCの速度指令が双方向トルク指令として使えるとは仮定しない。

## Task 2 control-board baseline

この限定範囲はMCU・電源・SWDのみ。下記は初号機の設計条件であり、全システムの電源・安全・通信要求を確定したものではない。

| ID | Baseline | Verification / status |
| --- | --- | --- |
| E-01-T2 | 外部安定化5 V、J1で4.8–5.25 V、短いbench配線。モータbattery直結禁止 | 人間による電源適合確認・実測TBD |
| E-02-T2 | AP2112K-3.3、3.3 V load budget <=100 mA、室温bench。各railをprobe可能にする | datasheet/headroom/熱見積り確認、負荷・ripple・温度実測TBD |
| E-04-T2 | SS14直列逆接保護。給電元を<=150 mA current limitとする | fuse/TVSなし。hot-plug/surge/長ケーブル保証なし |
| D-01-T2 | 1x6 SWD header、VTref sense/SWDIO/GND/SWCLK/NRST/SWO | schematic/netlist確認。ST-LINK adapter接続試験TBD |
| D-02-T2 | HSI16、NRST 100 nF、BOOT0 10k pulldown、normal-flash option-byte確認 | firmware/option-byte設定は未実施 |
| T-02-T2 | 全severity ERC 0/0、全MCU physical pinとLDO pinoutを照合 | 結果はdocs/validation.md。PCBなし、DRC対象外 |

MCU基本回路のみの移行条件はTask 2の公式資料・pinout・限定電源条件で満たす。O-01～O-04の全システム移行条件はCAN/センサ/ESC回路・motor通電前に引き続き適用する。

## Task 3 interface baseline / superseding power limits

Task2 table is historical for MCU-only loading. Current E-02 budget180mA at3.3V, room-temperature bench, E-04 supply current limit220mA. Input4.8–5.25V and all Task2 circuits remain. Controller assumptions explicitly accepted by user; unidentified encoder/ESC compatibility is not confirmed.

| ID | Implemented requirement | Acceptance / open constraint |
| --- | --- | --- |
| C-01-T3 | TCAN3413DR FD-capable3.3V,120ohm shunt-selectable, CAN TVS,3wire connector | both physical ends terminated; bitrate/HSI/cable/common-ground test TBD |
| C-02-T3 | USART1 TX/RX/GND debug3.3V TTL; optionalUSART2 ESC | adapter/baud/protocol TBD; no5V/RS232 or adapter backfeed |
| S-01-T3 | LSM6DSLTR four-wire SPI1,INT1,local decoupling | WHO_AM_I0x6A; ODR/filter age/calibration/frame/axes acceptance TBD |
| S-02-T3 | external3.3V push-pull ABI wheel port <=20mA,TIM3 A/B,PC3 index | module not fixed; maximumRPM/PPR/bandwidth/alignment must be verified |
| MO-03-T3 | gated3.3V PWM,active-high enable,active-low open-drain fault,optionalUART | external device must satisfy contract; reverse torque/timeout/regeneration remain TBD |
| SA-01-T3 | reset outputs EN/PWM low, no motor power on controller | physical ESC behavior, fault-wire loss and independent isolation not validated |
| T-01-T3 | CAN/IRQ/ABI/PWM/EN probe pads; remaining buses accessible at parts/headers | scope frequency/ground technique and physical access review before PCB |
| T-02-T3 | native ERC + full new/preserved netlist cross-check | one intentional SDX/GND warning documented; no exclusions; noPCB/DRC |

O-01/O-02/O-04 motor/sensor system requirements remain gates before powered operation. Pendulum angle sensor remains reserved and unimplemented; IMU alone is not assumed to replace it.

## Task 4 preliminary PCB constraints — 2026-10-03

- Board90x70mm is placement feasibility only, final mechanical envelope TBD. Four3.2mm M3 NPTH, hole centers5mm from edge,4mm radius screw/spacer reserve, actual mounting hardware TBD.
- Four copper layers planned;1.6mm nominal thickness placeholder, supplier stackup/copper/impedance TBD. All top components, probe/rework/header access must survive enclosure assembly.
- General track/clearance0.20mm; POWER0.50mm,CAN0.25mm; through-via0.60/0.30mm; copper-edge0.50mm. Only U4 internal pad clearance0.15mm for its native LGA geometry, supplier qualification required.
- No motor current path on this controller. Reset low ESC gating does not ensure SWD halt stop or broken-fault-wire detection; independent motor power isolation/actual ESC timeout/arming qualification before motor tests.
- IMU native axes/position relative to pivot, connector keying/mating height, exact passive/connector MPNs and assembly/stencil remain TBD. Unrouted baseline DRC is not manufacturing acceptance.

## Task 5 routing acceptance

User approved90x70mm/fourholes/connector placement for routing. Prototype routing acceptance now met: DRC0Errors/0Warnings/0unrouted/0parity, ERC0Errors/1intentionalWarning; no rule relaxation. All electrical assignment unchanged. Official IMU figure verified and native axes shown; mechanical transform/sign calibration remains TBD.

This does not satisfy manufacturing or powered-system acceptance: exact BOM/stackup/assembly, actual external device compatibility, thermal/EMI/timing and safety tests remain required. See docs/task5_routing_review.md and docs/bringup.md. Historical Task2–4 loading/check results above are not current PCB status.
