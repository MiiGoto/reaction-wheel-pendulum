param([string]$NativeDirectory)
$ErrorActionPreference='Stop'
if(-not ('Inventor.DocumentTypeEnum' -as [type])){Add-Type -Path 'C:/Program Files/Autodesk/Inventor 2025/Bin/Autodesk.Inventor.Interop.dll'}
Add-Type @'
using System; using System.Runtime.InteropServices;
public static class FinalActive {
 [DllImport("oleaut32.dll",PreserveSig=false)] private static extern void GetActiveObject(ref Guid c,IntPtr r,[MarshalAs(UnmanagedType.IUnknown)] out object o);
 public static object Get(){var c=Type.GetTypeFromProgID("Inventor.Application",true).GUID; object o; GetActiveObject(ref c,IntPtr.Zero,out o);return o;}
}
'@
$app=[FinalActive]::Get();if($app.SoftwareVersion.DisplayVersion -notlike '2026*'){throw '2026 required'}
$app.Visible=$true;$tg=$app.TransientGeometry
if(-not $NativeDirectory){$NativeDirectory=Join-Path $PSScriptRoot 'local_native_b1'}
$NativeDirectory=[IO.Path]::GetFullPath($NativeDirectory)
$assemblyFile=Join-Path $NativeDirectory 'Cubli_OneWheel_Module_RevB.iam'
if(Test-Path -LiteralPath $assemblyFile){throw 'Assembly already exists; no automatic overwrite'}
$assembly=$app.Documents.Add([Inventor.DocumentTypeEnum]::kAssemblyDocumentObject,$app.FileManager.GetTemplateFile([Inventor.DocumentTypeEnum]::kAssemblyDocumentObject,[Inventor.SystemOfMeasureEnum]::kMetricSystemOfMeasure),$true)
$assembly.PropertySets.Item('Inventor Summary Information').Item('Author').Value='Reaction Wheel Pendulum project'
$ac=$assembly.ComponentDefinition;$occs=@{};$docs=@{};$rows=[Collections.Generic.List[object]]::new()
$rotor=@('01_Wheel_Rim','02_Wheel_Hub','03_Wheel_Spokes','04_Wheel_Shaft','07_Brake_Drum','13_Torsional_Coupling','13B_Coupling_Sleeve_5_6','16_Motor_Rotor_Shaft','18_Encoder_Magnet','20_Retaining_Washer','21_Retaining_Clip','25_Shaft_Key','26_Inner_Race_Spacer','27_Front_Hub_Shim','28_Clip_Stack_Shim')
foreach($f in (Get-ChildItem -LiteralPath $NativeDirectory -Filter '*.ipt'|Sort-Object Name)){
 $d=$app.Documents.Open($f.FullName,$false);$o=$ac.Occurrences.Add($f.FullName,$tg.CreateMatrix());$o.Name=$f.BaseName;$o.Grounded=$false;$occs[$f.BaseName]=$o;$docs[$f.BaseName]=$d
 $mp=$d.ComponentDefinition.MassProperties;[double]$xx=0;[double]$yy=0;[double]$zz=0;[double]$xy=0;[double]$yz=0;[double]$xz=0;$mp.XYZMomentsOfInertia([ref]$xx,[ref]$yy,[ref]$zz,[ref]$xy,[ref]$yz,[ref]$xz)
 $group='fixed';if($rotor -contains $f.BaseName){$group='rotor'};if($f.BaseName -like '08*' -or $f.BaseName -like '24*'){$group='pad';if($f.BaseName -in @('08_Brake_Mechanism','24_Lower_Pad_Carrier')){$group='pad_lower'}else{$group='pad_upper'}}
 if($f.BaseName -match '^(30_|32_|33_)'){$group='slider'}
 $rows.Add([pscustomobject]@{part=$f.BaseName;group=$group;bytes=$f.Length;solid_bodies=$d.ComponentDefinition.SurfaceBodies.Count;mass_kg=$mp.Mass;volume_mm3=($mp.Volume*1000);material=$d.ActiveMaterial.DisplayName;centroid_mm=@(($mp.CenterOfMass.X*10),($mp.CenterOfMass.Y*10),($mp.CenterOfMass.Z*10));centroid_tensor_terms_kg_m2=@(($xx*.0001),($yy*.0001),($zz*.0001),($xy*.0001),($yz*.0001),($xz*.0001));mass_override=($f.BaseName -match '^(13_Torsional|14|15_|21_|31_|32_|37_|38_)');mass_note='Material proxy or explicit catalogue/envelope override; see Rev B review'})
}
function Plane($o,$i){[object]$p=New-Object System.Object;$o.CreateGeometryProxy($o.Definition.WorkPlanes.Item($i),[ref]$p);return $p}
function Axis($o){[object]$p=New-Object System.Object;$o.CreateGeometryProxy($o.Definition.WorkAxes.Item(3),[ref]$p);return $p}
function Rigid($o,$b){foreach($i in @(1,2,3)){[void]$ac.Constraints.AddFlushConstraint((Plane $o $i),(Plane $b $i),0)}}
$frame=$occs['11_Module_Frame'];$shaft=$occs['04_Wheel_Shaft'];$frame.Grounded=$true
[void]$ac.Constraints.AddMateConstraint((Axis $shaft),(Axis $frame),0)
[void]$ac.Constraints.AddFlushConstraint((Plane $shaft 3),(Plane $frame 3),0)
$stroke=$ac.Parameters.UserParameters.AddByExpression('InputStroke','0 mm','mm')
foreach($row in $rows){$o=$occs[$row.part];if($row.part -in @('11_Module_Frame','04_Wheel_Shaft')){continue};if($row.group -like 'pad_*'){
 foreach($i in @(1,2)){[void]$ac.Constraints.AddFlushConstraint((Plane $o $i),(Plane $frame $i),0)}
 $c=$ac.Constraints.AddFlushConstraint((Plane $o 3),(Plane $frame 3),0);if($row.part -in @('08_Brake_Mechanism','24_Lower_Pad_Carrier')){$c.Offset.Expression='-0.065*InputStroke'}else{$c.Offset.Expression='0.035*InputStroke'};$c.Name='Brake_actuation_'+$row.part
 }elseif($row.group -eq 'slider'){foreach($i in @(1,3)){[void]$ac.Constraints.AddFlushConstraint((Plane $o $i),(Plane $frame $i),0)};$c=$ac.Constraints.AddFlushConstraint((Plane $o 2),(Plane $frame 2),0);$c.Offset.Expression='-InputStroke';$c.Name='Input_slider_'+$row.part
 }elseif($row.group -eq 'rotor'){Rigid $o $shaft}else{Rigid $o $frame}}
