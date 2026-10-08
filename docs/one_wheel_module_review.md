# One-wheel Inventor module verification — 2026-10-08

## COMPLETED: real native CAD

Inventor2026.2 COM connected to a visible2026 process. A separate10×10×2mm
part was saved142848bytes,closed,reopened and returned one solid/200mm³.
Native v4 output contains36single-solidIPTs,one488960byteIAM and14IDWs.
Reopen found36/36 existing references and104constraints; all were up-to-date,
none suppressed. One grounded frame; rotor's angular DOF remains free. Pads are
parameter-driven opposed axial coordinates (not a free actuator mechanism).

Official COM solved wheel angles0,45,90,180,270degrees and0/.35mm pad stroke.
Native AnalyzeInterference returned0pairs in each of7poses. Solver propagated
rotor constraints; an earlier transform-only check did not and was discarded.
No continuous sweep, rolling contact, cable flex, installed fastener clearance,
impact, strength or actual brake performance was verified. Assembly was saved
released at0degrees, reopened, and left accessible in visible Inventor.

Corrections included guide pins moved outside the disc sweep, encoder support
relocated away from wheel, hub rearPCD32/frontPCD28 separated, and caliper base
M3 tap drills matched frame clearance holes. Native geometry exports correspond
to corrected v4, not obsolete earlier guide-pin positions.

## PARTIAL: qualification

CandidateFAULHABER4221G024BXTH(non-SC): the official drawing was rendered and
visually read. Mounting and external envelope are verified; cable options,
shaft material and final torque/speed/thermal behavior under Micro PWM are not.
Catalogue units use DC equivalent current. AN190sinusoidal phaseRMS/DCeq=.78
was used to derive Kt~.03418Nm/phase-peak-A; this is a documented conversion
assumption, not a commissioned ODrive value.2.87ADCeq corresponds~3.17Aphasepeak.

ODriveMicro at24V,40mNm and assumed5mNmdrag gives~4.81s to3330rpm using actual
rotating inertia. Approximate voltage-headroom screening with78% modulation
is NOT a measured loaded speed curve. Micro3.5Afreeair25°C/7Apeak current
ratings and enclosure thermal/firmware behavior require qualification. No
onboard dump-resistor capacity is assumed;~29.3J braking energy must remain in
mechanical brake or go into a qualified regenerative sink. An ordinary bench
supply must not be assumed to absorb regen. No current/FOC commissioning occurred.

Disc vs band: disc requires equal normal forces but behaves symmetrically for
both rotation signs, avoids tight/slack-band reversal, and allows independent
shaft support. Band+servo was not selected from stall torque alone. Opposed
linings, guide mechanism and bracket are actual solids; actuator/springs,
friction material and fastener retention are unresolved.4Nm performance remains
Calculated/Assumption, never measured. Brake/motor radial load is carried by the
independent6000bearing housing; compliant coupling load isolation remains HOLD.

## CAD mass / changed feasibility

Wheel four-part stack151.8469g,Jz0.00047409235kgm²;native module892.9687g.
All values depend on CAD library density proxies, simple bearing solid rings,
and140g motor-body override plus shaft proxy. Actuator, actual driver, full
fastener/cable/battery masses are excluded. These are actual CAD properties,
not measured parts or production mass.

COM=(8.9454,0.0021,20.0596)mm. Native centroidal inertia terms kgm²:
Ixx=.00206045675,Iyy=.00247818268,Izz=.00273841732,
Ixy=2.7527e-8,Iyz=-4.0986e-8,Ixz=-5.95170e-5.
Raw Autodesk XYZ partial terms are provided in JSON; off-diagonal convention
must be cross-checked before simulation tensor import. Axis+Z is wheel spin.
Whole-cube200mm/1.40kg/80%impulse-transfer screen now requires~5188rpm, not3330.
Three independent modules weigh~2.68kg before electronics/battery. A lighter
sharedframe and new inertia/packaging study are mandatory; self-righting remains
BLOCKED, not simulated successfully.

## Outputs / public safety

37STEP,3STL,14nativeIDW/PDF and seven nativeviewport PNGs plus write-test PNG actually generated.
All14single-pagePDFs rendered and inspected; views/HOLDnotes readable. Each has
2native dimensions; full manufacturing annotations remain incomplete. STLunits
are exported mm and checked by bounding boxes. NativeIPT/IAM/IDW files retain
local reference metadata, so stay local; generated neutralgeometry/scripts/
reports are public. No third-party CAD/code/vendorPDF copied. Publicmetadata
uses project author, no private workstation paths. Existing1axisCAD untouched.

ComputerUse failed before UI interactions. Therefore browser-tree and native
MassProperties/Interference dialog screenshots are NOT COMPLETED. Viewport
images are Inventor ActiveView captures and JSON is actual native API evidence.

## Source register

- [FAULHABER4221BXTHofficialdatasheet](https://www.faulhaber.com/fileadmin/Import/Media/EN_4221_BXTH_DFF.pdf),2026-07-28 table and dimensioned page2.
- [FAULHABERAN190](https://www.faulhaber.com/fileadmin/Import/Media/AN190_EN.pdf), current convention; loaded operating point still untested.
- [ODriveMicroofficialdatasheet](https://docs.odriverobotics.com/v/latest/hardware/micro-datasheet.html), accessed2026-10-08.
- [SKF6000-2Z](https://www.emarketplace.in.skf.com/deep-groove-ball-bearing/6000-2z),10×26×8/19g supplier data; CAD mass differs by simplified geometry.
- [SKF2018catalogue](https://www.skf.com/binaries/pub12/Images/0901d196807026e8-100-700_SKF_bearings_and_mounted_products_2018_tcm_12-314117.pdf), bearing load-screening data, not permission to substitute open-bearing speed for2Z.
- [AutodeskXYZMomentsOfInertia](https://help.autodesk.com/cloudhelp/2024/ENU/Inventor-API/files/MassProperties_XYZMomentsOfInertia.htm), centroid/reference-axis partial terms.

Next: qualify motor coupling, front retention stack, bidirectional clamp
actuator/lining and bracket strength on this one-wheel module before a complete
three-wheel host assembly. No purchase/order/power-on/rotation occurred.
