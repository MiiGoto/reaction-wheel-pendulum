# Bring-up plan (not executed)

開始条件: 電源/部品/配線を公式資料で確認し、ERCをreview。PCB導入後はDRCと製造reviewも必要。Task5で全ネット配線済み、nativeDRC0Error/0Warning/0unrouted。製造・実機承認は別途必要。製造・組立・通電試験は未実施。

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

## Task 3 staged interface bring-up (future hardware; not executed)

Motor **unplugged** for steps1–9. Use existing SWD recovery/BOOT/reset steps; initial220mA bench limit at5V, reduce limit for power-only diagnosis. Record board revision, siliconREV_ID, firmwarecommit, instruments and observed values.

1. J1 polarity/input4.8–5.25V, protected input,3.3V/VDDA/VREF, idle/current/ripple and LDO temperature; verify180mA budget under expected loads. Stop on overheating/rail droop.
2. SWD identification/reset/flash and normal boot; inspect reset states. Explicitly disable PB4 UCPD dead-battery before ABI input sampling, preserve SWD and BOOT.
3. J7 USB-UART with3.3V I/O only, crossoverTX/RX, commonGND; no adapter power pin. Verify USART1 output/readback, chosenbaud/error rate and reset idle.
4. U4 SPI1 start1MHz mode3, CS default high, read WHO_AM_I0x0F=0x6A; software reset, configure4wire/BDU/increment, INT1active-high push-pull, sensor hub/INT2DEN disabled. Measure interrupt-to-read age, ODR, sensor bias/axis sign/filter latency; finalrate TBD.
5. Select a documented3.3V push-pull ABI module <=20mA; motor disconnected, hand-turn guarded shaft or use a calibrated3.3V signal generator. Confirm A/B quadrature/count direction/index and unplug default00; test maximumrequirededge rate/filter/16bit overflow separately. Confirm magnet/alignment/RPM before spinning.
6. MCU internal FDCAN loopback first (not a transceiver test). Then two-node real bus with exactlytwo120ohm ends, J4 shunt only at end, ground reference and twistedH/L. Start conservative bitrate, CAN_STB low for normal; observe TP7–10, ACK/error counters/bus-off. Use FD only after HSI timing tolerance/topology qualified; apply silicon-specific errata policy.
7. J6 to scope/dummy logic load **without ESC power or motor**. During power-up/reset or an unpowered/disconnected MCU, EN and PWM must stay low; verify U5 gating and series/pull resistors. SWD halt can retain EN and timer/PWM outputs: halt is not a stop mechanism. Keep motor power independently isolated during debugging; qualify actual ESC timeout/watchdog and arming before motor tests. Fault pin simulate open-drain low/high; unplug reads high, so cable loss needs separate health detection.
8. With EN low verify no command pulses at TP15; with an explicit bench command check PWM rate/pulse shape and U5 enable timing. Do not choose an arbitrary ESC pulse convention; no analog low-pass filter fitted.
9. Verify selected ESC official pinout/3.3V thresholds/enable polarity/fault type/timeout; only then connect logic with motor still unplugged, review BEC backfeed/commonGND. For B-G431B-ESC1 only J3.4PWM/J3.5GND adapter initially, correct generatedMCSDK firmware required. Confirm actual disable/reset/watchdog behavior without motor. OptionalUART2 after protocol/cable verification only.
10. Motor test requires a separate approved plan: secure fixture/guard, maximumRPM/current/torque, independent motor power isolation, regenerative energy handling, reverse-command behavior and explicit arming. Unknown motor/ESC or RPM blocks powered motor testing. Begin minimumenergy tests last; control stabilization/FOC are outside Task3.

Acceptance thresholds for latency/ripple/temperature/edge loss/CANbitrate are TBD until control and external devices are selected. This plan is not evidence that any powered test passed.

## Task 4 review gates before routing / assembly

Confirm preliminary90x70mm/fourM3holes against mounting and screw/spacer dimensions; check all header mating height/cable orientation. Map ST IMU Figure1 native axes and pin1 to board/mechanical frame. Qualify0.15mm IMU internal pad spacing/stencil/paste and actual supplier4layer stackup. Review capacitor return routing, TVS discharge GND and rail thermal budget when routing is authorized. No physical bring-up has been performed. A173unrouted baseline DRC is not a fabrication release.

## Task 5 ordered bring-up checklist — future physical tests

Prerequisite: complete signal routing, full DRC/review and manufacturing/assembly approval in a later authorized task. Current PCB has0unconnected items; finalDRC passes. It has not been manufactured or powered. Exact BOM/stackup/assembly/external device/safety approval still required.

1. Visual inspection: soldering, pin1, polarity, holes, cable pinout and shorts.
2. VIN–GND resistance check, supply disconnected.
3. 3V3–GND resistance check; account for capacitor charging.
4. Current-limited logic-only power-on; motor/ESC unplugged.
5. VIN and protectedVIN check against approved input range.
6. 3.3V rail/ripple/current and regulator temperature check.
7. VDDA/VREF check at capacitor pads/TP4 common rail, local scope return.
8. SWD connection with verified customJ2 adapter and VTref sense.
9. MCU identification, silicon revision/errata and normal boot/recovery.
10. Power LED test.
11. UART3.3V adapter loopback/log check, no adapter power backfeed.
12. IMU WHO_AM_I0x6A, official/native-axis mapping, ODR/latency/calibration.
13. Qualified3.3V ABI encoder signal/count/index/max-edge-rate checks.
14. CAN loopback then two-node bus, correct120ohm ends, termination/default standby/bitrate.
15. ESC interface checks with no motor and verified actual ESC pinout/polarity/timeout.
16. PWM oscilloscope checks on dummy logic load.
17. ENABLE/FAULT default/gating and fault-wire loss checks; SWD halt does not ensure stop.
18. Motor connection only after prior checks pass and a separate guarded/isolated low-energy motor test plan is approved.

No acceptable fixed resistance threshold invented; compare measured behavior to approved BOM/circuit and investigate unexpected low resistance. Record all results/conditions/revision. Physical tests not performed.

### Superseding Task5 draft gate

Current interface draft has45unconnected items and2physicalMOSI/GND errors (DRC47Errors/0Warnings). Earlier73unconnected power-only checkpoint is historical. Do not assemble/power/manufacture this draft. Resolve errors and remaining routing, perform finalDRC/parity/return-path review, then seek later manufacturing approval. Existing18-step bring-up plan remains future work. Official IMU graphical source now verified; mechanical sign calibration remains mandatory.

### Current gate — supersedes the draft gate above

Routing now complete: DRC0Errors/0Warnings/0unrouted/0parity; ERC0Errors/1intentionalWarning. All18steps above remain planned, not executed. Confirm finalBOM, capacitor DC bias, supplierstackup/assembly, actual encoder/ESC, mechanical/sign mapping and independent motor isolation before manufacture/assembly/any powered tests. No Task6 or motor authorization implied.
