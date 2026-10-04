# reaction_wheel_controller

KiCad10.0.6でreaction_wheel_controller.kicad_proを開く。rootは概念概要、階層sheetはMCU/電源/SWD、CAN/IMU、Encoder/ESC、UARTの実回路。Task5でreaction_wheel_controller.kicad_pcbの全ネット配線を完了。90x70mm、4層、86footprints、548segments、155via、R0.5。

NativeDRC0Errors/0Warnings/0unrouted/0parity、ERC0Errors/1intentionalSDX/GNDWarning。主要設計ファイルとproject-local symbol table、custom design rulesを追跡。outputs/はlocal report・preview・checkpoint用でignored。VendorPDF/tools/SDK、Gerber/drill/PnPは公開せず、製造出力自体未実施。

DRC合格は製造承認・実機適合ではない。ExactBOM/stackup/assembly/encoder/ESC/mechanical/safety/thermal/EMIは未検証。[routing review](../../docs/task5_routing_review.md)、[validation](../../docs/validation.md)、[bring-up](../../docs/bringup.md)参照。未使用/予約MCUpinは意図的NC、firmware未実装。
