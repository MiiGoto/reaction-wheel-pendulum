"""Original feasibility model; assumptions, not a validated CAD or motor model.

Fixed ideal point pivot, orthogonal reaction rotors, quaternion RK4.
No unilateral contacts, impacts, brake-band model, noise, thermal or actual FOC.
"""
from pathlib import Path
import json
import math
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'mechanical/cubli_concept'
G = 9.80665
J = .5 * .09 * (.065**2 + .055**2)

def quatmul(a,b):
    return np.r_[a[0]*b[0]-a[1:]@b[1:], a[0]*b[1:]+b[0]*a[1:]+np.cross(a[1:],b[1:])]

def conj(q):
    return q*np.array([1.,-1.,-1.,-1.])

def matrix(q):
    w,x,y,z=q
    return np.array([[1-2*(y*y+z*z),2*(x*y-z*w),2*(x*z+y*w)],
                     [2*(x*y+z*w),1-2*(x*x+z*z),2*(y*z-x*w)],
                     [2*(x*z-y*w),2*(y*z+x*w),1-2*(x*x+y*y)]])

def dynamics(s,u,I,r,m):
    q=s[:4]/np.linalg.norm(s[:4]);w=s[4:7];spin=s[7:]
    gravity=np.cross(r,m*matrix(q).T@np.array([0,0,-G]))
    wd=np.linalg.solve(I,gravity-u-np.cross(w,(I+J*np.eye(3))@w+J*spin))
    return np.r_[.5*quatmul(q,np.r_[0,w]),wd,u/J-wd]

def conservation_check(model):
    I=np.array(model['body_inertia_corner_kg_m2']);Il=I+J*np.eye(3)
    s=np.r_[1.,0,0,0,.1,-.2,.3,2.,-3.,5.]
    def quantities(s):
        w=s[4:7];spin=s[7:]
        H=matrix(s[:4])@(Il@w+J*spin)
        E=.5*w@I@w+.5*J*((w+spin)@(w+spin))
        return H,E
    h0,e0=quantities(s);dt=.001
    for _ in range(1000):
        f=lambda y:dynamics(y,np.zeros(3),I,np.zeros(3),0.)
        a=f(s);b=f(s+dt*a/2);c=f(s+dt*b/2);d=f(s+dt*c)
        s+=dt*(a+2*b+2*c+d)/6;s[:4]/=np.linalg.norm(s[:4])
    h,e=quantities(s)
    dh=float(np.linalg.norm(h-h0));de=abs(e-e0)
    assert dh<1e-9 and de<1e-9,(dh,de)
    return dict(gravity_disabled=True,torque_zero=True,duration_s=1,world_angular_momentum_error_Nms=dh,kinetic_energy_error_J=de,passed=True)

def boxI(m,size):
    x,y,z=np.array(size)/1000
    return np.diag(m*np.array([y*y+z*z,x*x+z*z,x*x+y*y])/12)

def layout():
    parts=[]
    def add(name,m,c,size=None,axis=None,ro=0,ri=0,t=0):
        if size is not None:
            inertia=boxI(m,size)
            shape=dict(kind='box',size_mm=size)
        else:
            axial=.5*m*(ro**2+ri**2)
            transverse=m*(3*(ro**2+ri**2)+t*t)/12
            inertia=np.eye(3)*transverse
            inertia[axis,axis]=axial
            shape=dict(kind='annulus' if ri else 'cylinder',axis=axis,outer_radius_mm=ro*1000,inner_radius_mm=ri*1000,length_mm=t*1000)
        parts.append(dict(name=name,mass_kg=m,center_mm=c,inertia_centroid_kg_m2=inertia.tolist(),**shape))
    # Project-created clearance envelopes only. No motor mounting holes are guessed.
    for axis in range(3):
        c=[0,0,0];c[axis]=80
        add('wheel_'+str(axis),.09,c,axis=axis,ro=.065,ri=.055,t=.008841941)
        c=[0,0,0];c[axis]=60
        add('GB54_envelope_'+str(axis),.137,c,axis=axis,ro=.03035,t=.023)
        c=[0,0,0];c[axis]=42
        s=[32,32,32];s[axis]=7
        add('Micro_envelope_'+str(axis),.0081,c,size=s)
    # 12 rails plus 8 corner blocks form a 180mm cube clearance concept.
    for axis in range(3):
        other=[i for i in range(3) if i!=axis]
        for a in [-86,86]:
            for b in [-86,86]:
                c=[0,0,0];c[other[0]]=a;c[other[1]]=b
                s=[8,8,8];s[axis]=164
                add('frame_'+str(len(parts)),164*8*8*1.27/1e6,c,size=s)
    for x in [-86,86]:
        for y in [-86,86]:
            for z in [-86,86]:
                add('corner_'+str(len(parts)),8**3*1.27/1e6,[x,y,z],size=[8,8,8])
    add('controller_clearance',.04,[0,0,-55],size=[90,70,8])
    add('battery_clearance',.10,[0,0,0],size=[50,30,20])
    # Unplaced guards/brackets/wiring reserve: included in dynamics, absent geometry.
    add('unplaced_guard_mount_wire_reserve',.18,[0,0,0],size=[120,120,120])
    m=sum(p['mass_kg'] for p in parts)
    com=sum(p['mass_kg']*np.array(p['center_mm'])/1000 for p in parts)/m
    pivot=np.array([-.09,-.09,-.09])
    r=com-pivot
    locked=np.zeros((3,3))
    for p in parts:
        v=np.array(p['center_mm'])/1000-pivot
        locked+=np.array(p['inertia_centroid_kg_m2'])+p['mass_kg']*((v@v)*np.eye(3)-np.outer(v,v))
    body=locked-J*np.eye(3)
    assert np.linalg.eigvalsh(body).min()>0
    return dict(status='ANALYTICAL_CLEARANCE_ENVELOPES_NOT_NATIVE_MASS_PROPERTIES',board_size_mm=[90,70],cube_envelope_mm=180,mass_kg=m,com_from_cube_center_m=com.tolist(),com_from_corner_m=r.tolist(),locked_inertia_corner_kg_m2=locked.tolist(),body_inertia_corner_kg_m2=body.tolist(),wheel_spin_inertia_kg_m2=J,parts=parts)

