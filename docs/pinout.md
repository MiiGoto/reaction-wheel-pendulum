# MCU and connector pin allocation — Task 3

STM32G431RBT6 / LQFP64. Physical numbers from DS12589 Figure 10 / Table 12, functions from Table 13. `used` is wired now; `reserved` and `free` have explicit no-connect marks in this schematic. Implemented interfaces are marked used; external module compatibility is conditional on the connector contracts below.

| MCU Pin | Peripheral | Signal | Destination | Status | Reason |
| --- | --- | --- | --- | --- | --- |
| 1 / VBAT | Power | +3V3 | Rail / C8 | used | no backup battery |
| 2 / PC13 | GPIO | — | Unconnected | free | extension margin |
| 3 / PC14 | RCC | LSE_IN | Future clock | reserved | clock reserve |
| 4 / PC15 | RCC | LSE_OUT | Future clock | reserved | clock reserve |
| 5 / PF0 | RCC | HSE_IN | Future clock | reserved | FDCAN clock upgrade |
| 6 / PF1 | RCC | HSE_OUT | Future clock | reserved | FDCAN clock upgrade |
| 7 / PG10 | Reset | NRST | C13 / J2.5 / TP5 | used | NRST_MODE=3 |
| 8 / PC0 | ADC12_IN6 | ADC_AUX1 | Future measurement | reserved | analog range/filter TBD |
| 9 / PC1 | ADC12_IN7 | ADC_AUX2 | Future measurement | reserved | analog range/filter TBD |
| 10 / PC2 | GPIO | CAN_STB | U3.8 / R4 | used | high=standby, default high |
| 11 / PC3 | GPIO / EXTI | ENC_Z | J5.5 / R13 | used | optional wheel index |
| 12 / PA0 | TIM2_CH1 AF1 | ENC_PEND_A | Future encoder | reserved | quadrature pair |
| 13 / PA1 | TIM2_CH2 AF1 | ENC_PEND_B | Future encoder | reserved | quadrature pair |
| 14 / PA2 | USART2_TX AF7 | ESC_UART_TX | R28 / J6.5 | used | optional ESC UART; protocol TBD |
| 15 / VSS | Power | GND | Ground | used | all supply returns |
| 16 / VDD | Power | +3V3 | Rail / local 100nF | used | all VDD pins |
| 17 / PA3 | USART2_RX AF7 | ESC_UART_RX | R29 / J6.6 | used | separate from debug UART |
| 18 / PA4 | GPIO | IMU_CS_N | U4.12 / R6 | used | software CS; default high |
| 19 / PA5 | SPI1_SCK AF5 | IMU_SCK | U4.13 | used | mode3 idle high |
| 20 / PA6 | SPI1_MISO AF5 | IMU_MISO | U4.1 | used | 3.3 V data to MCU |
| 21 / PA7 | SPI1_MOSI AF5 | IMU_MOSI | U4.14 | used | 3.3 V data to sensor |
| 22 / PC4 | GPIO / EXTI | IMU_INT1 | U4.4 / TP12 | used | active-high push-pull IRQ |
| 23 / PC5 | GPIO | ESC_ENABLE | U5.1 / R21 / J6.2 | used | default low; gates PWM |
| 24 / PB0 | GPIO / EXTI | ESC_FAULT_N | R24 / J6.3 | used | active-low external open-drain |
| 25 / PB1 | GPIO | ARM_BUTTON | Future UI | reserved | not independent safety isolation |
| 26 / PB2 | GPIO | STATUS_LED | Future UI | reserved | separate from power LED |
| 27 / VSSA | Analog power | GND | Analog return | used | no separate VREF- pad |
| 28 / VREF+ | Reference | +3V3 | C11/C12 | used | VREFBUF disabled |
| 29 / VDDA | Analog power | +3V3 | C9/C10 | used | direct common rail |
| 30 / PB10 | GPIO | — | Unconnected | free | extension margin |
| 31 / VSS | Power | GND | Ground | used | all supply returns |
| 32 / VDD | Power | +3V3 | Rail / local 100nF | used | all VDD pins |
| 33 / PB11 | GPIO | — | Unconnected | free | extension margin |
| 34 / PB12 | GPIO | — | Unconnected | free | extension margin |
| 35 / PB13 | GPIO | — | Unconnected | free | extension margin |
| 36 / PB14 | GPIO | — | Unconnected | free | extension margin |
| 37 / PB15 | GPIO | — | Unconnected | free | extension margin |
| 38 / PC6 | GPIO | — | Unconnected | free | extension margin |
| 39 / PC7 | GPIO | — | Unconnected | free | extension margin |
| 40 / PC8 | GPIO | — | Unconnected | free | extension margin |
| 41 / PC9 | GPIO | — | Unconnected | free | extension margin |
| 42 / PA8 | TIM1_CH1 AF6 | MOTOR_PWM | U5.2 | used | 3.3 V gated command; frequency TBD |
| 43 / PA9 | USART1_TX AF7 | UART_TX | R25 / J7.1 | used | PC adapter debug TX |
| 44 / PA10 | USART1_RX AF7 | UART_RX | R26 / J7.2 | used | PC adapter debug RX |
| 45 / PA11 | FDCAN1_RX AF9 | FDCAN_RX | U3.4 / TP10 | used | USB shares pins; not implemented |
| 46 / PA12 | FDCAN1_TX AF9 | FDCAN_TX | U3.1 / TP9 | used | CAN recessive default |
| 47 / VSS | Power | GND | Ground | used | all supply returns |
| 48 / VDD | Power | +3V3 | Rail / local 100nF | used | all VDD pins |
| 49 / PA13 | SWD AF0 | SWDIO | J2.2 | used | retain debug |
| 50 / PA14 | SWD AF0 | SWCLK | J2.4 | used | retain debug |
| 51 / PA15 | I2C1_SCL AF4 | I2C_AUX_SCL | Future I2C | reserved | corrects invalid PB6 reservation; SWD retained |
| 52 / PC10 | GPIO | — | Unconnected | free | extension margin |
| 53 / PC11 | GPIO | — | Unconnected | free | extension margin |
| 54 / PC12 | GPIO | — | Unconnected | free | extension margin |
| 55 / PD2 | GPIO | — | Unconnected | free | extension margin |
| 56 / PB3 | Trace AF0 | SWO | J2.6 | used | optional trace fitted |
| 57 / PB4 | TIM3_CH1 AF2 | ENC_A | R11 / J5.3 | used | wheel quadrature; disable UCPD dead-battery first |
| 58 / PB5 | TIM3_CH2 AF2 | ENC_B | R12 / J5.4 | used | same encoder timer |
| 59 / PB6 | GPIO | — | Unconnected | free | PB6 has no I2C1_SCL in DS12589 |
| 60 / PB7 | I2C1_SDA AF4 | I2C_AUX_SDA | Future I2C | reserved | pair with PA15; NC now |
| 61 / PB8 | BOOT | BOOT0 | R1 / TP6 | used | normal flash configuration |
| 62 / PB9 | GPIO | — | Unconnected | free | extension margin |
| 63 / VSS | Power | GND | Ground | used | all supply returns |
| 64 / VDD | Power | +3V3 | Rail / local 100nF | used | all VDD pins |

