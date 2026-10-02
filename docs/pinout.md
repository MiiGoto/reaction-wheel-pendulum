# MCU and SWD pin allocation — Task 2

STM32G431RBT6 / LQFP64. Physical numbers from DS12589 Figure 10 / Table 12, functions from Table 13. `used` is wired now; `reserved` and `free` have explicit no-connect marks in this schematic. Reservations are a future plan, not implemented peripheral circuits. Remove NC when connecting in a subsequent task.

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
| 10 / PC2 | GPIO | — | Unconnected | free | extension margin |
| 11 / PC3 | GPIO | — | Unconnected | free | extension margin |
| 12 / PA0 | TIM2_CH1 AF1 | ENC_PEND_A | Future encoder | reserved | quadrature pair |
| 13 / PA1 | TIM2_CH2 AF1 | ENC_PEND_B | Future encoder | reserved | quadrature pair |
| 14 / PA2 | GPIO | — | Unconnected | free | extension margin |
| 15 / VSS | Power | GND | Ground | used | all supply returns |
| 16 / VDD | Power | +3V3 | Rail / local 100nF | used | all VDD pins |
| 17 / PA3 | GPIO | — | Unconnected | free | extension margin |
| 18 / PA4 | GPIO | SPI_CS | Future sensor | reserved | software chip select |
| 19 / PA5 | SPI1_SCK AF5 | SPI_SCK | Future sensor | reserved | SPI alternative |
| 20 / PA6 | SPI1_MISO AF5 | SPI_MISO | Future sensor | reserved | SPI alternative |
| 21 / PA7 | SPI1_MOSI AF5 | SPI_MOSI | Future sensor | reserved | SPI alternative |
| 22 / PC4 | GPIO / EXTI | IMU_DRDY | Future sensor | reserved | timestamp candidate |
| 23 / PC5 | GPIO | ESC_ENABLE | Future ESC | reserved | actual interface TBD |
| 24 / PB0 | GPIO / EXTI | ESC_FAULT | Future ESC | reserved | actual interface TBD |
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
| 42 / PA8 | TIM1_CH1 AF6 | MOTOR_PWM | Future ESC | reserved | PWM candidate only |
| 43 / PA9 | USART1_TX AF7 | UART_TX | Future debug UART | reserved | no circuit now |
| 44 / PA10 | USART1_RX AF7 | UART_RX | Future debug UART | reserved | no circuit now |
| 45 / PA11 | FDCAN1_RX AF9 | CAN_RX | Future transceiver | reserved | USB DM shares pin |
| 46 / PA12 | FDCAN1_TX AF9 | CAN_TX | Future transceiver | reserved | USB DP shares pin |
| 47 / VSS | Power | GND | Ground | used | all supply returns |
| 48 / VDD | Power | +3V3 | Rail / local 100nF | used | all VDD pins |
| 49 / PA13 | SWD AF0 | SWDIO | J2.2 | used | retain debug |
| 50 / PA14 | SWD AF0 | SWCLK | J2.4 | used | retain debug |
| 51 / PA15 | GPIO | — | Unconnected | free | extension margin |
| 52 / PC10 | GPIO | — | Unconnected | free | extension margin |
| 53 / PC11 | GPIO | — | Unconnected | free | extension margin |
| 54 / PC12 | GPIO | — | Unconnected | free | extension margin |
| 55 / PD2 | GPIO | — | Unconnected | free | extension margin |
| 56 / PB3 | Trace AF0 | SWO | J2.6 | used | optional trace fitted |
| 57 / PB4 | TIM3_CH1 AF2 | ENC_WHEEL_A | Future encoder | reserved | separate timer |
| 58 / PB5 | TIM3_CH2 AF2 | ENC_WHEEL_B | Future encoder | reserved | separate timer |
| 59 / PB6 | I2C1_SCL AF4 | IMU_SCL | Future sensor | reserved | bus candidate |
| 60 / PB7 | I2C1_SDA AF4 | IMU_SDA | Future sensor | reserved | bus candidate |
| 61 / PB8 | BOOT | BOOT0 | R1 / TP6 | used | normal flash configuration |
| 62 / PB9 | GPIO | — | Unconnected | free | extension margin |
| 63 / VSS | Power | GND | Ground | used | all supply returns |
| 64 / VDD | Power | +3V3 | Rail / local 100nF | used | all VDD pins |

Physical pins: 17 used (includes power), 26 reserved, 21 free. All 64 accounted for. Free GPIOs can accommodate a second ESC UART (PA2/PA3 USART2 AF7), CAN standby, encoder index and additional ADC after actual device selection.

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

TIM2 is used for pendulum AB, TIM3 for wheel AB, TIM1 for one PWM; no timer pair is shared. I2C1/SPI1/USART1/FDCAN1 do not collide with implemented SWD/reset/BOOT pins. ADC12_IN6/7 is not an AF selection. PA11/12 USB conflicts with the FDCAN reservation and needs a subsequent pin-plan revision if selected. PB8 is kept for BOOT in this revision. DMA/DMAMUX, interrupts, actual sensor/ESC levels, peripheral setup and CubeMX simultaneous allocation remain TBD. No external peripherals are connected in Task 2.
