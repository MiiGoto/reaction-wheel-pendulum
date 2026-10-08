param([Parameter(Mandatory=$true)][string]$RevADirectory,[string]$NativeDirectory)
$ErrorActionPreference='Stop'
# Enum-only compatibility interop; running server MUST be Inventor 2026.
if(-not ('Inventor.DocumentTypeEnum' -as [type])){Add-Type -Path 'C:/Program Files/Autodesk/Inventor 2025/Bin/Autodesk.Inventor.Interop.dll'}
Add-Type @'
using System; using System.Runtime.InteropServices;
public static class ModuleActive {
 [DllImport("oleaut32.dll",PreserveSig=false)] private static extern void GetActiveObject(ref Guid c,IntPtr r,[MarshalAs(UnmanagedType.IUnknown)] out object o);
 public static object Get(){var c=Type.GetTypeFromProgID("Inventor.Application",true).GUID; object o; GetActiveObject(ref c,IntPtr.Zero,out o);return o;}
}
'@
$app=[ModuleActive]::Get();if($app.SoftwareVersion.DisplayVersion -notlike '2026*'){throw '2026 required'}
$app.Visible=$true;$tg=$app.TransientGeometry
if(-not $NativeDirectory){$NativeDirectory=Join-Path $PSScriptRoot 'local_study_b1'}
$NativeDirectory=[IO.Path]::GetFullPath($NativeDirectory)
if(Test-Path -LiteralPath $NativeDirectory){throw 'Refuse overwrite of existing native output'}
[void][IO.Directory]::CreateDirectory($NativeDirectory)
foreach($folder in @('step','views')){[void][IO.Directory]::CreateDirectory((Join-Path $PSScriptRoot $folder))}
$pt=$app.FileManager.GetTemplateFile([Inventor.DocumentTypeEnum]::kPartDocumentObject,[Inventor.SystemOfMeasureEnum]::kMetricSystemOfMeasure)
$at=$app.FileManager.GetTemplateFile([Inventor.DocumentTypeEnum]::kAssemblyDocumentObject,[Inventor.SystemOfMeasureEnum]::kMetricSystemOfMeasure)
$rows=[Collections.Generic.List[object]]::new();$occs=@{};$docs=@{}
$assembly=$app.Documents.Add([Inventor.DocumentTypeEnum]::kAssemblyDocumentObject,$at,$true)
$ac=$assembly.ComponentDefinition
$assembly.PropertySets.Item('Inventor Summary Information').Item('Author').Value='Reaction Wheel Pendulum project'
function Sketch($z){$plane=$script:doc.ComponentDefinition.WorkPlanes.AddByPlaneAndOffset($script:doc.ComponentDefinition.WorkPlanes.Item(3),($z/10),$false);$plane.Visible=$false;return $script:doc.ComponentDefinition.Sketches.Add($plane,$false)}
function Extrude($sk,$depth,$cut=$false){$f=$script:doc.ComponentDefinition.Features.ExtrudeFeatures;$op=[Inventor.PartFeatureOperationEnum]::kJoinOperation;if($cut){$op=[Inventor.PartFeatureOperationEnum]::kCutOperation};$d=$f.CreateExtrudeDefinition($sk.Profiles.AddForSolid(),$op);$d.SetDistanceExtent(($depth/10),[Inventor.PartFeatureExtentDirectionEnum]::kPositiveExtentDirection);[void]$f.Add($d);$sk.Visible=$false}
function Ring($ro,$ri,$z,$depth,$cut=$false){$s=Sketch $z;[void]$s.SketchCircles.AddByCenterRadius($tg.CreatePoint2d(0,0),($ro/10));if($ri -gt 0){[void]$s.SketchCircles.AddByCenterRadius($tg.CreatePoint2d(0,0),($ri/10))};Extrude $s $depth $cut}
function Box([double]$x,[double]$y,[double]$w,[double]$h,[double]$z,[double]$depth,$cut=$false){$s=Sketch $z;[void]$s.SketchLines.AddAsTwoPointRectangle($tg.CreatePoint2d(($x-$w/2)/10,($y-$h/2)/10),$tg.CreatePoint2d(($x+$w/2)/10,($y+$h/2)/10));Extrude $s $depth $cut}
function Hole($x,$y,$r,$z,$depth){$s=Sketch $z;[void]$s.SketchCircles.AddByCenterRadius($tg.CreatePoint2d($x/10,$y/10),($r/10));Extrude $s $depth $true}
function BoltCircle($n,$radius,$hole,$z,$depth,$start=0){for($i=0;$i -lt $n;$i++){$a=($start+$i*360/$n)*[Math]::PI/180;Hole ($radius*[Math]::Cos($a)) ($radius*[Math]::Sin($a)) $hole $z $depth}}
function Corners($x,$y,$r,$z,$depth){foreach($ix in @(-1,1)){foreach($iy in @(-1,1)){Hole ($ix*$x) ($iy*$y) $r $z $depth}}}
function NewPart($name,$material){$script:partName=$name;$script:doc=$app.Documents.Add([Inventor.DocumentTypeEnum]::kPartDocumentObject,$pt,$false);$script:doc.PropertySets.Item('Inventor Summary Information').Item('Author').Value='Reaction Wheel Pendulum project';$script:doc.PropertySets.Item('Design Tracking Properties').Item('Part Number').Value=$name;$lib=$app.AssetLibraries | Where-Object {$_.DisplayName -eq 'Inventor Material Library'} | Select-Object -First 1;$asset=$lib.MaterialAssets.Item($material).CopyTo($script:doc);$script:doc.ActiveMaterial=$asset}
function SavePart($group='fixed'){
 [void]$script:doc.Update2($false);if($script:doc.ComponentDefinition.SurfaceBodies.Count -ne 1){throw "Not one solid: $partName"}
 $file=Join-Path $NativeDirectory ($partName+'.ipt');$script:doc.SaveAs($file,$false)
 $o=$ac.Occurrences.Add($file,$tg.CreateMatrix());$o.Name=$partName;$o.Grounded=$false;$occs[$partName]=$o;$docs[$partName]=$script:doc
 $mp=$script:doc.ComponentDefinition.MassProperties
 [double]$xx=0;[double]$yy=0;[double]$zz=0;[double]$xy=0;[double]$yz=0;[double]$xz=0
 $mp.XYZMomentsOfInertia([ref]$xx,[ref]$yy,[ref]$zz,[ref]$xy,[ref]$yz,[ref]$xz)
 $rows.Add([pscustomobject]@{part=$partName;group=$group;bytes=(Get-Item -LiteralPath $file).Length;solids=1;mass_kg=$mp.Mass;volume_mm3=($mp.Volume*1000);material=$script:doc.ActiveMaterial.DisplayName;centroid_inertia_kg_m2=@(($xx*.0001),($yy*.0001),($zz*.0001),($xy*.0001),($yz*.0001),($xz*.0001));mass_override=$false})
 Write-Output "Saved $partName"
}


