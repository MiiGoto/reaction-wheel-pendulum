"""Review-only drawing/BOM and native-vs-analytical mass checks; not fabrication."""
from pathlib import Path
import csv,json,re
import numpy as np

HERE=Path(__file__).resolve().parent
p=json.loads((HERE/'parameters.json').read_text())
n=json.loads((HERE/'native_review.json').read_text(encoding='utf-8-sig'))
parts=[x for x in p['parts'] if not x['name'].startswith('unplaced')]
m=sum(x['mass_kg'] for x in parts)
com=sum(x['mass_kg']*np.array(x['center_mm'])/1000 for x in parts)/m
I=np.zeros((3,3))
for x in parts:
    v=np.array(x['center_mm'])/1000-com
    I+=np.array(x['inertia_centroid_kg_m2'])+x['mass_kg']*((v@v)*np.eye(3)-np.outer(v,v))
native=n['centroid_inertia_native_terms_kg_m2'];a,b,c,xy,yz,xz=native
converted=np.array([[a,xy,xz],[xy,b,yz],[xz,yz,c]])
masserr=abs(m-n['mass_kg']);comerr=np.linalg.norm(com*1000-np.array(n['com_from_cube_center_mm']))
inertiaerr=np.max(np.abs(I-converted))
assert masserr<1e-7 and comerr<1e-4 and inertiaerr<1e-7,(masserr,comerr,inertiaerr)
step=(HERE/'Cubli_clearance_concept.step').read_text()
assert not re.search(r'(?i)(C:[/\\]|Users[/\\]|@)',step)
breps=len(re.findall(r'=\s*MANIFOLD_SOLID_BREP\s*\(',step))
report=dict(status='NATIVE_VS_ANALYTICAL_ASSUMED_MASS_CHECK',native_occurrences=n['occurrences'],native_mass_kg=n['mass_kg'],mass_error_kg=masserr,com_error_mm=float(comerr),centroid_inertia_error_kg_m2=float(inertiaerr),native_term_order='Ixx,Iyy,Izz,Ixy,Iyz,Ixz',native_offdiagonal_sign_verified_against_independent_composite_formula=True,centroid_inertia_tensor_kg_m2=converted.tolist(),step_manifold_solid_brep_entities=breps,STEP_reimport_not_yet_verified=True,unplaced_reserve_kg=.18,not_manufacturing_ready=True)
if (HERE/'step_reimport.json').exists():
    imported=json.loads((HERE/'step_reimport.json').read_text(encoding='utf-8-sig'))
    report['STEP_reimport_not_yet_verified']=not(imported.get('occurrences')==31 and imported.get('bounds_mm')==[180.,180.,180.])
(HERE/'geometry_validation.json').write_text(json.dumps(report,indent=2)+'\n')
with (HERE/'concept_bom.csv').open('w',newline='') as f:
    w=csv.writer(f);w.writerow(['Part','Quantity','Mass_kg','Material_or_method','Status'])
    for x in p['parts']:
        material='PETG assumed /3D print' if x['name'].startswith(('frame','corner')) else 'Envelope or unplaced reserve; material/part selection TBD'
        w.writerow([x['name'],1,x['mass_kg'],material,'REVIEW ONLY; not purchase or fabrication BOM'])
svg=['<svg xmlns="http://www.w3.org/2000/svg" width="1100" height="620" viewBox="0 0 1100 620">','<rect width="1100" height="620" fill="white"/>','<style>text{font-family:sans-serif;fill:#17324a} .frame{stroke:#738494;fill:none} .wheel{stroke:#2872b3;fill:none;stroke-width:3}</style>','<text x="30" y="32" font-size="22">Independent 3-axis clearance concept — NOT FOR FABRICATION</text>']
for i,(axes,name) in enumerate([((0,1),'XY / Z wheel'),((0,2),'XZ / Y wheel'),((1,2),'YZ / X wheel')]):
    cx=185+i*360;cy=255;scale=1.45
    svg.append(f'<text x="{cx-110}" y="75" font-size="18">{name}</text>')
    svg.append(f'<rect class="frame" x="{cx-90*scale}" y="{cy-90*scale}" width="{180*scale}" height="{180*scale}"/>')
    svg.append(f'<circle class="wheel" cx="{cx}" cy="{cy}" r="{65*scale}"/><circle class="wheel" cx="{cx}" cy="{cy}" r="{55*scale}"/>')
    for x in parts:
        if x['kind']!='box' or x['name'].startswith(('frame','corner')):continue
        c=np.array(x['center_mm']);s=np.array(x['size_mm']);ax,ay=axes
        svg.append(f'<rect x="{cx+(c[ax]-s[ax]/2)*scale}" y="{cy-(c[ay]+s[ay]/2)*scale}" width="{s[ax]*scale}" height="{s[ay]*scale}" fill="none" stroke="#de8b35"/>')
    svg.append(f'<text x="{cx-100}" y="415">180 mm provisional envelope</text>')
svg+=['<text x="30" y="465">Wheel: OD130 / ID110 / thickness8.842 mm; 90g assumed. No spokes or hub retention.</text>','<text x="30" y="495">Axes orthogonal; wheel plane centers +80mm. Native31 solids; guards/brakes/fasteners absent.</text>','<text x="30" y="525">Orange: projected PCB/battery/driver clearance boxes. Projection overlap is not 3D collision.</text>','<text x="30" y="555">No manufacturing tolerances, screw depths, safe RPM or material allowables are specified.</text>','</svg>']
(HERE/'concept_review.svg').write_text('\n'.join(svg)+'\n',encoding='utf-8')
# Independent parameter projection, deliberately labelled as a drawing, not a screenshot.
from PIL import Image,ImageDraw
im=Image.new('RGB',(1100,620),'white');draw=ImageDraw.Draw(im)
draw.text((30,25),'Independent 3-axis clearance concept - NOT FOR FABRICATION',fill='black')
for i,(axes,name) in enumerate([((0,1),'XY / Z wheel'),((0,2),'XZ / Y wheel'),((1,2),'YZ / X wheel')]):
    cx=185+i*360;cy=255;s=1.45
    draw.text((cx-110,75),name,fill='black')
    draw.rectangle((cx-90*s,cy-90*s,cx+90*s,cy+90*s),outline='#738494',width=2)
    for r in [55,65]:draw.ellipse((cx-r*s,cy-r*s,cx+r*s,cy+r*s),outline='#2872b3',width=3)
    for x in parts:
        if x['kind']!='box' or x['name'].startswith(('frame','corner')):continue
        c=np.array(x['center_mm']);size=np.array(x['size_mm']);a,b=axes
        draw.rectangle((cx+(c[a]-size[a]/2)*s,cy-(c[b]+size[b]/2)*s,cx+(c[a]+size[a]/2)*s,cy-(c[b]-size[b]/2)*s),outline='#de8b35',width=2)
    draw.text((cx-105,410),'180 mm provisional envelope',fill='black')
for y,line in [(465,'Wheel OD130 / ID110 / thickness8.842mm; no spokes or hub retention.'),(495,'Native31 solids. Guards, brakes, shafts, fasteners and cables are not complete.'),(525,'Orange boxes: controller, battery and driver projections; overlap is not 3D collision.'),(555,'Parameter projection, not an Inventor screenshot. No safe RPM or fabrication tolerances.')]:draw.text((30,y),line,fill='black')
im.save(HERE/'concept_review.png')
print(json.dumps(report,indent=2))