Physical pins: **35 used, 12 reserved, 17 free**. All64 accounted for. PA2/PA3, PC2/PC3 were previously free; no power/debug/BOOT pin reassignment.

## SWD connector J2

Custom 1x6 2.54 mm vertical header, **not ARM 10-pin compatible**. Pin 1 square pad; number sequentially down header. PCB silk is planned, not yet drawn.

| J2 pin | Signal | MCU / rail | Use |
| --- | --- | --- | --- |
| 1 | VTref | +3V3 | ST-LINK voltage sense only, never supply target here |
| 2 | SWDIO | PA13 / 49 | bidirectional debug |
| 3 | GND | Ground | common reference |
| 4 | SWCLK | PA14 / 50 | clock from probe |
| 5 | NRST | PG10 / 7 | reset from probe |
| 6 | SWO | PB3 / 56 | optional trace to probe |

J1: pin 1 +5V_IN, pin 2 GND. TP1 GND / TP2 input / TP3 protected input / TP4 +3V3 / TP5 NRST / TP6 BOOT0.

## Reservation review limits

TIM2 is reserved for pendulum AB, TIM3 for wheel AB, TIM1 for one PWM; no timer pair is shared. I2C1 (PA15/PB7), SPI1, USART1/2 and FDCAN1 do not collide with implemented SWD/reset/BOOT pins. ADC12_IN6/7 is not an AF selection. PA11/12 USB conflicts with the FDCAN reservation and needs a subsequent pin-plan revision if selected. PB8 is kept for BOOT in this revision. DMA/DMAMUX, interrupts, actual sensor/ESC levels, peripheral setup and CubeMX simultaneous allocation remain TBD. Task 3 uses SPI1 IMU, TIM3 encoder, TIM1 PWM, USART1 debug, USART2 optional ESC, FDCAN1. TIM2 pendulum encoder remains reserved. HSI16 CAN timing tolerance needs measurement / potential HSE upgrade before a guaranteed CAN FD bitrate.

