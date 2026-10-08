"""Pre-CAD screening; assumed geometry, not a manufacturing qualification.

No original CAD is edited. Fixed-edge integration cannot validate face/edge/point
contact transitions or slip. Wheel speeds below are requirements, not safe limits.
"""
import json
import math
from pathlib import Path
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
G = 9.80665


def size_case(side, diameter, wheel_mass):
    # Non-wheel budget is the earlier composite budget rounded upward. It does
    # not follow a new detailed CAD, and changing frame dimensions changes it.
    mass = .95 + 3 * wheel_mass
    ro, ri = diameter / 2, diameter / 2 - .010
    J = wheel_mass * (ro * ro + ri * ri) / 2
    I = 2 * mass * side * side / 3
    barrier = mass * G * side * (1 / math.sqrt(2) - .5)
    H = math.sqrt(2 * I * barrier)
    return dict(side_m=side, wheel_diameter_m=diameter,
                total_assumed_mass_kg=mass, each_wheel_mass_kg=wheel_mass,
                wheel_inertia_kg_m2=J, edge_locked_inertia_kg_m2=I,
                face_edge_barrier_J=barrier, ideal_required_H_Nms=H,
                ideal_required_rpm=H / J * 60 / (2 * math.pi),
                required_rpm_at_80pct_impulse_transfer=H / (.8 * J) * 60 / (2 * math.pi),
                edge_point_symmetric_barrier_J=mass * G * side * (math.sqrt(3)/2-1/math.sqrt(2)),
                initial_gravity_torque_Nm=mass * G * side / 2,
                status='ASSUMED_CENTERED_UNIFORM_BODY_NOT_NATIVE_CAD')


def fixed_edge(case, rpm, brake, dt=.00002):
    """One wheel aligned with pivot. Ideal engaged brake has constant torque.

    Body inertia excludes independently spinning axial inertia until lock.
    Integration retains wheel absolute angular velocity, then locks it to body.
    Floor constraint only prevents initial backward rotation. No slip solver.
    Contact force demand is reported to expose invalid fixed-edge assumptions.
    """
    m, a, J, IL = [case[k] for k in ('total_assumed_mass_kg', 'side_m',
                                    'wheel_inertia_kg_m2', 'edge_locked_inertia_kg_m2')]
    theta = omega = 0.
    wheel = rpm * 2 * math.pi / 60
    lock_time = None
    max_mu = 0.
    lift = False
    minimum_normal = math.inf
    for step in range(round(2 / dt)):
        time = step * dt
        rx = a / 2 * (math.cos(theta) - math.sin(theta))
        ry = a / 2 * (math.sin(theta) + math.cos(theta))
        torque = brake if lock_time is None else 0.
        alpha = (torque - m * G * rx) / (IL - J if lock_time is None else IL)
        if theta <= 0 and omega <= 0 and alpha < 0:
            theta = omega = 0.
            alpha = 0.
        else:
            lift = True
        fx = m * (-alpha * ry - omega * omega * rx)
        fy = m * (alpha * rx - omega * omega * ry + G)
        minimum_normal = min(minimum_normal, fy)
        if fy > 0:
            max_mu = max(max_mu, abs(fx) / fy)
        omega += alpha * dt
        theta += omega * dt
        if lock_time is None:
            wheel -= torque / J * dt
            if wheel <= omega:
                # Event correction conserves angular momentum of body+wheel.
                omega = ((IL - J) * omega + J * wheel) / IL
                wheel = omega
                lock_time = time + dt
        if theta >= math.pi / 4:
            return dict(rpm=rpm, brake_Nm=brake, crossed_edge_barrier=True,
                        crossing_s=time, lock_time_s=lock_time,
                        max_required_contact_mu=max_mu, minimum_normal_N=minimum_normal,
                        scope='FIXED_EDGE_ONLY; no catch, slip, impact, edge-to-point')
        if lift and omega < 0 and lock_time is not None:
            break
    return dict(rpm=rpm, brake_Nm=brake, crossed_edge_barrier=False,
                final_angle_deg=math.degrees(theta), lock_time_s=lock_time,
                max_required_contact_mu=max_mu, minimum_normal_N=minimum_normal,
                scope='FIXED_EDGE_ONLY; no catch, slip, impact, edge-to-point')


def main():
    A = np.eye(3)
    cases = [size_case(.160, .110, .090), size_case(.180, .130, .120),
             size_case(.200, .150, .150)]
    # Preliminary 200mm option; impulse allowance is an assumption, not measured.
    c = cases[-1]
    rpm = c['required_rpm_at_80pct_impulse_transfer']
    H = c['wheel_inertia_kg_m2'] * rpm * 2 * math.pi / 60
    E = .5 * c['wheel_inertia_kg_m2'] * (rpm * 2 * math.pi / 60)**2
    band = []
    for stopping_time in (.02, .05, .10):
        torque = H / stopping_time  # stationary-body estimate only
        for mu in (.15, .25, .35):
            wrap = 1.5 * math.pi
            ratio = math.exp(mu * wrap)
            slack = torque / (.055 * (ratio - 1))
            tight = ratio * slack
            band.append(dict(stop_s=stopping_time, mu_assumed=mu,
                             wrap_rad=wrap, drum_radius_m=.055,
                             stationary_brake_torque_Nm=torque,
                             slack_N=slack, tight_N=tight,
                             conservative_band_load_bound_N=slack+tight,
                             slack_actuator_torque_at_10mm_lever_Nm=slack*.010,
                             band_energy_per_stop_J=E))
    out = dict(status='DETAIL_CAD_GATE_NOT_PASSED',
               coordinate_system='right-handed body XYZ; wheel axes +X,+Y,+Z',
               allocation_matrix=A.tolist(), allocation_rank=int(np.linalg.matrix_rank(A)),
               allocation_condition_2=float(np.linalg.cond(A)), size_options=cases,
               band_sensitivity=band,
               fixed_edge_screen=[fixed_edge(c, rpm, b) for b in (2.,4.,8.)],
               timestep_check=dict(coarse=fixed_edge(c, rpm, 4., .00004),
                                   fine=fixed_edge(c, rpm, 4., .00002)),
               power=dict(three_wheel_energy_J=3*E,
                          ideal_capacitance_24_to_30V_F=2*3*E/(30**2-24**2),
                          all_electrical_stop_average_current_50ms_24V_A=3*E/(24*.05)),
               ring_stress=dict(al_density_assumed_kg_m3=2700,
                                thin_ring_hoop_stress_at_required_speed_Pa=2700*(rpm*2*math.pi/60*.075)**2,
                                exclusions=['spokes','hub','holes','fasteners','fatigue','guard','material certification']),
               blockers=['GB54 momentum deficit and unqualified mounting/thermal limits',
                         'band force exceeds unsupported cantilever motor shaft allowance',
                         'qualified brake actuator, separate wheel bearings, positive retention undefined',
                         'alternative motor/ODrive current convention and loaded speed require qualification',
                         'hybrid face-edge-point model, contact/catch and power absorber unfinished'])
    dest = ROOT/'mechanical'/'cubli_reva_review'/'feasibility.json'
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(json.dumps(out, indent=2)+'\n', encoding='utf-8', newline='\n')
    print(json.dumps({k:v for k,v in out.items() if k not in ('band_sensitivity',)}, indent=2))


if __name__ == '__main__':
    main()
