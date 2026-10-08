# Reference investigation — 2026-10-08

| Item | Confirmed / unresolved |
|---|---|
| Exact requested X post | Fetch failed: https://x.com/H0meMadeGarbage/status/2107279709327487272 ; identity/motion unconfirmed |
| Related machine | HomeMadeGarbage SHISEIGYO-3 N1: three reaction wheels, edge and point balance, yaw rotation, staged get-up |
| Mechanism | One-piece printed frame; BLDC ID-529XW x3 identified in author's development articles. Not GB54 or ODrive |
| Get-up | Spin central wheel then servo-actuated band brake for face-to-edge; two lateral wheels/brakes for edge-to-point |
| Dimensions / axes | Exact dimensions, mass, inertia and complete wheel-axis geometry not established; our180mm orthogonal layout is independent |
| Appearance | Printed-frame mechanism described by author. Images/videos not reliably rendered in this investigation; no exact visual match asserted |
| Control | Public ESP32 sketch has MPU6050/Kalman, PWM/direction/brake pins, quadrature PCNT, angle/rate/wheel terms and yaw-rate control; gain values are not transferred |
| CAD | No native/STEP/STL files in inspected public repository tree; commercial recipe/product is not freely reusable CAD |
| License | README states MIT for software; no standalone LICENSE seen in tree. No source copied. Blog photos, recipe and CAD rights not inferred from software license |

Sources: [usage](https://homemadegarbage.com/reactionwheel84), [development](https://homemadegarbage.com/reactionwheel82), [brake development](https://homemadegarbage.com/reactionwheel83), [software](https://github.com/homemadegarbage/SHISEIGYO-3-N1). Inspected software revision: ec8a88f4e9fffab502140e5b2d853c7e396b4ce6; tree consists of README, three ESP32 files and one image. Code is reference-only; vendor SDK, photos and models not redistributed.

Important: author's earlier brake-less prototype failed to get up, then band-brake changes enabled the reported behavior. This supports evaluating impulsive mechanical braking, not assuming all electric braking is impossible for all motors. SHISEIGYO-3 DC and other earlier works are different machines.
