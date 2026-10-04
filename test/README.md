# Verification plan

| Stage | Evidence | Status |
| --- | --- | --- |
| Repository initialization | git status/diff、公開前内容とidentity review | 初期構築時に記録 |
| Conceptual KiCad schematic | native load/export、all-severity ERC | `docs/validation.md`参照 |
| Electrical schematic | datasheet/pin review、ERC、requirement trace | Task2/3回路図、ERC0Error/1intentionalWarning |
| PCB | footprint/orientation、DRC、mechanical/製造review | Task5配線済み、DRC0/0・未配線0。製造/実機承認は未実施 |
| Firmware | selected target build、unit/bench test、fault injection | 未作成 |
| Simulation | parameter provenance、energy/sign、limits、model comparison | 未作成 |
| Hardware | staged bring-up、sensor/ESC calibration、safe-state test | 未実施 |

生成レポートと生ログは `results/` (ignored)へ。review済みの結果要約をdocsに保存する。空の回路図がERCを通っても実回路を合格扱いにしない。
