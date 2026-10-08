# Control simulation scope

2026-10-08: `cubli_screening.py` is an original quaternion/gyro-coupled3axis fixed-pivot screening model using assumed clearance-solid mass/inertia, not a contact/get-up simulation or real-motor model. Results: `mechanical/cubli_concept/screening_results.json`; detailed limits in `docs/control_strategy.md`. +2degrees failed; do not present only successes. Torque-free/zero-gravity angular momentum and energy checks pass;500/1000Hzsample-and-delay sensitivity changes peakRPM by0.177. These checks are numerical/model consistency evidence, not hardware qualification. Existing1axis simulation/native CAD are preserved in the local integration branch and earlier publicreview reports.

The following is the historical initial plan.

状態: モデル要件整理のみ。シミュレーションコードと数値結果は未作成。

角度は上向き平衡点からの振子角 `theta`、wheelの振子に対する相対角 `phi` を候補とし、正方向・観測frameを機構と統一します。動力学は質量分布、wheel軸位置、motor rotor inertia、摩擦、ESC遅延・飽和を含めて導出します。

必要パラメータ: 支点から重心までの距離、各質量、支点回り慣性、wheel回転慣性、摩擦、motor torque constant、電流/速度limit、sample time、sensor/actuator latency。約90 g・径130 mmだけからwheel inertiaを確定しません。

手順: 非線形modelとenergy/signチェック → 平衡点線形化 → controllability → PID/state feedback/LQR → saturation/latency/noise → 推定・同定 → swing-up → 実機との比較。Python環境はproject-local venvを用い、必要な依存を導入した時点でversionを記録します。
