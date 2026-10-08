# Rev B brake actuator selection

## Confirmed sources and provisional decision

[Actuonix PQ12 official datasheet](https://www.actuonix.com/assets/images/datasheets/ActuonixPQ12Datasheet.pdf)
[PQ12-100-12-P product](https://www.actuonix.com/pq12-100-12-p).
12V,20mm travel,19g P-version,100:1,40N at6mm/s power point,50N maximum lift,
10mm/s no-load,20% duty,0.25mm backlash,210mA stall at12V.
Stall and peak-power catalogue numbers do not certify continuous clamp duty.
Body36.5x21.5x15mm is a simplified own envelope; clevis coordinates and mounting are parametric HOLD.

Selected **slow prototype force/motion model**: PQ12 with dual opposed wedge.
Input0..10mm gives lower+0.65mm and upper-0.35mm. Guide slots, offset clevis,
mechanical stops, spring seats and actuator support are actual IPTs.

## Calculated sensitivity

Rectangular pad49.1..54.7mm radial-x,8mm wide, area44.8mm2, mean radius
51.954mm. T=2muNr.
mu0.10/0.15/0.25/0.35 requires approximately385/257/154/110N per pad.
Assumed wedge mechanical efficiency0.7 yields55/37/22/16N input.
Atmu0.10 the PQ12 max50N fails. mu0.15 pressure roughly5.7MPa requires a real lining specification.
4Nm is direction symmetric in a disc arrangement, but friction/force is NOT measured.
Stopping time after full clamp is tens of milliseconds; clamp application1.0..1.67s is far slower.
Bulk disc heat calculation excludes flash temperature, pad heating and wear; see brake_analysis.json.
Power-loss release is NOT guaranteed: shallow wedges may self-lock and PQ12 holds load.

## Bounded comparison

|Method|Force/stroke assessment|Response|Decision|
|---|---|---|---|
|Servo+cam|Can amplify force, but contact compliance and operating torque needed|Potentially faster; stall rating insufficient|Alternative HOLD|
|Servo+toggle|High force near dead center, narrow tolerance range|Potentially faster; release/over-center risk|Alternative HOLD|
|PQ12 geared screw+wedge|Real40N@6mm/s can conditionally give257N pads|1.67s closure|CAD proof only; reject as self-righting launch actuator|
|Solenoid+latch/spring|Can release preloaded clamp quickly; real energy/stroke essential|Potentially suitable impulsive actuation|Recommended next actuator study, not selected|

No actuator has been qualified for bidirectional4Nm rapid self-righting.
Return spring stiffness/wire/solid height, liningmu-vs-temperature, fail-safe behavior and actuator
force-speed/current must be verified before brake manufacture. No actual brake test occurred.