## Task 3 connector contracts

Directions are relative to this controller. All headers are prototype 2.54mm vertical, pin1 square, sequential numbering. Final keyed cable housings and silk remain a PCB review item. +3V3 on J5 is a supply, not a 5V-tolerant input. No port assumes MCU 5V tolerance. Disconnect controller/ESC power before cabling.

| Connector | Pin | Signal | Voltage | Direction | Note |
| --- | --- | --- | --- | --- | --- |
| J3 CAN | 1 | CANH | differential CAN, not TTL | bidirectional | U3.7 / D3.1 / TP7 |
| J3 | 2 | CANL | differential CAN, not TTL | bidirectional | U3.6 / D3.2 / TP8 |
| J3 | 3 | GND | 0V | reference | no motor return or bus supply |
| J4 TERM | 1 | CAN_TERM | CAN bus | passive | R3 lower end |
| J4 | 2 | CANL | CAN bus | passive | shunt fitted=120ohm ON; absent=OFF |
| J5 Encoder | 1 | +3V3 | 3.3V supply | output | external module <=20mA; not separately fused |
| J5 | 2 | GND | 0V | reference | controller-powered module only |
| J5 | 3 | ENC_A_EXT | 0..3.3V | input | push-pull ABI A ->100ohm->PB4 |
| J5 | 4 | ENC_B_EXT | 0..3.3V | input | push-pull ABI B ->100ohm->PB5 |
| J5 | 5 | ENC_Z_EXT | 0..3.3V | input | optional push-pull index ->PC3; unused leave open |
| J6 ESC | 1 | ESC_PWM | 0..3.3V | output | gated PA8, 100ohm, default low |
| J6 | 2 | ESC_EN_OUT | 0..3.3V | output | active-high, default low; controller logic only |
| J6 | 3 | ESC_FAULT_EXT_N | 0..3.3V | input | active-low open-drain, board 10k pull-up |
| J6 | 4 | GND | 0V | reference | no power/current path for motor |
| J6 | 5 | ESC_TX_EXT | 0..3.3V | output | USART2 TX -> ESC RX; optional |
| J6 | 6 | ESC_RX_EXT | 0..3.3V | input | USART2 RX <- ESC TX; optional |
| J7 DEBUG | 1 | UART_TX_EXT | 0..3.3V | output | USART1 TX -> USB-UART RX |
| J7 | 2 | UART_RX_EXT | 0..3.3V | input | USART1 RX <- USB-UART TX |
| J7 | 3 | GND | 0V | reference | no adapter power pin; not RS-232 |

TP7 CANH, TP8 CANL, TP9 FDCAN_TX, TP10 FDCAN_RX, TP11 IMU_CS_N, TP12 IMU_INT1, TP13 ENC_A, TP14 ENC_B, TP15 ESC_PWM, TP16 ESC_EN_OUT. Probe SPI SCK/MOSI/MISO at U4/R7–R9 and UART/fault/index at headers; no redundant pads added.

B-G431B-ESC1 conditional adapter: J6.1 -> board J3.4 PWM and J6.4 -> board J3.5 GND (UM2516). J6.2/.3 do **not** map to documented generic enable/fault pins on that board. Do not join BEC +5V to controller rails. Board UART adapter/cable numbering is TBD pending actual revision and schematic check; no speculative assignment.