def point_run(model,tilt_deg,cap=.2,speed_limit_rpm=250,dt=.002):
    m=model['mass_kg'];r=np.array(model['com_from_corner_m'])
    I=np.array(model['body_inertia_corner_kg_m2']);Il=I+J*np.eye(3)
    n=r/np.linalg.norm(r);z=np.array([0.,0.,1.])
    axis=np.cross(n,z);axis/=np.linalg.norm(axis);angle=math.acos(n@z)
    qd=np.r_[math.cos(angle/2),axis*math.sin(angle/2)]
    perturb=np.r_[math.cos(math.radians(tilt_deg)/2),math.sin(math.radians(tilt_deg)/2),0,0]
    state=np.r_[quatmul(qd,perturb),np.zeros(6)]
    command=np.zeros(3);peak=0.;peak_torque=0.;settled=True;limit_hits=0
    def rhs(s,u):
        return dynamics(s,u,I,r,m)
    for k in range(round(10/dt)):
        q=state[:4];w=state[4:7];spin=state[7:]
        err=quatmul(conj(q),qd)
        if err[0]<0:err=-err
        grav=np.cross(r,m*matrix(q).T@np.array([0,0,-G]))
        nxt=np.clip(grav-np.cross(w,Il@w+J*spin)-3.*2*err[1:]+.6*w,-cap,cap)
        blocked=(np.abs(spin)>speed_limit_rpm*2*math.pi/60)&(nxt*spin>0)
        limit_hits+=int(np.count_nonzero(blocked));nxt[blocked]=0
        a=rhs(state,command);b=rhs(state+dt*a/2,command);c=rhs(state+dt*b/2,command);d=rhs(state+dt*c,command)
        state+=dt*(a+2*b+2*c+d)/6;state[:4]/=np.linalg.norm(state[:4])
        command=nxt
        peak=max(peak,float(np.max(np.abs(state[7:]))*60/(2*math.pi)))
        peak_torque=max(peak_torque,float(np.max(np.abs(command))))
        error_angle=2*math.acos(min(1.,abs(quatmul(conj(state[:4]),qd)[0])))
        if k*dt>=3 and (error_angle>math.radians(.5) or np.linalg.norm(state[4:7])>.03):settled=False
    return dict(initial_tilt_deg=tilt_deg,settled_after_3s_for_10s=settled,peak_relative_wheel_rpm=peak,peak_command_Nm=peak_torque,saturation_samples=limit_hits,final_orientation_error_deg=math.degrees(error_angle))

def screening():
    m=1.2;a=.18;edgeI=2*m*a*a/3
    barrier=m*G*a*(1/math.sqrt(2)-.5)
    requiredH=math.sqrt(2*edgeI*barrier)
    rpm=33*24;omega=rpm*2*math.pi/60
    kt=8.27/33
    return dict(status='ASSUMPTION_SCREEN_NOT_MOTOR_RATING',uniform_cube_mass_kg=m,cube_side_m=a,edge_pivot_inertia_kg_m2=edgeI,face_to_edge_gravity_barrier_J=barrier,ideal_instant_brake_required_H_Nms=requiredH,one_wheel_required_rpm=requiredH/J*60/(2*math.pi),GB54_24V_KV_no_load_ceiling_rpm=rpm,one_wheel_H_at_ceiling_Nms=J*omega,optimistic_three_wheel_sum_H_Nms=3*J*omega,three_orthogonal_equal_wheel_vector_H_Nms=math.sqrt(3)*J*omega,one_wheel_energy_at_ceiling_J=.5*J*omega**2,catalog_torque_Nm=.33,catalog_torque_NOT_max_or_continuous_verified=True,estimated_Kt_Nm_A=kt,estimated_Iq_at_catalog_torque_A=.33/kt,phase_resistance_assumption_ohm=[7.8,15.6],copper_loss_at_catalog_torque_W=[1.5*(.33/kt)**2*x for x in [7.8,15.6]],ideal_braking_duration_s=J*omega/.33,ideal_braking_initial_power_W=.33*omega,three_wheel_energy_J=3*.5*J*omega**2,minimum_C_for_all_energy_24_to_30V_F=2*(3*.5*J*omega**2)/(30**2-24**2),edge_gravity_torque_at_face_Nm=m*G*a/2,momentum_saturation_time_at_0p02Nm_s=J*omega/.02)

