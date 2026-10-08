# Motor, momentum and braking screening

GB54-1 KV33 is **not frozen**. [Manufacturer catalogue](https://www.ligpower.com/product/gb54-1-gimbal-type.html) provides137g,12N14P (7pole pairs),3–6S,15.6ohm resistance and0.33Nm listed torque. Maximum/continuous torque, phase-vs-line resistance, torque-speed curve, thermal conditions, screw depth and rotating/fixed face remain unverified. No procurement is performed.

The original130/110mm90g annulus has J=3.2625e-4kgm². H=J*omega, torque=J*alpha, energy=J*omega²/2. Screening assumes uniform180mm cube1.2kg, I_edge=2ma²/3=0.02592kgm²; face-to-edge barrier=mg*a*(1/sqrt(2)-1/2)=0.4387J. An ideal instantaneous transfer requires H=sqrt(2 I_edge DeltaU)=0.15081Nms, or4414rpm for one annulus. It ignores losses; finite-duration gravity, contacts and geometry need a hybrid model.

At24V, KV*V=792rpm is an optimistic no-load estimate, not loaded or safe speed. H=0.02706Nms/wheel. Three arbitrarily aligned contributions cannot exceed0.08118Nms; three orthogonal equal spins have magnitude0.04687Nms, less than the screened requirement. Thus adding three GB54 motors does not solve this get-up case. A mechanical brake alone does not fix insufficient stored angular momentum. Different mass/COM/contact geometry requires recomputation.

Recomputation from the native-cross-checked composite geometry plus180g unplaced reserve gives a higher face-to-edge barrier0.49923J, edge nonspin inertia0.02999287kgm², ideal impulse0.17305Nms and5065rpm for one annulus. Edge is parallelbodyZat(-90,-90,0)mm, initial face normalbody+Y. This explicit COM shift worsens the case; neither uniform nor composite calculation is a dynamic contact/impact qualification. GB54 does not pass either screening.

Estimated Kt=8.27/33=0.25061Nm/A, Iq for catalogue0.33Nm=1.317A. If phase resistance were7.8–15.6ohm and Iq is peak-phase current, copper loss=1.5 R Iq²=20.3–40.6W. This illustrates uncertainty, not a thermal rating. Catalogue0.33Nm would need approximately0.082s to stop one wheel from792rpm absent body motion; initial mechanical power27.4W. Initial gravity torque at a face-edge pivot is1.059Nm, exceeding the catalogue torque. At constant0.020Nm, ideal momentum headroom lasts1.35s from zero to the no-load estimate; persistent disturbances require lean/momentum unloading.

Three wheel energies at792rpm total3.366J. If all reaches an isolated DC link, keeping24V below30V needs at least20.8mF ideal capacitance, before tolerances/ESR/other rotor energy. This is not a capacitor selection. Actual regen current depends on stopping time: average approximately E/(V*dt), peak higher. For4414rpm, each wheel stores about34.85J; simultaneous three-wheel braking could involve about104.6J and, at50ms/24V, about87A average if all energy regenerates. Mechanical braking dissipates much of this in the brake instead, requiring brake/impact/heat qualification. No supercapacitor board connection is approved.

| Candidate | Benefit | Unresolved / driver consequence |
|---|---|---|
| GB54-1 + Micro, direct | low KV/compact current driver; limited-angle learning | unverified limits; screened get-up rejected |
| MN4006 EVO KV380 + suitable FOC driver | official shaft/body and propeller torque/RPM data;73g; higher speed | propeller DC-current tests are not Iq or reversible FOC ratings. Micro3.5A gives estimated0.076Nm direct,7Apeak0.152Nm; do not use catalogue18A with Micro |
| Higher-speed motor + reduction + wheel/brake redesign | independently tune speed/torque and wheel inertia | reduction sacrifices wheel speed; gearbox/belt backlash and bearings; not a selected part |

[MN4006 primary data](https://www.ligpower.com/product/ligpower-mn4006-EVO-kv380-motor-antigravity-type.html) is a shortlist candidate, not a new unsupported adoption. At4:1, ideal24Vwheel speed2280rpm and estimated0.305Nm at3.5A before losses, still below4414rpm one-wheel screen. A larger wheel inertia, lower mass or different motor/driver is necessary. Motor cooling in an enclosed cube differs from a propeller test. Obtain winding constants, bidirectional FOC/braking limits, rotor inertia, mounting and encoder before detailed design.