[void]$assembly.Update2($false);$assembly.SaveAs($assemblyFile,$false)
$assembly.Activate();$cam=$app.ActiveView.Camera;$cam.ViewOrientationType=[Inventor.ViewOrientationTypeEnum]::kIsoTopRightViewOrientation;$cam.Apply();$app.ActiveView.Fit();$app.ActiveView.SaveAsBitmap((Join-Path $PSScriptRoot 'views/module_assembly.bmp'),1600,1200)
$all=$app.TransientObjects.CreateObjectCollection();foreach($o in $ac.Occurrences){$all.Add($o)}
function Interferences($label){$hits=$ac.AnalyzeInterference($all,$null);$pairs=@();foreach($h in $hits){$pairs+=,[pscustomobject]@{a=$h.OccurrenceOne.Name;b=$h.OccurrenceTwo.Name;volume_mm3=($h.Volume*1000)}};return [pscustomobject]@{pose=$label;shaft_rotation_matrix11=$shaft.Transformation.Cell(1,1);lower_pad_translation_z_mm=($occs['08_Brake_Mechanism'].Transformation.Translation.Z*10);upper_pad_translation_z_mm=($occs['08B_Brake_Pad'].Transformation.Translation.Z*10);pairs=$pairs}}
$states=@();$states+=Interferences 'released';$stroke.Expression='5 mm';[void]$assembly.Update2($false);$states+=Interferences 'PARTIAL';$stroke.Expression='10 mm';[void]$assembly.Update2($false);$states+=Interferences 'pad_contact';$stroke.Expression='0 mm';[void]$assembly.Update2($false)
# Rotate the free shaft; solver propagates rigid rotor attachments.
foreach($deg in @(0,45,90,180,270)){$m=$tg.CreateMatrix();$m.SetToRotation(($deg*[Math]::PI/180),$tg.CreateVector(0,0,1),$tg.CreatePoint(0,0,0));$shaft.Transformation=$m;[void]$assembly.Update2($false);$states+=Interferences ('wheel_'+$deg)}
$shaft.Transformation=$tg.CreateMatrix();[void]$assembly.Update2($false);$assembly.Save()
$mp=$ac.MassProperties;[double]$xx=0;[double]$yy=0;[double]$zz=0;[double]$xy=0;[double]$yz=0;[double]$xz=0;$mp.XYZMomentsOfInertia([ref]$xx,[ref]$yy,[ref]$zz,[ref]$xy,[ref]$yz,[ref]$xz)
$wheelRows=@($rows|Where-Object {$_.part -in @('01_Wheel_Rim','02_Wheel_Hub','03_Wheel_Spokes','07_Brake_Drum')})
$health=@();foreach($c in $ac.Constraints){$health+=,[pscustomobject]@{name=$c.Name;health=$c.HealthStatus.ToString();suppressed=$c.Suppressed}}
$report=[ordered]@{Inventor=$app.SoftwareVersion.DisplayVersion;parts=$rows;occurrences=$ac.Occurrences.Count;constraints=$ac.Constraints.Count;constraint_health=$health;grounded=1;wheel_mass_kg=($wheelRows|Measure-Object mass_kg -Sum).Sum;wheel_Jz_kg_m2=($wheelRows|ForEach-Object {$_.centroid_tensor_terms_kg_m2[2]+$_.mass_kg*(($_.centroid_mm[0]/1000)*($_.centroid_mm[0]/1000)+($_.centroid_mm[1]/1000)*($_.centroid_mm[1]/1000))}|Measure-Object -Sum).Sum;mass_kg=$mp.Mass;COM_mm=@(($mp.CenterOfMass.X*10),($mp.CenterOfMass.Y*10),($mp.CenterOfMass.Z*10));assembly_centroid_tensor_terms_kg_m2=@(($xx*.0001),($yy*.0001),($zz*.0001),($xy*.0001),($yz*.0001),($xz*.0001));term_order='Ixx Iyy Izz Ixy Iyz Ixz';poses=$states;wheel_rotation='axis mate + axial flush, no angle lock';brake_actuation='InputStroke0..10mm; lower+0.65mm/upper-0.35mm; spring envelopes are not compressed in pose study';status='PARTIAL_PROTOTYPE_NATIVE; material proxies and procurement interfaces HOLD'}
$report|ConvertTo-Json -Depth 9|Set-Content (Join-Path $PSScriptRoot 'mass_properties.json') -Encoding utf8
Write-Output "Saved assembly $($ac.Occurrences.Count) occurrences/$($ac.Constraints.Count) constraints"
# Own model exports only. Native absolute references stay local.
$step=$app.ApplicationAddIns.ItemById('{90AF7F40-0C01-11D5-8E83-0010B541CD80}');$ctx=$app.TransientObjects.CreateTranslationContext();$ctx.Type=[Inventor.IOMechanismEnum]::kFileBrowseIOMechanism
function ExportStep($d,$name){$opt=$app.TransientObjects.CreateNameValueMap();[void]$step.HasSaveCopyAsOptions($d,$ctx,$opt);$opt.Value('ApplicationProtocolType')=3;$opt.Value('Author')='Reaction Wheel Pendulum project';$opt.Value('Organization')='';$opt.Value('Authorization')='';$medium=$app.TransientObjects.CreateDataMedium();$medium.FileName=Join-Path $PSScriptRoot ('step/'+$name+'.step');$step.SaveCopyAs($d,$ctx,$opt,$medium)}
ExportStep $assembly 'Cubli_OneWheel_Module_RevB'
foreach($name in $docs.Keys){ExportStep $docs[$name] $name}
$assembly.Activate();$app.ActiveView.Fit();$app.ActiveView.SaveAsBitmap((Join-Path $PSScriptRoot 'views/module_assembly.bmp'),1600,1200)
Write-Output ('Validation: '+$states.Count+' poses; mass '+$mp.Mass+' kg')
