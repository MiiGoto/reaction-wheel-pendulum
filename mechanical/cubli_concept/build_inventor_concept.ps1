# Original clearance geometry only. Refuses to overwrite an existing native study.
param([string]$NativeDirectory)
$ErrorActionPreference='Stop'
Add-Type -Path 'C:/Program Files/Autodesk/Inventor 2025/Bin/Autodesk.Inventor.Interop.dll'
$app=New-Object -ComObject Inventor.Application
$data=Get-Content (Join-Path $PSScriptRoot 'parameters.json') -Raw | ConvertFrom-Json
if(-not $NativeDirectory){$NativeDirectory=Join-Path $PSScriptRoot 'local_native'}
$NativeDirectory=[IO.Path]::GetFullPath($NativeDirectory)
if(Test-Path -LiteralPath $NativeDirectory){throw 'Refusing existing native directory'}
[void][IO.Directory]::CreateDirectory($NativeDirectory)
$pt=$app.FileManager.GetTemplateFile([Inventor.DocumentTypeEnum]::kPartDocumentObject,[Inventor.SystemOfMeasureEnum]::kMetricSystemOfMeasure)
$at=$app.FileManager.GetTemplateFile([Inventor.DocumentTypeEnum]::kAssemblyDocumentObject,[Inventor.SystemOfMeasureEnum]::kMetricSystemOfMeasure)
$tg=$app.TransientGeometry
$assembly=$app.Documents.Add([Inventor.DocumentTypeEnum]::kAssemblyDocumentObject,$at,$false)
$rows=[Collections.Generic.List[object]]::new()
foreach($p in $data.parts){
 if($p.name -eq 'unplaced_guard_mount_wire_reserve'){continue}
 $doc=$app.Documents.Add([Inventor.DocumentTypeEnum]::kPartDocumentObject,$pt,$false)
 $doc.PropertySets.Item('Inventor Summary Information').Item('Author').Value='Reaction Wheel Pendulum project'
 $doc.PropertySets.Item('Design Tracking Properties').Item('Part Number').Value=$p.name
 $sk=$doc.ComponentDefinition.Sketches.Add($doc.ComponentDefinition.WorkPlanes.Item(3),$false)
 $tr=$tg.CreateMatrix()
 if($p.kind -eq 'box'){
  $w=$p.size_mm[0]/10;$h=$p.size_mm[1]/10;$depth=$p.size_mm[2]/10
  [void]$sk.SketchLines.AddAsTwoPointRectangle($tg.CreatePoint2d(-$w/2,-$h/2),$tg.CreatePoint2d($w/2,$h/2))
  $tr.SetTranslation($tg.CreateVector($p.center_mm[0]/10,$p.center_mm[1]/10,($p.center_mm[2]/10-$depth/2)),$false)
 }else{
  $depth=$p.length_mm/10
  [void]$sk.SketchCircles.AddByCenterRadius($tg.CreatePoint2d(0,0),($p.outer_radius_mm/10))
  if($p.inner_radius_mm -gt 0){[void]$sk.SketchCircles.AddByCenterRadius($tg.CreatePoint2d(0,0),($p.inner_radius_mm/10))}
  if($p.axis -eq 0){$tr.SetToRotation([Math]::PI/2,$tg.CreateVector(0,1,0),$tg.CreatePoint(0,0,0))}
  if($p.axis -eq 1){$tr.SetToRotation(-[Math]::PI/2,$tg.CreateVector(1,0,0),$tg.CreatePoint(0,0,0))}
  $v=@(($p.center_mm[0]/10),($p.center_mm[1]/10),($p.center_mm[2]/10));$v[$p.axis]-=$depth/2
  $tr.SetTranslation($tg.CreateVector($v[0],$v[1],$v[2]),$false)
 }
 $def=$doc.ComponentDefinition.Features.ExtrudeFeatures.CreateExtrudeDefinition($sk.Profiles.AddForSolid($true,$null,$null),[Inventor.PartFeatureOperationEnum]::kJoinOperation)
 [void]$def.SetDistanceExtent($depth,[Inventor.PartFeatureExtentDirectionEnum]::kPositiveExtentDirection)
 [void]$doc.ComponentDefinition.Features.ExtrudeFeatures.Add($def)
 $sk.Visible=$false
 [void]$doc.Update2($false)
 if($doc.ComponentDefinition.SurfaceBodies.Count -ne 1){throw 'Not one solid'}
 $doc.ComponentDefinition.MassProperties.Mass=$p.mass_kg
 $file=Join-Path $NativeDirectory ($p.name+'.ipt')
 $doc.SaveAs($file,$false)
 $occ=$assembly.ComponentDefinition.Occurrences.Add($file,$tr);$occ.Grounded=$true
 $rows.Add([pscustomobject]@{part=$p.name;mass_kg=$doc.ComponentDefinition.MassProperties.Mass;mass_override_assumed=$true})
 $doc.Close($true)
}
$assembly.PropertySets.Item('Inventor Summary Information').Item('Author').Value='Reaction Wheel Pendulum project'
[void]$assembly.Update2($false)
$mp=$assembly.ComponentDefinition.MassProperties
[double]$xx=0;[double]$yy=0;[double]$zz=0;[double]$xy=0;[double]$xz=0;[double]$yz=0
$mp.XYZMomentsOfInertia([ref]$xx,[ref]$yy,[ref]$zz,[ref]$xy,[ref]$yz,[ref]$xz)
$com=$mp.CenterOfMass
$oc=$app.TransientObjects.CreateObjectCollection()
foreach($o in $assembly.ComponentDefinition.Occurrences){$oc.Add($o)}
$hits=$assembly.ComponentDefinition.AnalyzeInterference($oc,$null)
$pairs=@();foreach($hit in $hits){$pairs+=,@($hit.OccurrenceOne.Name,$hit.OccurrenceTwo.Name)}
$assembly.SaveAs((Join-Path $NativeDirectory 'Cubli_clearance_concept.iam'),$false)
$report=[ordered]@{status='NATIVE_CLEARANCE_STUDY_WITH_ASSUMED_MASS';Inventor_version=$app.SoftwareVersion.DisplayVersion;occurrences=$assembly.ComponentDefinition.Occurrences.Count;mass_kg=$mp.Mass;com_from_cube_center_mm=@(($com.X*10),($com.Y*10),($com.Z*10));centroid_inertia_native_terms_kg_m2=@(($xx*.0001),($yy*.0001),($zz*.0001),($xy*.0001),($yz*.0001),($xz*.0001));native_term_order='Ixx,Iyy,Izz,Ixy,Iyz,Ixz';product_of_inertia_sign_requires_explicit_conversion=$true;unplaced_reserve_excluded_kg=.18;interference_pairs=$pairs;parts=$rows}
$report | ConvertTo-Json -Depth 8 | Set-Content (Join-Path $PSScriptRoot 'native_review.json') -Encoding utf8
$step=$app.ApplicationAddIns.ItemById('{90AF7F40-0C01-11D5-8E83-0010B541CD80}')
$ctx=$app.TransientObjects.CreateTranslationContext();$ctx.Type=[Inventor.IOMechanismEnum]::kFileBrowseIOMechanism
$opt=$app.TransientObjects.CreateNameValueMap()
if(-not $step.HasSaveCopyAsOptions($assembly,$ctx,$opt)){throw 'STEP export unavailable'}
$opt.Value('ApplicationProtocolType')=3;$opt.Value('Author')='Reaction Wheel Pendulum project';$opt.Value('Organization')='';$opt.Value('Authorization')=''
$medium=$app.TransientObjects.CreateDataMedium();$medium.FileName=Join-Path $PSScriptRoot 'Cubli_clearance_concept.step'
$step.SaveCopyAs($assembly,$ctx,$opt,$medium)
# Headless documents cannot reliably Activate; do not change existing user views.
# Review SVG is generated independently by review_geometry.py, not a native screenshot.
$report | ConvertTo-Json -Depth 4
