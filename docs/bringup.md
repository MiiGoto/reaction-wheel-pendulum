# Bring-up plan (not executed)

開始条件: 電源/部品/配線を公式資料で確認し、ERCをreview。PCB導入後はDRCと製造reviewも必要。現時点では概念図のため通電できる設計はない。

1. ガード・治具・電源遮断手段を用意し、定格、limit、coast/brake/disable方針を確定。ホイール回転試験は最大rpm・energy確認後。
2. モータを接続せず、外観・continuity・GND/電源short・connector polarityを確認。
3. 電流制限電源でlogic部のみ通電。各rail、startup、reset、消費電流、温度を測定し仕様と比較。
4. SWDで接続・書込み・復旧を確認。BOOT/NRST/watchdogを評価。起動時ESC commandは安全状態に保つ。
5. UART loggingを確認し、firmware ID、time base、units、sign、sampling ageを記録。
6. センサを個別に校正し、静止/既知角度/既知速度で検証。欠測・disconnect試験を行う。
7. CAN transceiver電源・終端・bitrateを確認して通信評価。bus-off、PC切断、timeoutを試験。
8. ESC単体を低energy条件で評価。正負トルク、低速応答、disable、回生、faultを確認してからwheel付き試験へ移る。
9. 固定治具でopen-loopの小commandから評価し、limit・故障時挙動を確認。制御modelとsignを照合して閉loopへ進む。

各段階で条件、測定値、期待値、結果、commit IDを `test/results/` にローカル保存。公開する記録は個人情報と機器固有の秘密情報を除去して別途reviewする。

## Task 2 standalone control-board bring-up (future physical test)

1. Review U1 LQFP64 orientation, all supply pins, D1/D2 polarity and J1/J2 labels before assembly. Select ceramic MPNs meeting effective capacitance, verify soldering/shorts with no power.
2. Keep motor/ESC and future sensor circuits disconnected. Confirm J1 external supply 4.8–5.25 V, current limit <=150 mA; start with low-energy short-circuit checks. Never power target through J2 VTref.
3. Measure TP2/TP3/TP4/GND, input/output ripple and regulator temperature. Confirm protected VIN >=4.3 V, +3V3 within AP2112 tolerance under actual load <=100 mA. Motor voltage not approved.
4. Verify J2 physical adapter wiring individually, connect common GND/VTref before SWD and NRST, and avoid driving an unpowered target.
5. Read device ID, silicon revision and ES0431 errata; retain NRST_MODE=3. Read boot option bytes, program normal-flash nSWBOOT0=0/nBOOT0=1 only after recovery path review. Empty flash may boot ROM intentionally.
6. Check NRST waveform, SWD recovery, power LED and HSI clock timing. Keep VREFBUF disabled/high impedance. Measure ADC noise before adopting analog precision targets.

These are planned tests; no assembled board, firmware, option-byte programming or hardware measurements were performed in Task 2.

Task2 errata addition: ES0431 §2.2.6 requires verifying VDD/VBAT decay below100 mV for >200 ms between bench power cycles, or applying its software backup-domain reset workaround. Because VBAT is tied +3V3, measure TP4. Do not assume a brief supply interruption guarantees a valid backup-domain reset.