NewPart '40_Shared_Module_Dock' 'MaterialInv_048';Box 0 0 180 6 0 3;Box 0 0 6 180 0 3;Box 0 0 40 40 0 3;Box 0 -60 125 4 0 3;Box 0 60 125 4 0 3;Box 70 -7 16 42 0 3;Box 78 -62.5 6 45 0 3;Hole 0 0 7 0 3;Corners 15 15 1.6 0 3;Hole 70 -8 1.6 0 3;Hole 70 8 1.6 0 3;SavePart
NewPart '41_Common_Cube_Frame' 'MaterialInv_048';Box 0 0 280 280 -140 8;Box 0 0 264 264 -140 8 $true;foreach($x in @(-136,136)){foreach($y in @(-136,136)){Box $x $y 8 8 -132 264}};Box 0 0 280 280 132 8;Box 0 0 264 264 132 8 $true;foreach($x in @(-136,136)){foreach($y in @(-136,136)){Box $x $y 4 4 -140 280 $true}};SavePart
NewPart '42_ODrive_Micro_Envelope' 'MaterialInv_048';Box 0 0 32 32 0 7;Corners 13 13 1.6 0 7;$doc.ComponentDefinition.MassProperties.Mass=.0081;SavePart
NewPart '43_Battery_Envelope_ASSUMPTION' 'MaterialInv_048';Box 0 0 110 45 0 30;$doc.ComponentDefinition.MassProperties.Mass=.300;SavePart
NewPart '44_Controller_PCB_Envelope' 'MaterialInv_048';Box 0 0 90 70 0 1.6;Corners 40 30 1.6 0 1.6;$doc.ComponentDefinition.MassProperties.Mass=.050;SavePart
NewPart '45_Rim_B_Aluminium' 'MaterialInv_004';Ring 75 68 52 13;BoltCircle 6 72.5 1.35 52 13 30;SavePart
# Own spoke topology, polymer density proxy only; creep qualification HOLD.
$new=Join-Path $NativeDirectory '46_Spider_D_Polymer.ipt';$d=$app.Documents.Open((Join-Path $RevADirectory '../local_native_b1/03_Wheel_Spokes.ipt'),$false);$d.SaveAs($new,$true);$d=$app.Documents.Open($new,$false);$lib=$app.AssetLibraries|Where-Object {$_.DisplayName -eq 'Inventor Material Library'}|Select-Object -First 1;$mat=$lib.MaterialAssets.Item('MaterialInv_048').CopyTo($d);$d.ActiveMaterial=$mat;$d.Save()
$rows|ConvertTo-Json -Depth 5|Set-Content (Join-Path $PSScriptRoot 'study_parts.json') -Encoding utf8
Write-Output 'Study solids saved'
