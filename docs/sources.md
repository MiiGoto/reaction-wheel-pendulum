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
