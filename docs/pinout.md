# MCU pin requirements and provisional allocation

## Selection status

STM32G431は第一候補。正確なordering code・package・物理pin番号はTBD。I/O要件の確定前にLQFP48/64等を固定しない。以下は**需要表**であり、PCB配線やfirmwareの確定pin mapではない。

公式DS12589のpin definition/alternate function表、RM0440のdevice feature tableとencoder interface modeを部分確認済み。boot/clock/全register設定を含む詳細reviewは未完了で、実回路前に両資料の対象仕様と選定packageを照合する。確認状態は [sources.md](sources.md) を参照。

## Pin allocation table

| MCU pin | Peripheral | Signal | Destination | Reason |
| --- | --- | --- | --- | --- |
| TBD (physical) | VDD/VSS | 3.3 V candidate / GND | Power regulation | 全電源pinとdecouplingをpackage選定後に確認 |
| TBD (physical) | VDDA/VSSA/VREF+/VBAT | Analog/reference/backup supply | Analog supply tree | 供給方式・未使用時の処理は公式仕様で確認 |
| PA13 / physical TBD | SWD | SWDIO | Debug connector | 書込み・debug用。GPIO用途に割り当てない |
| PA14 / physical TBD | SWD | SWCLK | Debug connector | debugアクセスを維持 |
| NRST / physical TBD | Reset | NRST | Debug connector / reset button | 書込み復旧とreset試験 |
| PB8-BOOT0 / physical TBD | Boot / GPIO | BOOT0 | Boot configuration / test access | option bytesと起動条件を確認。他busとの競合を避ける |
| TBD (two pins) | RCC | HSE_IN / HSE_OUT | Optional clock circuit | FDCAN等のclock精度を評価し外部clockの要否を決定 |
| TBD (two pins if needed) | RCC | LSE_IN / LSE_OUT | Optional low-speed clock | RTC/timekeeping要件TBD。不要なら割当しない |
| TBD (two pins) | USART/UART | DEBUG_TX / DEBUG_RX | PC USB-UART adapter | SWDと別の診断経路。signal levelとbaudはTBD |
| TBD (two pins) | FDCAN1 | CAN_TX / CAN_RX | External CAN transceiver | MCU controllerだけではCANH/CANLを直接駆動できない |
| TBD (one GPIO if needed) | GPIO | CAN_STB / EN | Transceiver | selected partのenable/fault仕様に依存 |
| TBD (two pins) | I2C | SCL / SDA | IMU / absolute angle candidates | アドレス衝突・帯域・pullup・bus lengthを確認 |
| TBD (three pins + CS per device) | SPI | SCK / MISO / MOSI / CS | IMU / encoder alternatives | I2C代替。I2CとSPIを両方必須と決めない |
| TBD (one per device) | GPIO / EXTI | IMU_DRDY / SENSOR_IRQ | Sensor | 取得時刻と同期。DMA/interrupt routingも確認 |
| TBD (two pins + optional Z) | Encoder-capable timer | PEND_A / PEND_B / optional INDEX | Pendulum encoder alternative | timerのCH1/CH2 pair。sensor方式次第で不要 |
| TBD (two pins + optional Z) | Separate encoder-capable timer | WHEEL_A / WHEEL_B / optional INDEX | Wheel encoder alternative | 同時計数。速度・分解能に対する入力rateとcounter幅確認 |
| TBD (one pin if PWM used) | PWM-capable timer | ESC_COMMAND | External ESC | pulse方式・frequency・resolutionはESC資料に依存 |
| TBD (two pins if serial used) | Separate USART/UART | ESC_TX / ESC_RX | External ESC alternative | debug UARTとの同時利用が可能か確認 |
| TBD (two GPIO candidates) | GPIO / EXTI | ESC_ENABLE / ESC_FAULT | ESC if supported | 起動時disable、fault検出。実在signalを資料で確認 |
| TBD (one per analog channel) | ADC | VIN_SENSE / TEMP / optional current | Measurement circuits TBD | input range、source impedance、sampling time、analog filter確認 |
| TBD (two GPIO candidates) | GPIO | STATUS_LED / ARM_BUTTON | UI | user操作と状態表示。安全遮断をbutton GPIOのみに依存しない |
| TBD (two pins, optional) | USB | DM / DP | Optional USB connector | CAN/SWD/UART/PWMとのAF競合をpackageごとに確認 |
| No external pin required | Basic timer / SysTick | CONTROL_TICK | Control scheduler | encoder/PWM timerと独立した固定周期を検討 |

## I/O budget (assumption)

同時需要の見積り例: SWD 2、UART debug 2、FDCAN 2、I2C 2、SPI 3+CS 1、DRDY 1、二つのAB encoder 4、ESC PWM 1、enable/fault 2、ADC 2、UI 2 = **24 GPIO**。これは比較用に代替方式も併記した保守的な案で、確定需要ではない。

NRST、BOOT、HSE 2、LSE 2、USB 2、CAN standby、encoder index、別ESC UARTなどの追加需要と全電源pinを別途評価する。48/64 pin候補での実際のbonding・AF競合・ADC選択を比較してからpackageを決める。ピン数だけで採用しない。

## Before freezing allocation

1. IMU/二つのencoder/ESCの方式を決め、同時使用するsignalsを選ぶ。
2. DS12589 Table 12 (pin definition)、Table 13 (AF) の対象package列で物理番号・AF・voltage toleranceを照合。
3. RM0440でtimer encoder mode、PWM、ADC、DMA/DMAMUX、I2C/SPI/USART、FDCAN clock、boot/option bytesを確認。
4. CubeMXで全機能を同時に配置して競合・clock・DMAを確認し、`.ioc`を保存。
5. Nucleo/ESC側pin使用と照合。KiCad symbolとfootprintのpin番号・orientationを別に確認。
6. 表を実際の `GPIO / physical pin / AF` へ更新し、資料・review結果を記録する。
