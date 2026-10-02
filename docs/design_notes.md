# Design notes and decisions

## 2026-10-02: initial scope

**確定**: 一つのrepositoryでhardware/firmware/simulation/mechanical/docs/testを管理。今回の停止地点は初期構築。

**候補**: STM32G431、外部ESC/B-G431B-ESC1、3.3 V logic、補助5 V、AS5600。exact part/package、motor、sensor、bus方式は未選定。

**判断理由**: モータ・機構・正負トルク・センサ遅延が未確定のため、power stageや最終MCU pin配置の作り込みを先行しない。

## KiCad initialization

新規の `.kicad_pro` と `.kicad_sch` を作成。回路図の矩形・文字・破線は概念ブロックで、接続netや部品ではない。既存のKiCadファイルは編集していない。新規ファイルもnative CLIで読み込み、SVG出力とERCを検証する。

ブロック: Power input、input protection、5 V/3.3 V regulation、STM32G431、SWD、UART debug、CAN/FDCAN、IMU、encoder interface、motor/ESC interface、LEDs、buttons、test points。

PCBファイルは未作成。board outline・stackup・placement・routing・製造物は未実施。

## ERC warnings

意図的なwarning除外は設定しない。実行結果は `validation.md` に記録する。部品/netがない段階の0件は概念ファイルの初期チェックに過ぎず、電源/通信/実装の安全性検証ではない。次にsymbolsを追加した時点で改めて全severityのERCを実行する。

## Open design issues

通常のhobby ESCの速度commandだけで倒立制御の必要な正負トルク・低速応答を満たせるかは未確認。ホイールの速度飽和、回生、command timeout、sensorlessの低速挙動を評価する。AS5600をホイール高速測定に使えるとも仮定しない。

## 2026-10-02: Task 2 MCU / power / SWD

### Confirmed selection and package verification

- U1: **STM32G431RBT6**、LQFP64、10x10 mm body、0.5 mm pitch、64 lead、exposed padなし。Flash 128 KB、SRAM 22 KB + CCM SRAM 10 KB。ordering codeはDS12589 Table 101で照合。
- LQFP48 STM32G431CBT6も候補だが追加GPIO・clock・将来I/Oの余裕を優先しLQFP64を採用。BGA/QFNよりleadを目視でき、手実装・修理が容易。LQFP80/100は今回不要。
- KiCad 10.0.6 `MCU_ST_STM32G4:STM32G431RBTx` を使用。aliasの親symbolを解決して全64 physical pinをDS12589 Figure 10/Table 12のLQFP64列と照合。**64/64一致**。PG10はpin 7のNRST機能として使用し、BOOT0はPB8 pin 61。全番号はpinout表に記録。
- `Package_QFP:LQFP-64_10x10mm_P0.5mm`: 64 pad、pitch 0.5、pin 1はtop view左辺上端（角印）、番号は反時計回り、EPなし。DS12589 §6.5の10 mm body/12 mm lead spanと照合。padはleadの外側へ伸びるsolder landでありbody寸法と同一ではない。PCB設計時に採用実部品のdrawingと再照合する。
- 予約済み機能は同時使用可能なGPIOへ配置。PA13/14とPB3をdebug用に維持。PA11/12はFDCANの予約で、USBも同じpairを使うため同時使用には再割当が必要。CubeMX/DMA/clock詳細は後続タスク。

### MCU supplies and analog strategy

VDD 16/32/48/64、VBAT 1、VDDA 29、VREF+ 28を+3V3へ直結。VSS 15/31/47/63、VSSA 27をGNDへ接続。専用VREF-は外部padなし（内部でVSSAへbond）。VCAP/VDDIO2はこのpackageにないため追加しない。

DS12589 Figure 16のdevice-specific値を採用: VDD各100 nF + bulk 4.7 uF、VDDA 10 nF + 1 uF、VREF+ 100 nF + 1 uF。AN5093の一般例（bulk 10 uF / VDDA 100 nF）との値の違いはdevice datasheetを優先する。VBATはbattery未使用として100 nFを追加（AN5093 §2.1.3）。全capacitorは無極性ceramic。

初号機はVDDA/VREF+を同じ3.3 Vに直結しferrite/RC/LCは追加しない。AN5093 Table 10はferriteをoptionalとし直結を許容する。VDD/VDDAの起動差を作らず簡単に実装できる。ADC絶対精度はLDO ripple・基準誤差・ground returnの影響を受けるため未保証。**VREFBUFは無効/high impedanceのまま**（外部railへdriveしない）。精度要求と実測noiseに応じ将来見直す。

### Clock / reset / boot

- 外部HSE/LSEなし。内部HSI16と必要に応じPLLを使用する方針。初期起動・SWDには十分でcrystal/load-cap選定を省ける。制御周期、UART baud、FDCANのbit timingと温度範囲は未検証。将来FDCAN導入前にclock toleranceを評価し必要ならPF0/PF1にHSE追加。PC14/15もLSE予備として予約。USB clock対応を保証しない。
- NRST: MCU内部pull-up + C13 100 nF（AN5093 §2.2.3）、J2 pin 5からST-LINK reset、TP5で測定。external pull-up/reset buttonは初号機に追加しない。NRST_MODE=3（reset I/O default）を維持しPG10 GPIOへの変更を禁止。
- BOOT0: R1 10k pulldown、TP6でアクセス。通常flash起動の設定はnSWBOOT0=0/nBOOT0=1をbring-upで確認する。hardware pulldownはpin-controlled boot時にもlowを保つ。未書込flashのempty-checkによるsystem bootloader移行は故障ではない。実際のoption bytesは未設定。nBOOT1/BOOT_LOCK/RDPを不用意に変更しない。