def composite_edge_screen(model):
    # Edge parallel body Z at(-90,-90,0)mm, initial face normal +Y.
    # Same component distribution used by point model, reserve included.
    rx,ry,_=model['com_from_corner_m'];m=model['mass_kg']
    # After ideal brake engagement the stopped-relative rotor rotates with body:
    # use locked inertia here, unlike the independently spinning control model.
    I=float(model['locked_inertia_corner_kg_m2'][2][2])
    barrier=m*G*(math.hypot(rx,ry)-ry)
    H=math.sqrt(2*I*barrier)
    return dict(status='COMPOSITE_ASSUMED_NATIVE_GEOMETRY_PLUS_RESERVE',edge_axis='body Z at(-90,-90,0)mm',initial_support_face_normal='body +Y',barrier_J=barrier,edge_locked_after_brake_inertia_kg_m2=I,required_impulse_Nms=H,one_annulus_required_rpm=H/J*60/(2*math.pi),no_contact_or_loss_validation=True)

def checks(model):
    # Only major wheel/motor/driver/controller/battery boxes; not full collisions.
    boxes=[]
    for p in model['parts']:
        if p['name'].startswith(('frame','corner','unplaced')):continue
        if p['kind']=='box':size=np.array(p['size_mm'])
        else:
            size=np.full(3,2*p['outer_radius_mm']);size[p['axis']]=p['length_mm']
        c=np.array(p['center_mm']);boxes.append((p['name'],c-size/2,c+size/2))
    collisions=[]
    for i,(a,lo,hi) in enumerate(boxes):
        for b,bl,bh in boxes[i+1:]:
            if np.all(np.minimum(hi,bh)-np.maximum(lo,bl)>0):collisions.append([a,b])
    assert not collisions,collisions
    return dict(kind='AABB_CLEARANCE_ONLY',major_envelope_overlap_pairs=collisions,wheel_face_planes_mm=[80,80,80],minimum_orthogonal_wheel_AABB_gap_mm=80-8.841941/2-65,not_checked=['brake','shafts','fasteners','cables','full guards','moving contacts','service access'])

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    model=layout()
    # Conservation check at zero gravity would require a different RHS;
    # exact upright zero-command equilibrium checks torque/sign numerically.
    results=dict(assumptions=['ideal fixed corner pivot','assumed composite envelope mass','ideal measured quaternion','500Hz with one-step command delay','hypothetical 0.2Nm torque cap','250rpm drive-inhibition threshold not hard or safety speed limit','no voltage-current FOC or impact model'],layout= {k:v for k,v in model.items() if k!='parts'},clearance=checks(model),self_righting=screening(),point_cases=[point_run(model,x) for x in [0,.5,1,2,-1]],can_budget={})
    coarse=point_run(model,1,dt=.002);fine=point_run(model,1,dt=.001)
    delta=abs(coarse['peak_relative_wheel_rpm']-fine['peak_relative_wheel_rpm'])
    # Sampling and command delay both change: this is sampled-model sensitivity,
    # not a pure integrator step convergence test.
    results['sample_rate_sensitivity']={'500Hz':coarse,'1000Hz':fine,'peak_rpm_difference':delta,'scope':'sample time and one-step delay change together'}
    results['conservation_check']=conservation_check(model)
    results['composite_edge_screen']=composite_edge_screen(model)
    for hz in [500,1000]:
        # Conservative stuffed lengths incl intermission: DLC4=95, DLC8=135 bits.
        bits=3*hz*95+3*100*135+3*10*135+3*10*135+3*1*135
        results['can_budget'][str(hz)]={'command_hz_per_node':hz,'encoder_hz_per_node':100,'heartbeat_hz_per_node':10,'bus_telemetry_hz_per_node':10,'temperature_hz_per_node':1,'conservative_bus_load_percent':bits/1e6*100,'arbitration_retries_not_included':True}
    (OUT/'parameters.json').write_text(json.dumps(model,indent=2)+'\n')
    (OUT/'screening_results.json').write_text(json.dumps(results,indent=2)+'\n')
    print(json.dumps({k:v for k,v in results.items() if k!='layout'},indent=2))

if __name__=='__main__':main()
