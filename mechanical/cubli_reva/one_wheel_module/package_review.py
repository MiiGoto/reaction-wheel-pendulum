from pathlib import Path
import json, math, csv, hashlib, struct
from PIL import Image,ImageDraw
from pypdf import PdfReader
b=Path('mechanical/cubli_reva/one_wheel_module')
r=json.loads((b/'native_module_report.json').read_text(encoding='utf-8-sig'))
J=r['wheel_Jz_kg_m2']; omega=3330*2*math.pi/60
rotor=[p for p in r['parts'] if p['group']=='rotor']
Jrot=sum(p['centroid_tensor_terms_kg_m2'][2]+p['mass_kg']*sum((v/1000)**2 for v in p['centroid_mm'][:2]) for p in rotor)+6.9e-6
mu=[.15,.25,.35];brake=[{'mu_assumption':u,'pad_normal_force_N_each':4/(2*u*.049),'bidirectional_torque_Nm':4} for u in mu]
F=4/.049; a=.00825; L=.020; d=.010;M=F*a;I=math.pi*d**4/64
sig=32*M/(math.pi*d**3);tau=16*4/(math.pi*d**3);vm=math.sqrt(sig**2+3*tau**2)
bodym=1.40;side=.200;Iedge=2*bodym*side**2/3;du=bodym*9.80665*side*(1/math.sqrt(2)-.5);Hreq=math.sqrt(2*Iedge*du)/.8
peakKt=.0377/(.78*math.sqrt(2));iq=.040/peakKt
E=.5*Jrot*omega**2
calc={'classification':'CALCULATED FROM CAD + EXPLICIT ASSUMPTIONS, NOT TESTED','wheel_J_kg_m2':J,'rotating_J_with_catalogue_motor_rotor_kg_m2':Jrot,'target_rpm':3330,'wheel_H_Nms':J*omega,'total_rotating_H_Nms':Jrot*omega,'stop_energy_J':E,'acceleration_assumed_command_Nm':.040,'drag_assumption_Nm':.005,'spinup_seconds_constant_net_torque':Jrot*omega/.035,'catalogue_DCeq_Kt_Nm_A':.0377,'sinusoidal_phase_RMS_per_DCeq_assumed_from_FA_application_note':.78,'derived_phase_peak_Kt_Nm_A':peakKt,'phase_peak_Iq_for_40mNm_A':iq,'catalogue_DCeq_nominal_A':2.87,'corresponding_phase_peak_nominal_A':2.87*.78*math.sqrt(2),'copper_loss_W_at_command':1.5*.37*iq**2,'speed_voltage_heuristic_rpm_NOT_curve':6040*.78,'brake':brake,'brake_nominal_stop_seconds':Jrot*omega/4,'brake_tangential_force_N':F,'bearing_reactions_nominal_N':[F*(1+a/L),-F*a/L],'shock_factor_assumption':3,'bearing_reactions_shock_N':[3*F*(1+a/L),-3*F*a/L],'shaft_bending_MPa':sig/1e6,'shaft_torsion_MPa':tau/1e6,'shaft_vonMises_3x_shock_MPa':vm*3/1e6,'shaft_vonMises_3x_shock_Kf2_MPa':vm*6/1e6,'shaft_tip_deflection_mm_shock':3*F*a*a*(L+a)/(3*210e9*I)*1000,'pad_axial_imbalance_10pct_N':brake[0]['pad_normal_force_N_each']*.1,'caliper_plate_deflection_mm_each_assumption':brake[0]['pad_normal_force_N_each']*.026**3/(3*69e9*(.080*.003**3/12))*1000,'actuator_required_force_N_each_pad':350,'actuator_required_closing_stroke_mm_minimum':1.2,'actuator_engagement_requirement_ms_unverified':20,'uniform_disc_single_stop_temp_rise_K_assumed_cp500':E/(next(p['mass_kg'] for p in r['parts'] if p['part']=='07_Brake_Drum')*500),'rim_thin_ring_hoop_MPa_3330':2700*(omega*.075)**2/1e6,'rim_thin_ring_hoop_MPa_5000':2700*(5000*2*math.pi/60*.075)**2/1e6,'old_1p4kg_cube_face_edge_Hreq_Nms_80pct':Hreq,'old_cube_required_rpm_with_actual_wheel_J':Hreq/J*60/(2*math.pi),'three_independent_module_mass_kg_NO_shared_frame':3*r['mass_kg'],'bearing_speed_2Z_status':'specific supplier speed rating must be frozen before operation','simulation_status':'no multibody self-righting simulation completed','FEA':'NOT STARTED','self_righting':'BLOCKED for former 1.40kg/3330rpm claim: actual J smaller and module mass greater'}
(b/'design_calculations.json').write_text(json.dumps(calc,indent=2)+'\n',encoding='utf-8')
rows=[]
for p in r['parts']:
 name=p['part'];material=p['material'];kind='fabricated';mpn='own parametric part';process='machining'
 if name.startswith(('08','10','11','12','19')):process='FDM or friction/PCB interface prototype - HOLD'
 if name.startswith('14'): kind='purchased';mpn='SKF 6000-2Z';process='catalogue bearing simplified envelope; CAD mass proxy'
 if name.startswith('15'): kind='purchased';mpn='FAULHABER 4221 G 024 BXT H, non-SC';process='manufacturer external geometry; 140g body mass override'
 if name.startswith('16'):mpn='included in FAULHABER motor';kind='included';process='motor shaft envelope'
 if name.startswith('18'):mpn='diametrical magnet 5x2 prototype size; MPN HOLD'
 if name.startswith('19'):mpn='AS5047P SPI IC candidate; sensor PCB MPN/geometry HOLD'
 if name.startswith('21'):mpn='custom external retaining clip; qualified standard MPN HOLD'
 if name.startswith('23'):mpn='ground guide pin dia3 x11; MPN HOLD'
 rows.append([name,name,1,material,round(p['mass_kg']*1000,4),process,mpn,kind,'HOLD: dimensions/material qualification per assembly instructions'])