### Power selection / protection / thermal assumptions

- 外部安定化5 V入力を採用、**J1実測4.8–5.25 V**、benchで供給側current limit <=150 mA。モータpower stageは分離、battery電圧は未確定のまま。
- U2 **AP2112K-3.3TRG1** / SOT25（SOT-23-5）、device rating 600 mAだがboard初期load budgetは**100 mA**。MCP1700級低電流LDOやbuckも比較対象とし、手実装できる5-lead package、簡単なEN接続、1 uF ceramicで安定するAP2112を採用。buckの効率は高いが100 mA初期条件には部品・switching noise・配線負担が増える。調達在庫は未確認。
- 公式AP2112 pinoutとKiCadを照合: 1 VIN、2 GND、3 EN、4 NC、5 VOUT。ENはVINへ直結、NCはno-connect。標準footprint SOT-23-5、5 pad、0.95 mm pitch、EPなし。top view pin 1左上/2左中央/3左下/4右下/5右上。
- D1 **Vishay SS14-E3/61T**、SMA/DO-214AC。anode pad 2=+5V_IN、cathode pad 1=+5V_PROTECTED。datasheet VF max 0.5 V @1 Aを保守的headroom計算に使用: 4.8−0.5=4.3 V、3.3 Vに1.0 V margin。AP2112 max dropout 0.4 V @600 mA以下。保護後VINは6 V recommended maximum以下とする。
- 最悪5.25 V、diode dropをゼロとしてLDO loss=(5.25−3.3)*0.1≈0.195 W。datasheet SOT25 thetaJA 184 °C/Wからrise≈36 °C（reference PCB依存）。室温25 °Cで約61 °Cの見積り。高温・600 mA・実PCB温度を保証する値ではなく、負荷追加時に再予算化する。
- C1/C2 nominal 4.7 uF /10 V/X7R/0805を使用。AP2112指定のeffective >=1 uFをDC bias・tolerance・温度込みで満たす実MPNを調達時に確認する。4.7 uF nominalだけでは条件充足を保証しない。
- 直列Schottkyで逆接対策を行う。current-limited short bench supply前提のためpolyfuse/TVSは追加しない。長い配線、motor rail、surge/ESD/独立電源からのbackfeedは未対策。VTrefから給電しない。電源未投入時にSWD信号をdriveしてphantom powerを起こさない。

### Debug, indicator and test access

J2はcustom 1x6/2.54 mm header。ARM 10-pin/1.27 mmはcompactで標準adapter向きだが、初号機はST-LINK個別wire接続が容易な2.54 mmを採用。標準ARM cableを直接挿すものではない。pinoutはdocs/pinout.md。SWOをPB3から追加。SWDIO/SWCLKは内蔵pullを使用（AN5093 §6.4）、external pullなし。PCBシルクに1/VTref/IO/GND/CLK/RST/SWOを明記する予定。

D2はKingbright **APT2012SECK** orange 0805。pad 1 cathode=GND、pad 2 anode=LED_A。R2 2.2kで、datasheet Vf typical 2.1 V（20 mAでの値）を参考とすると(3.3−2.1)/2200≈0.55 mA。低電流のVfは未保証なのでbrightnessは実測する。保守的Vf=0、rail上限3.3495 V・抵抗1%下限2178 ohmでも約1.54 mA、抵抗loss約5.2 mW以下（0.125 W級で十分）。

TP1 GND、TP2 input、TP3 protected input、TP4 +3V3（VDDA/VREFと同rail）、TP5 NRST、TP6 BOOT0。SWDIO/SWCLKはJ2でprobe可能。TestPoint_Pad_D1.5mmはprobe padで部品不要。

### Validation and unresolved issues

既存overviewは図形UUIDを保存して階層sheetを追加。標準symbolの継承を解決し、native parser/netlist/SVG/ERCで検証してから記録する。最初のERCのpower-output競合と重複stacked-pin wire warningは修正済み。意図的warning、exclusion、ignored checkは**なし**。最終結果はvalidation.md。

未決: actual passives/headers MPN、調達在庫、全load budget、PCB熱/ADC品質、ST-LINK adapter実配線、clock精度、CubeMX/DMA、silicon revisionに対応するerrata、option bytes実設定。Task 3前に人間が電源条件、SWD pinout、MCU/package、予約pinとCAN/USB競合をreviewする。PCB/routing/DRC/firmwareは今回実施しない。

### Errata review supplement

ES0431 Rev9 System limitations were checked for this circuit. SWD is used instead of full JTAG, and HSE-bypass/LSE are absent. For §2.2.6 backup-domain power-reset limitation, the initial bench power-cycle procedure requires both VDD and VBAT to fall below100 mV for >200 ms before reapplying power; otherwise a documented software backup-domain reset is required. The circuit alone cannot guarantee this discharge condition. Future firmware must handle reset/startup and revision-specific errata; these are not covered by ERC.
