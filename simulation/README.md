# Control simulation scope

状態: モデル要件整理のみ。シミュレーションコードと数値結果は未作成。

角度は上向き平衡点からの振子角 `theta`、wheelの振子に対する相対角 `phi` を候補とし、正方向・観測frameを機構と統一します。動力学は質量分布、wheel軸位置、motor rotor inertia、摩擦、ESC遅延・飽和を含めて導出します。

必要パラメータ: 支点から重心までの距離、各質量、支点回り慣性、wheel回転慣性、摩擦、motor torque constant、電流/速度limit、sample time、sensor/actuator latency。約90 g・径130 mmだけからwheel inertiaを確定しません。

手順: 非線形modelとenergy/signチェック → 平衡点線形化 → controllability → PID/state feedback/LQR → saturation/latency/noise → 推定・同定 → swing-up → 実機との比較。Python環境はproject-local venvを用い、必要な依存を導入した時点でversionを記録します。
