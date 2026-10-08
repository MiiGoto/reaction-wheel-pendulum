# Cubli Rev B actual CAD review artifacts

Status: native one-wheel and three-axis packing CAD created, read back and exported.
Self-righting/rapid brake/manufacture remain HOLD. See ../../docs/cubli_revb_review.md.

Local native model: local_native_b3/Cubli_OneWheel_Module_RevB.iam.
Integration: local_study_b2/Cubli_ThreeAxis_Integration_Study.iam.
Native models retain absolute references and are intentionally excluded from public Git.
All neutral models and scripts are independently authored; vendor datasheets/CAD are not redistributed.

## Actual outputs

53 Rev B IPTs; constrained IAM155 healthy constraints;4 wheel comparison IAMs;
standalone/shared three-axis IAMs;68 validated/exported native model files,
68 STEP,3 STL,20 review IDW/PDF sheets.4 sheets lack associative dimensions,
and additional production-drawing layout is required. All are HOLD, not fabrication approval.
Actual native poses0/5/10mm in brake_kinematics_native.json and seven viewport PNGs.

## Reproduction with local Inventor2026 COM

Scripts are fresh PowerShell invocations; they use2025 interop only for enums and
explicitly reject a server that is not Inventor2026. Existing output folders are never overwritten.
1. Supply Rev A local native directory to build_revb.ps1 and build_study_parts.ps1.
2. Run refine_revb.ps1 then refine_revb_b3.ps1 for recorded local clearance corrections.
3. Run finalize_revb.ps1 with NativeDirectory=local_native_b3.
4. Duplicate only study IPTs from local_study_b1 to a new local_study_b2 directory,
then run integration_study.ps1. The native frame replacement is part of that script.
5. Run validate_exports.ps1 for save/reopen/reference/STEP checks.
6. Run drawings_revb.ps1 for initial review sheets and STL. Additional dimension/layout
helpers were not reliably completed and are local-only, not reproducible production output.
7. Run calculate_revb.py with NumPy for conditional CAD-based screens.

Do not execute purchase, power-on or spin operations. Source Rev A and1-axis designs remain untouched.
