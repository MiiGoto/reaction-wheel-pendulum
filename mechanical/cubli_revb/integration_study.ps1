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
if(-not $NativeDirectory){$NativeDirectory=Join-Path $PSScriptRoot 'local_study_b2'}
$NativeDirectory=[IO.Path]::GetFullPath($NativeDirectory)

$B2=Join-Path $PSScriptRoot 'local_native_b3';$at=$app.FileManager.GetTemplateFile([Inventor.DocumentTypeEnum]::kAssemblyDocumentObject,[Inventor.SystemOfMeasureEnum]::kMetricSystemOfMeasure)
function NewAssembly{$a=$app.Documents.Add([Inventor.DocumentTypeEnum]::kAssemblyDocumentObject,$at,$true);$a.PropertySets.Item('Inventor Summary Information').Item('Author').Value='Reaction Wheel Pendulum project';return $a}
function Tensor($d){$mp=$d.ComponentDefinition.MassProperties;[double]$xx=0;[double]$yy=0;[double]$zz=0;[double]$xy=0;[double]$yz=0;[double]$xz=0;$mp.XYZMomentsOfInertia([ref]$xx,[ref]$yy,[ref]$zz,[ref]$xy,[ref]$yz,[ref]$xz);return [pscustomobject]@{mass_kg=$mp.Mass;COM_mm=@(($mp.CenterOfMass.X*10),($mp.CenterOfMass.Y*10),($mp.CenterOfMass.Z*10));terms_kg_m2=@(($xx*.0001),($yy*.0001),($zz*.0001),($xy*.0001),($yz*.0001),($xz*.0001))}}
# Four real native wheel comparison assemblies, held stationary for mass comparison.
$wheelRows=@();foreach($variant in @('A','B','C','D')){$a=NewAssembly;foreach($part in @('01_Wheel_Rim','02_Wheel_Hub','03_Wheel_Spokes','07_Brake_Drum')){$file=Join-Path $B2 ($part+'.ipt');if($variant -eq 'A'){$file=Join-Path (Join-Path $PSScriptRoot 'local_rev_a_copy') ($part+'.ipt')};if($variant -eq 'B' -and $part -eq '01_Wheel_Rim'){$file=Join-Path $NativeDirectory '45_Rim_B_Aluminium.ipt'};if($variant -eq 'D' -and $part -eq '03_Wheel_Spokes'){$file=Join-Path $NativeDirectory '46_Spider_D_Polymer.ipt'};$o=$a.ComponentDefinition.Occurrences.Add($file,$tg.CreateMatrix());$o.Grounded=$true};[void]$a.Update2($false);$a.SaveAs((Join-Path $NativeDirectory ('Wheel_Comparison_'+$variant+'.iam')),$false);$v=Tensor $a;$wheelRows+=,[pscustomobject]@{variant=$variant;mass_kg=$v.mass_kg;Jz_kg_m2=$v.terms_kg_m2[2];COM_mm=$v.COM_mm;native_bytes=(Get-Item $a.FullFileName).Length}}
$wheelRows|ConvertTo-Json -Depth 5|Set-Content (Join-Path $PSScriptRoot 'wheel_comparison.json') -Encoding utf8
# Copy assembly; replace only its frame with lighter docking ribs. B2 remains unchanged.
$base=Join-Path $B2 'Cubli_OneWheel_Module_RevB.iam';$sharedFile=Join-Path $NativeDirectory 'Cubli_Shared_Module_RevB.iam';$d=$app.Documents.Open($base,$false);$d.SaveAs($sharedFile,$true);$d=$app.Documents.Open($sharedFile,$false);$frame=$d.ComponentDefinition.Occurrences|Where-Object {$_.Name -eq '11_Module_Frame'};$frame.Replace((Join-Path $NativeDirectory '40_Shared_Module_Dock.ipt'),$true);$frame.Name='11_Module_Frame';$frame.Grounded=$true;[void]$d.Update2($false);$d.Save();$sharedHealth=@();foreach($c in $d.ComponentDefinition.Constraints){$sharedHealth+=,$c.HealthStatus.ToString()}
$allReports=@();foreach($mode in @('Standalone','Shared')){
 $a=NewAssembly;$ac=$a.ComponentDefinition;$all=$app.TransientObjects.CreateObjectCollection();$placements=@(@(-35,35,72),@(72,-35,35),@(35,72,-35));$module=$base;if($mode -eq 'Shared'){$module=$sharedFile}
 $n=0;foreach($p in $placements){$m=$tg.CreateMatrix();if($n -eq 1){$m.SetToRotation(([Math]::PI/2),$tg.CreateVector(0,1,0),$tg.CreatePoint())};if($n -eq 2){$m.SetToRotation((-[Math]::PI/2),$tg.CreateVector(1,0,0),$tg.CreatePoint())};$m.SetTranslation($tg.CreateVector($p[0]/10,$p[1]/10,$p[2]/10),$false);$o=$ac.Occurrences.Add($module,$m);$o.Name='Module_'+@('Z','X','Y')[$n];$o.Grounded=$true;try{$o.Flexible=$true}catch{};$all.Add($o);$n++}
 $parts=@(@('41_Common_Cube_Frame',0,0,0),@('42_ODrive_Micro_Envelope',-110,-55,-105),@('42_ODrive_Micro_Envelope',-110,0,-105),@('42_ODrive_Micro_Envelope',-110,55,-105),@('43_Battery_Envelope_ASSUMPTION',-40,-110,-125),@('44_Controller_PCB_Envelope',-35,0,-125));$i=0;foreach($p in $parts){$m=$tg.CreateMatrix();$m.SetTranslation($tg.CreateVector($p[1]/10,$p[2]/10,$p[3]/10),$false);$o=$ac.Occurrences.Add((Join-Path $NativeDirectory ($p[0]+'.ipt')),$m);$o.Name=$p[0]+'_'+$i;$o.Grounded=$true;$all.Add($o);$i++}
 [void]$a.Update2($false);$name='Cubli_ThreeAxis_'+$mode;if($mode -eq 'Shared'){$name='Cubli_ThreeAxis_Integration_Study'};$file=Join-Path $NativeDirectory ($name+'.iam');$a.SaveAs($file,$false)
 $hits=$ac.AnalyzeInterference($all,$null);$pairs=@();foreach($hit in $hits){$pairs+=,[pscustomobject]@{a=$hit.OccurrenceOne.Name;b=$hit.OccurrenceTwo.Name;volume_mm3=($hit.Volume*1000)}};$v=Tensor $a;$allReports+=,[pscustomobject]@{mode=$mode;mass_kg=$v.mass_kg;COM_mm=$v.COM_mm;centroid_tensor_terms_kg_m2=$v.terms_kg_m2;interferences=$pairs;native_bytes=(Get-Item $file).Length;occurrences=$ac.Occurrences.Count;grounded_top_level='fixture envelopes; nested module constraints retained; no full-robot dynamics claim';missing_mass_reserve_kg=.15}
 $a.Activate();$cam=$app.ActiveView.Camera;$cam.ViewOrientationType=[Inventor.ViewOrientationTypeEnum]::kIsoTopRightViewOrientation;$cam.Apply();$app.ActiveView.Fit();$app.ActiveView.SaveAsBitmap((Join-Path $PSScriptRoot ('views/'+$name+'.bmp')),1600,1200)
 Write-Output ($mode+' integration mass '+$v.mass_kg+' kg; top-level pairs '+$pairs.Count)
}
[pscustomobject]@{Inventor=$app.SoftwareVersion.DisplayVersion;cube_external_mm=280;axes=@(@(1,0,0),@(0,1,0),@(0,0,1));allocation_rank=3;allocation_condition_number=1;module_shared_constraint_health=$sharedHealth;variants=$allReports;status='PARAMETRIC_INTEGRATION_STUDY_NOT_MANUFACTURING_RELEASE'}|ConvertTo-Json -Depth 9|Set-Content (Join-Path $PSScriptRoot 'integration_native_report.json') -Encoding utf8
