param([string]$NativeDirectory,[switch]$PartsOnly)
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
if(-not $NativeDirectory){$NativeDirectory=Join-Path $PSScriptRoot 'local_native_v4'}
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
# Rim and mechanically separate spider/hub. Motor/wheel axis is body +Z.
NewPart '01_Wheel_Rim' 'MaterialInv_004';Ring 75 68 51 7;BoltCircle 6 71 1.6 51 7 30;SavePart 'rotor'
NewPart '02_Wheel_Hub' 'MaterialInv_004';Ring 12 5 36.5 13;Ring 18 5 39 3;Ring 18 5 46.5 3;BoltCircle 4 16 1.25 39 3;BoltCircle 4 14 1.25 46.5 3;Box 0 5.5 3 3 36.5 13 $true;SavePart 'rotor'
NewPart '03_Wheel_Spokes' 'MaterialInv_004';Ring 74 68 49.5 1.5;Box 0 0 148 6 49.5 1.5;Box 0 0 6 148 49.5 1.5;Ring 18 0 49.5 1.5;Hole 0 0 5 49.5 1.5;BoltCircle 6 71 1.6 49.5 1.5 30;BoltCircle 4 14 1.6 49.5 1.5;SavePart 'rotor'
NewPart '04_Wheel_Shaft' 'MaterialInv_003';Ring 5 0 -10 67;Ring 6 0 14 12;Ring 5 4.6 54 1.1 $true;Box 0 5.5 3 3 36.5 13 $true;Hole 0 0 1.25 52 5;SavePart 'rotor'
NewPart '05_Bearing_Housing' 'MaterialInv_004';Box 0 0 52 52 6 28;Hole 0 0 11 6 28;Hole 0 0 13 6 8;Hole 0 0 13 26 8;Corners 22 22 2.1 6 28;Corners 16 16 1.25 6 28;foreach($sign in @(-1,1)){Box 0 ($sign*20) 20 12 6 28 $true;Box ($sign*20) 0 12 20 6 28 $true};SavePart
NewPart '06_Motor_Mount' 'MaterialInv_004';Box 0 0 52 52 -24 3;Hole 0 0 8.05 -24 3;BoltCircle 6 11 1.6 -24 3 90;Corners 22 22 2.1 -24 3;SavePart
# Steel disc replaces band/drum; opposing pads are symmetric in either direction.
NewPart '07_Brake_Drum' 'MaterialInv_024';Ring 55 45 37.5 1.5;Box 0 0 110 7 37.5 1.5;Box 0 0 7 110 37.5 1.5;Ring 20 0 37.5 1.5;Hole 0 0 15 37.5 1.5;BoltCircle 4 16 1.6 37.5 1.5;SavePart 'rotor'
NewPart '08_Brake_Mechanism' 'MaterialInv_048';Box 49 0 10 14 35.15 2;SavePart 'pad_lower'
NewPart '08B_Brake_Pad' 'MaterialInv_048';Box 49 0 10 14 39.35 2;SavePart 'pad_upper'
NewPart '09_Brake_Actuator_Bracket' 'MaterialInv_004';Box 65 0 10 80 4 42;Box 53 0 34 80 29 3;Box 53 0 34 80 43 3;Box 79 0 18 36 29 3;Hole 76 -12 2.1 29 3;Hole 84 12 2.1 29 3;Hole 49 -32 1.5 29 17;Hole 49 32 1.5 29 17;Hole 65 -8 1.25 4 25;Hole 65 8 1.25 4 25;SavePart
NewPart '10_Encoder_Mount' 'MaterialInv_048';Ring 15 8 63 2;Box -48 0 70 10 63 2;Box -80 0 6 10 4 61;Corners 7.5 7.5 1.1 63 2;Hole -80 0 2.1 4 61;SavePart
NewPart '11_Module_Frame' 'MaterialInv_048';Box 0 0 180 180 0 4;Box 0 0 160 160 0 4 $true;Box 0 0 180 10 0 4;Box 0 0 10 180 0 4;Box 0 0 52 52 0 4;Box 65 0 18 24 0 4;Hole 0 0 7 0 4;Corners 84 84 2.1 0 4;Corners 22 22 2.1 0 4;Hole 65 -8 1.7 0 4;Hole 65 8 1.7 0 4;SavePart
NewPart '12_Wheel_Guard' 'MaterialInv_048';Box 0 0 180 180 46 20;Box 0 0 176 176 46 20 $true;foreach($x in @(-85,85)){foreach($y in @(-85,85)){Box $x $y 10 10 4 42}};Box 0 0 180 180 66 1.5;Hole 0 0 12 66 1.5;foreach($y in @(-55,-30,30,55)){Box 0 $y 130 10 66 1.5 $true};Corners 84 84 2.1 4 63.5;SavePart
NewPart '13_Torsional_Coupling' 'MaterialInv_004';Ring 9 0 -20 16;Hole 0 0 2.5 -20 9;Hole 0 0 5 -11 7;Box 0 0 2 20 -10.5 1 $true;SavePart 'rotor'
NewPart '14_Bearing_6000_2Z' 'MaterialInv_003';Ring 13 5 6 8;SavePart
NewPart '14B_Bearing_6000_2Z' 'MaterialInv_003';Ring 13 5 26 8;SavePart
NewPart '15_Motor_4221G024BXTH' 'MaterialInv_003';Ring 21 0 -46 22;Ring 8 0 -24 1.5;Hole 0 0 2.6 -24 1.5;BoltCircle 6 11 1.25 -27 3 90;$doc.ComponentDefinition.MassProperties.Mass=.140;SavePart
NewPart '16_Motor_Rotor_Shaft' 'MaterialInv_003';Ring 2.5 0 -24 13;SavePart 'rotor'
NewPart '17_Bearing_Retainer_Rear' 'MaterialInv_004';Ring 25 6 4 2;Corners 16 16 1.6 4 2;SavePart
NewPart '17B_Bearing_Retainer_Front' 'MaterialInv_004';Ring 25 6 34 2;Corners 16 16 1.6 34 2;SavePart
NewPart '18_Encoder_Magnet' 'MaterialInv_003';Ring 2.5 0 57 2;SavePart 'rotor'
NewPart '19_Encoder_PCB_Interface' 'MaterialInv_048';Box 0 0 20 20 60.5 1.6;Corners 7.5 7.5 1.1 60.5 1.6;SavePart
NewPart '20_Retaining_Washer' 'MaterialInv_003';Ring 9 5 52.5 1;SavePart 'rotor'
NewPart '21_Retaining_Clip' 'MaterialInv_003';Ring 6 4.6 54 1;Box 0 6 3 6 54 1 $true;SavePart 'rotor'
# Four individually placed compression spacers isolate printed structure.
foreach($x in @(-22,22)){foreach($y in @(-22,22)){NewPart ('22_Spacer_'+$x+'_'+$y) 'MaterialInv_004';$s=Sketch -21;[void]$s.SketchCircles.AddByCenterRadius($tg.CreatePoint2d($x/10,$y/10),.4);[void]$s.SketchCircles.AddByCenterRadius($tg.CreatePoint2d($x/10,$y/10),.21);Extrude $s 21;SavePart}}
foreach($y in @(-32,32)){NewPart ('23_Brake_Guide_'+$y) 'MaterialInv_003';$s=Sketch 32;[void]$s.SketchCircles.AddByCenterRadius($tg.CreatePoint2d(4.9,$y/10),.15);Extrude $s 11;SavePart}
NewPart '24_Lower_Pad_Carrier' 'MaterialInv_004';Box 49 0 16 72 33.5 1.65;Hole 49 -32 1.6 33.5 1.65;Hole 49 32 1.6 33.5 1.65;SavePart 'pad_lower'
NewPart '24B_Upper_Pad_Carrier' 'MaterialInv_004';Box 49 0 16 72 41.35 1.65;Hole 49 -32 1.6 41.35 1.65;Hole 49 32 1.6 41.35 1.65;SavePart 'pad_upper'
NewPart '25_Shaft_Key' 'MaterialInv_003';Box 0 5.5 3 3 37 12;SavePart 'rotor'
Write-Output 'Native parts saved; run add_retention_parts.ps1 then finalize_module.ps1 in fresh processes'
