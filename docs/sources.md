# Official source verification record

確認日: 2026-10-02。資料は公式URLを記録し、vendor PDF/SDKそのものは公開repositoryへ含めない。候補部品の存在確認と、採用回路を設計可能な詳細reviewを区別する。

| Source | Revision / sections checked | Finding / scope | Remaining work |
| --- | --- | --- | --- |
| [STM32G431 datasheet DS12589](https://www.st.com/resource/en/datasheet/stm32g431rb.pdf) | Rev 6、198 pages。Device summary、Table 12 pin definition、Table 13 alternate functionsをWeb閲覧 | G431候補、SWD PA13/PA14、PB8-BOOT0とAF競合に注意。package未選定のため物理番号は割当しない | 選定ordering codeの対象package列、全電源pin、電気特性、footprintを詳細確認 |
| [STM32G4 reference manual RM0440](https://www.st.com/resource/en/reference_manual/dm00355726-stm32g4-series-reference-manual-stmicroelectronics.pdf) | Rev 9。公式URLのindexed textからdevice feature table、30.4.18 Encoder interface mode (pp.1334-1335)を確認 | G431向けperipheral範囲とencoderのTI1/TI2・count方向・filter/ARR確認の必要性を確認 | PDF全体はWeb容量制限、ローカルST downloadはtimeout。全register/clock/boot/DMAの詳細reviewは未完了 |
| [RM0440 encoder section alternate official URL](https://www.st.com.cn/resource/en/reference_manual/dm00355726-stm32g4-series-advanced-armbased-32bit-mcus-stmicroelectronics.pdf) | Rev 9、30.4.18のindexed textを照合 | 二入力quadrature encoderを需要表に反映。family全timerがG431にあると仮定しない | selected MCUでのtimer存在・AF pairをDSとCubeMXで照合 |
| [B-G431B-ESC1 UM2516](https://www.st.com/resource/en/user_manual/dm00564746-electronic-speed-controller-discovery-kit-for-drones-with-stm32g431cb-stmicroelectronics.pdf) | Rev 4の導入・board identificationを確認 | 外部motor-control評価候補。controllerとESC側MCUの役割分担はTBD | 実board revision、power/command/connector/safety詳細review |
| [G431/G441 errata ES0431 entry](https://www.st.com/en/microcontrollers-microprocessors/stm32g4x1/documentation.html) | 文書一覧で存在確認のみ | errataをdesign gateに含める | selected silicon revisionと使用peripheralの全関連errata確認 |

## Design gate

回路部品を追加する前に、採用部品の公式資料を読める状態にして、資料revision・section・pin/voltage/clock・未使用pin処理を記録する。上記の部分確認だけで最終MCU回路や電源回路を設計しない。

AS5600、IMU、transceiver、regulator、motor/ESC、connector、protection部品はまだ選定していないため、採用資料reviewも未実施。値や回路を推測で固定しない。

## Task 2 reviewed sources (2026-10-02)

Earlier rows record Task 1's historical limits; below supersedes them for the MCU/power/SWD scope.

| Primary source | Revision / reviewed sections | Applied result / limits |
| --- | --- | --- |
| [ST DS12589](https://www.st.com/resource/en/datasheet/stm32g431rb.pdf) | Rev 6, §3.7/3.11/3.13, Fig10, Table12/13, Fig16, §6.5, Table101 | All64 physical pins, power ranges/decoupling, debug/clock/boot, reservation AF and LQFP64 checked. Full analog performance/clock budget remains future work |
| [ST AN5093](https://www.st.com/resource/en/application_note/an5093-getting-started-with-stm32g4-series--hardware-development-boards-stmicroelectronics.pdf) | Rev 2, §2.1/2.2, §4/5/6.4/7.4, Table10 | VBAT connection, internal reset pull-up +100nF, boot, SWD internal pulls, optional analog ferrite/direct connection |
| [ST RM0440](https://www.st.com/resource/en/reference_manual/rm0440-stm32g4-series-advanced-armbased-32bit-mcus-stmicroelectronics.pdf) | Rev 9 official indexed text: boot Table5, Category2 FLASH_OPTR, §9.3.15/16 PG10/PB8 reset/boot selection, RCC clock selection | nSWBOOT0/nBOOT0 and NRST_MODE verified. Full PDF exceeded web size limit; all register programming/clock/DMA review is not claimed |
| [Diodes AP2112](https://www.diodes.com/datasheet/download/AP2112.pdf) | DS39724 Rev 2-2, pp1–3, 3.3V electrical table, ordering/package pages | SOT25 1VIN/2GND/3EN/4NC/5OUT, EN tied input, 1uF ceramic stability, headroom/thermal, exact ordering code |
| [Vishay SS12–SS16 family](https://www.vishay.com/docs/88746/ss12.pdf) | Document88746, ratings/package/ordering | SS14 40V/1A, VF max0.5V at1A, SMA cathode marking and pin orientation |
| [Kingbright APT2012SECK](https://www.kingbrightusa.com/images/catalog/SPEC/APT2012SECK.pdf) | V17A, 2025-03-17, dimensions/electrical characteristics | orange0805 polarity and Vf2.1typ/2.5max at20mA. Brightness at selected sub-mA remains untested |
| [KiCad libraries license](https://www.kicad.org/libraries/license/) | CC-BY-SA4.0 with design-file exception | cached standard symbols permitted in design artifacts. No vendor PDFs/library collections copied into repository |

Silicon-specific ES0431 errata review against the purchased revision remains a powered bring-up / future peripheral gate; current circuit makes no peripheral performance claims. Standard KiCad library files are installed locally and were checked against package drawings, not merely matched by symbol names.

### ES0431 circuit-scope cross-check

[ST ES0431 Rev9 (June2024)](https://www.st.com/resource/en/errata_sheet/es0431-stm32g431xx441xx-device-errata-stmicroelectronics.pdf): summary and System §2.2.1–2.2.10 reviewed. SWD avoids the full-JTAG/PB4 limitation. HSI-only design has no HSE-bypass/LSE circuit. Backup-domain reset after partial supply decay is a real concern even with VBAT tied VDD; bring-up must confirm VDD/VBAT <100 mV for >200 ms before repowering, or implement the documented firmware backup-domain reset on power-on. No firmware workaround is implemented in Task2. Low-power debug, SRAM initialization, flash programming interruption and silicon-revision-specific peripheral limitations remain firmware/bring-up checks. Identify REV_ID before peripheral enable.
