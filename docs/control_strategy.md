# Staged control and model limits

1. Retain1axis fixture and existing limited-angle requirement; confirm actuator signs, measured delays, encoder and torque/current limits.
2. Validate3axis controller on a fixed pivot simulation, then fixture-supported body with qualified actuators. Torque allocation uses a full-rank wheel-axis matrix A; orthogonal A is our independent proposal, not measured reference geometry.
3. Edge balance: contact/constraint model differs from a point pivot; separate linearization and momentum unloading.
4. Point balance: tilt stabilization and yaw-rate control. Six-axis IMU yaw drift forbids claiming absolute heading control without another observation.
5. Self-righting: spin-up, controlled/brake impulse, face-edge-point contact transitions and catch; qualify impact, friction and energy absorption before hardware.

The original Python quaternion RK4 screening uses fixed ideal corner pivot. I_L is locked inertia, J is axial wheel inertia, relative rotor speeds s. Body inertia I_B=I_L-AJA^T. With A=identity:

I_B w_dot = tau_gravity - u - w cross (I_L w + J s)

s_dot = J^-1 u - w_dot; q_dot=0.5 q*[0,w]. tau_gravity=r cross (R^T m g_world).

This accounts for body reaction and wheel relative motion without double-counting axial inertia. Inertia/mass derive from assumed clearance solids plus unplaced reserve, not a finished mechanism. Controller is ideal gravity/gyro compensation plus quaternion PD, sampled500Hz with one-step command delay.0.2Nm is hypothetical;250rpm is a drive-command inhibition threshold, not a hard speed clamp, rated or safe RPM. A falling body can exceed it. No noise, state estimator, motor-voltage model, thermal dynamics, bus jitter or unilateral contacts.

10s screening: initial tilt0,+0.5,+1,-1degrees settled within0.5degrees/0.03rad/s after3s; maximum rotor speeds~0/79/157/157rpm. +2degrees failed, exceeded250rpm and fell under the fixed-pivot model. These five cases do not prove a3Dregion of attraction or実機 feasibility. Get-up simulation is **not implemented**; analytical momentum screen fails GB54 direct drive. See JSON for exact results and numerical checks. No controller gains are installed on hardware.
