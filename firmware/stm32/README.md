# STM32 firmware scope

まだCubeMX `.ioc`、startup、HAL、linker script、実行コードはありません。MCU exact part/packageと評価ボード型番を決めてから初期化します。

予定構成: board support、time-stamped sensor drivers、control scheduler、estimation/control、ESC command adapter、watchdog/fault state machine、UART/CAN logging。

先に確認: timerとDMA競合、FDCAN clock、角度/速度unitsとsign、sensor age、ESC正負トルク・enable・timeout、WCETとjitter。motorはexplicit arm後のみ動作し、reset/faultのsafe stateは実機仕様に合わせて定義します。

ベンダー生成コードは採用時にライセンスと配布条件を確認し、必要なsourceと設定だけを追跡します。build成果物・IDE workspace・秘密情報は追跡しません。