for name,q,mpn,note in [('F01',6,'ISO 4762 M3x6','motor;0.5 washer+3 plate ->2.5 insertion <=3mm; verify actual stack'),('F02',6,'ISO 4762 M3x16 + M3 nuts','rim/spokes, washers; actual fastener clearance not modeled'),('F03',8,'ISO 4762 M3x5','4 rear disc/4 front spider;3mm engagement after washer'),('F04',8,'ISO 4762 M3x6','bearing retainer screws; holes outside seats'),('F05',4,'ISO 4762 M4x40 + M4 nuts','housing through frame, exact clamping stack HOLD'),('F06',4,'ISO 4762 M4x30 + M4 nuts','motor spacers, approximate measured clamping stack HOLD'),('F07',2,'ISO 4762 M3x10','caliper base into M3 tap holes'),('F08',4,'ISO 4762 M2x8 + M2 nuts','encoder PCB/bracket interface, board MPN HOLD'),('F09',4,'M4 module interface screws; length HOLD','168mm square interface, host-frame thickness TBD'),('F10',32,'ISO 7089 M3 washers','provisional count; reconcile stack drawing'),('F11',16,'ISO 7089 M4 washers','provisional count'),('A01',1,'bidirectional clamp actuator NOT SELECTED','>=350N each pad, >=1.2mm closing travel, <20ms engagement goal; response/duty/mass HOLD'),('A02',2,'return spring NOT SELECTED','fail-release behavior/retained spring travel HOLD'),('D01',1,'ODrive Micro','off-module electronics integration, regen sink required; NOT in CAD mass'),('E01',1,'AS5047P sensor PCB NOT SELECTED','sensor die/magnet alignment gap and MOSI high strap verify'),('P01',1,'24V regenerative-compatible source NOT SELECTED','no bench supply assumption of regen absorption'),('C01',1,'5-to10mm flexible coupling; current OWN proxy','clamp screw/positive locking and torsional compliance HOLD')]:
 rows.append([name,name,q,'purchased / certified material HOLD','TBD','purchased; not modeled',mpn,'purchased',note])
with (b/'BOM.csv').open('w',encoding='utf-8',newline='') as f:
 w=csv.writer(f);w.writerow(['Part ID','Part name','Quantity','Material','Mass g each','Manufacturing method','Manufacturer/MPN','Type','Notes']);w.writerows(rows)
files=[]
for p in (b/'local_native_v4').glob('*'):
 if p.suffix.lower() in ['.ipt','.iam']:files.append({'file':p.name,'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'public_git':False,'reason':'native reference metadata stays local'})
for p in (b/'local_native_v4'/'drawings').glob('*.idw'):files.append({'file':'drawings/'+p.name,'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'public_git':False})
(b/'native_file_inventory.json').write_text(json.dumps(files,indent=2)+'\n',encoding='utf-8')
write_test=Path('../inventor2026-write-test-20261008/Write_Test_10x10x2mm.ipt')
(b/'inventor_access.json').write_text(json.dumps({'Inventor_version':'2026.2','visible_GUI':True,'Computer_Use':False,'COM_API':True,'write_test_passed':True,'write_test_filename':'Write_Test_10x10x2mm.ipt','write_test_bytes':write_test.stat().st_size,'write_test_volume_mm3':200.0,'reopened_solid_bodies':1,'native_parts_saved':36,'native_assembly_saved':True,'native_drawings_saved':14,'interop_note':'2025 interop enum definitions only; connected server independently verified2026.2','evidence_limit':'native viewport captures; full UI browser and dialog screenshots unavailable'},indent=2)+'\n',encoding='utf-8')
privacy=[]
for p in (b/'drawings').glob('*.pdf'):
 rd=PdfReader(p);text='\n'.join(pg.extract_text() or '' for pg in rd.pages)
 privacy.append({'file':p.name,'pages':len(rd.pages),'has_hold':'HOLD' in text,'private_path':any(x in text for x in ['C:\\Users\\','C:/Users/']),'metadata':{str(k):str(v) for k,v in (rd.metadata or {}).items()}})
(b/'pdf_validation.json').write_text(json.dumps(privacy,indent=2)+'\n',encoding='utf-8')
imgs=[]
for p in sorted((b/'local_pdf_qa').glob('*.png')):
 im=Image.open(p).convert('RGB');im.thumbnail((600,430));tile=Image.new('RGB',(620,470),'white');tile.paste(im,(10,30));ImageDraw.Draw(tile).text((10,8),p.stem,fill='black');imgs.append(tile)
for n in range(0,len(imgs),6):
 sheet=Image.new('RGB',(1240,1410),'#cccccc')
 for i,im in enumerate(imgs[n:n+6]):sheet.paste(im,((i%2)*620,(i//2)*470))
 sheet.save(b/'local_pdf_qa'/f'montage_{n//6+1}.png')
print(json.dumps({k:calc[k] for k in ['wheel_J_kg_m2','spinup_seconds_constant_net_torque','stop_energy_J','old_cube_required_rpm_with_actual_wheel_J','shaft_vonMises_3x_shock_Kf2_MPa']},indent=2))
