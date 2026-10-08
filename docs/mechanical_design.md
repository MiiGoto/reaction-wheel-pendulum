# Independent Cubli clearance concept — NOT fabrication CAD

Proposed180mm cubic frame, three mutually orthogonal130mm wheels centered at(+80,0,0),(0,+80,0),(0,0,+80)mm. Wheel-plane offset gives10.579mm minimum major-envelope AABB gap. Motor envelopes at+60mm and Micro envelopes at+42mm along each axis.90x70mmcontroller clearance centered(0,0,-55)mm; battery50x30x20mm placeholder centeredorigin. PCB location, contacts and chosen corner are provisional. Reference-machine geometry has not been measured.

12PETG rails8x8x164mm and8corner blocks8mm are clearance volumes, not finished joints. No holes, motor-thread depth, material allowables or screw torque have been guessed. Each90g aluminum annulus has OD130/ID110/8.842mmthickness; it is deliberately NOT a retained spinning wheel: spokes/hub/guard/brake features are absent. Do not print or spin this annulus design.

Native study generator creates NEW assembly only and refuses overwrite. Native files remain local because Inventor embeds workstation paths; original generator and sanitized STEP/reports are public.31placed solids exclude the180g unplaced guard/mount/wire reserve. Analytical dynamics add reserve as a centered120mmmass distribution, yielding1.190461kg and COM from cube center(13.239,13.239,11.391)mm. This imbalance is due to three wheels/motors on positive faces and PCB on a negative face; do not call COM centered. Corner-to-COM approximately(103.239,103.239,101.391)mm. Native report contains separate mass/COM/inertia excluding reserve; product-of-inertia signs and origin must be interpreted explicitly.

Inventor2025 completed31placed occurrences; native mass1.01046096kg (assumed overrides), COM(15.597,15.597,13.420)mm from cube center. Modelled pair interference0; full mechanism not covered. Independent composite formula reproduces mass within7e-16kg, COMwithin3e-9mm and centroid inertia within1.1e-10kgm². XYZMomentsOfInertia returns orderIxx/Iyy/Izz/Ixy/Iyz/Ixz; direct offdiagonal signs were verified against our formula. STEP reimport yields31occurrences and180mmextent in each axis. Native files saved atmechanical/cubli_concept/local_native_v3 in the new worktree; excluded from public Git. Native screen activation failed; reviewPNG/SVG are independent parameter drawings.

Known wheel axial inertia3.2625e-4kgm² each. Analytical locked tensor aboutcorner,kgm²:

```
[[ 0.029999836, -0.012479570, -0.012281570],
 [-0.012479570,  0.030023836, -0.012281570],
 [-0.012281570, -0.012281570,  0.030319123]]
```

Subtract J*identity for the fixed-pivot body's nonspin axial tensor in simulation. This excludes unmodeled rotor axial inertia and treats motor envelopes as uniformly distributed nonspinning mass. It is not a release inertia tensor.

Manufacturing blockers: qualified motor/encoder/brake selection, shaft/hub positive retention, bearings and load ratings, compliant guard, impact-rated joints, COM optimization, PCB connector component geometry, power source, cable strain relief, fasteners, clear service/printing/assembly access. Existing220mmM1/M2 remain independent assets. No STL/DXF manufacturing parts are justified yet. Concept STEP/image and envelope BOM support review only, not ordering.
