# Three-axis integration study — Rev B

Confirmed actual Inventor files: Cubli_ThreeAxis_Standalone.iam and
Cubli_ThreeAxis_Integration_Study.iam under local_study_b2/.
Independent wheel axes X/Y/Z, allocation matrix identity, rank3, condition number1.
Origins(mm): Z=(-35,35,72), X=(72,-35,35), Y=(35,72,-35).
Outer frame280mm cube; wheel150mm. The stagger avoids wheel/motor collisions,
but enlarges the original200mm concept. No final cube size approval implied.

Standalone2.753310kg; shared2.691294kg.
Savings62.02g by lighter docking ribs replacing3 full module frames.
Both include one common host frame; common parts are counted once.
Shared native COM(mm)=[18.054550309772946, 7.136314959862169, 4.593162690802411] from cube center.
Native tensor terms(kg m2), orderIxx/Iyy/Izz/Ixy/Iyz/Ixz:
[0.03411952272909015, 0.031217653831018478, 0.030124446649400234, -0.000464388270255474, -0.002928299478288793, -0.0008119898828301374].
Separate body-only simulation parameters exclude whole rotor groups, not merely wheel rims.

ODrive Micro3 envelopes32x32x7mm, each8.1g connector-receptacle basis.
Controller outline90x70mm and hole80x60mm spacing from tracked KiCad; thickness1.6mm/mass50g
are assumptions and component heights/cable volumes are not fully modeled.
Battery110x45x30mm/300g is a parametric budget, not selected manufacturer geometry.
Missing fasteners, complete brackets, cables and power protection:150g separate assumption reserve.
Final estimated mass2.841294kg, not old1.40kg.
No physical CAN/power/regeneration capacity was qualified in this CAD task.

## Verification scope and HOLD

Released static integration interference0. Module155 healthy constraints retained after frame
replacement. Top-level fixture poses are grounded; no all-axis dynamic/contact simulation claim.
Eight sampled single-module poses; spring compression envelopes overlap at closed states.
Shared docking-to-host joints, frame deflection, service access, actual cables, release springs,
connector access and guards need detailed load/motion verification.
No swept-volume or complete contact-transition simulation was run.

## Self-righting screen

Face-to-edge uses CAD COM and locked assembly inertia about a candidateY edge.
Edge-to-point is an idealized energy/impulse screen with assumed contact pivot and two-wheel allocation.
Impulse transfer0.9/0.7/0.5: face-to-edge9506/12222/17111rpm;
edge-to-point7677/9870/13818rpm. Surfacefriction0.3/0.5/0.8 is a pending hybrid-contact
simulation sensitivity, not an executed solver result. Therefore self-righting **NOT VERIFIED**.
Motor/driver speed and coupling8000rpm, wheel containment and impact design do not currently
support these requirements. Do not simply run faster; redesign angular-momentum budget first.
