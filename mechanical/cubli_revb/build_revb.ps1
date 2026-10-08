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
if(-not $NativeDirectory){$NativeDirectory=Join-Path $PSScriptRoot 'local_native_b1'}
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

# Unchanged native solids are duplicated locally. The original IAM is NOT reused.
$replace=@('01_Wheel_Rim','02_Wheel_Hub','03_Wheel_Spokes','04_Wheel_Shaft','05_Bearing_Housing','06_Motor_Mount','07_Brake_Drum','08_Brake_Mechanism','08B_Brake_Pad','09_Brake_Actuator_Bracket','10_Encoder_Mount','11_Module_Frame','12_Wheel_Guard','13_Torsional_Coupling','15_Motor_4221G024BXTH','16_Motor_Rotor_Shaft','17_Bearing_Retainer_Rear','17B_Bearing_Retainer_Front','21_Retaining_Clip','23_Brake_Guide_-32','23_Brake_Guide_32','24_Lower_Pad_Carrier','24B_Upper_Pad_Carrier','27_Front_Hub_Shim')
Get-ChildItem -LiteralPath $RevADirectory -Filter '*.ipt'|Where-Object {$_.BaseName -notin $replace -and $_.BaseName -notlike '22_Spacer*'}|ForEach-Object {Copy-Item -LiteralPath $_.FullName -Destination $NativeDirectory}
function PolygonXY($points,$z,$depth,$cut=$false){$sk=Sketch $z;for($i=0;$i -lt $points.Count;$i++){$p=$points[$i];$q=$points[($i+1)%$points.Count];[void]$sk.SketchLines.AddByTwoPoints($tg.CreatePoint2d($p[0]/10,$p[1]/10),$tg.CreatePoint2d($q[0]/10,$q[1]/10))};Extrude $sk $depth $cut}
function PrismYZ($x,$width,$points){$wp=@();foreach($p in @(@($x,0,0),@($x,1,0),@($x,0,1))){$w=$doc.ComponentDefinition.WorkPoints.AddFixed($tg.CreatePoint($p[0]/10,$p[1]/10,$p[2]/10));$w.Visible=$false;$wp+=,$w};$plane=$doc.ComponentDefinition.WorkPlanes.AddByThreePoints($wp[0],$wp[1],$wp[2]);$plane.Visible=$false;$sk=$doc.ComponentDefinition.Sketches.Add($plane);$p=$points[0];$q=$points[1];$l=$sk.SketchLines.AddByTwoPoints($sk.ModelToSketchSpace($tg.CreatePoint($x/10,$p[0]/10,$p[1]/10)),$sk.ModelToSketchSpace($tg.CreatePoint($x/10,$q[0]/10,$q[1]/10)));$first=$l.StartSketchPoint;$last=$l.EndSketchPoint;for($i=2;$i -lt $points.Count;$i++){$p=$points[$i];$l=$sk.SketchLines.AddByTwoPoints($last,$sk.ModelToSketchSpace($tg.CreatePoint($x/10,$p[0]/10,$p[1]/10)));$last=$l.EndSketchPoint};[void]$sk.SketchLines.AddByTwoPoints($last,$first);Extrude $sk $width}
function PadSector($z){$pts=@();for($i=0;$i -le 16;$i++){$t=(8-$i)*[Math]::PI/180;$px=55*[Math]::Cos($t);$py=55*[Math]::Sin($t);$pts+=,@($px,$py)};for($i=0;$i -le 16;$i++){$t=(-8+$i)*[Math]::PI/180;$px=49*[Math]::Cos($t);$py=49*[Math]::Sin($t);$pts+=,@($px,$py)};PolygonXY $pts $z 2}
NewPart '01_Wheel_Rim' 'MaterialInv_024';Ring 75 70 52 5.5;BoltCircle 6 72.5 1.35 52 5.5 30;SavePart 'rotor'
NewPart '02_Wheel_Hub' 'MaterialInv_004';Ring 9 5 36.5 14;Ring 18 5 39 2;Ring 18 5 47.5 3;BoltCircle 4 16 1.25 39 2;BoltCircle 4 14 1.25 47.5 3;Box 0 5.5 3 3 36.5 13 $true;SavePart 'rotor'
NewPart '03_Wheel_Spokes' 'MaterialInv_004';Ring 74.5 69 50.5 1.5;Box 0 0 149 4 50.5 1.5;Box 0 0 4 149 50.5 1.5;Ring 18 0 50.5 1.5;Hole 0 0 5 50.5 1.5;BoltCircle 6 72.5 1.35 50.5 1.5 30;BoltCircle 4 14 1.6 50.5 1.5;SavePart 'rotor'
NewPart '04_Wheel_Shaft' 'MaterialInv_003';Ring 5 0 -17.55 74.55;Ring 6 0 14 12;Ring 5 4.8 54 1.1 $true;Box 0 5.5 3 3 36.5 13 $true;Hole 0 0 1.25 52 5;SavePart 'rotor'
NewPart '05_Bearing_Housing' 'MaterialInv_004';Box 0 0 36 36 6 28;Hole 0 0 11 6 28;Hole 0 0 13 6 8;Hole 0 0 13 26 8;Corners 15 15 1.6 6 28;SavePart
NewPart '06_Motor_Mount' 'MaterialInv_004';Box 0 0 40 40 -43.3 2;Hole 0 0 8.05 -43.3 2;BoltCircle 6 11 1.6 -43.3 2 90;Corners 15 15 1.6 -43.3 2;SavePart
NewPart '07_Brake_Drum' 'MaterialInv_024';Ring 55 49 37.8 1.2;Box 0 0 110 3 37.8 1.2;Box 0 0 3 110 37.8 1.2;Ring 20 0 37.8 1.2;Hole 0 0 15 37.8 1.2;BoltCircle 4 16 1.6 37.8 1.2;SavePart 'rotor'
NewPart '08_Brake_Mechanism' 'MaterialInv_048';Box 51.9 0 5.6 8 35.15 2;SavePart 'pad_lower'
NewPart '08B_Brake_Pad' 'MaterialInv_048';Box 51.9 0 5.6 8 39.35 2;SavePart 'pad_upper'
NewPart '09_Brake_Actuator_Bracket' 'MaterialInv_004';Box 70 0 6 28 4 45;Box 59 0 18 28 28 4;Box 59 0 18 28 45 4;Hole 60 -10 1.5 29 20;Hole 60 10 1.5 29 20;Hole 70 -8 1.25 4 25;Hole 70 8 1.25 4 25;SavePart
NewPart '10_Encoder_Mount' 'MaterialInv_048';Ring 15 8 63 2;Box -51 0 76 10 63 2;Box -86 0 6 10 3 62;Corners 7.5 7.5 1.1 63 2;Hole -86 0 2.1 3 62;SavePart
NewPart '11_Module_Frame' 'MaterialInv_048';Box 0 0 180 180 0 3;Box 0 0 168 168 0 3 $true;Box 0 0 180 6 0 3;Box 0 0 6 180 0 3;Box 0 0 40 40 0 3;foreach($x in @(-84,84)){foreach($y in @(-84,84)){Box $x $y 12 12 0 3}};Box 0 -60 180 4 0 3;Box 0 60 180 4 0 3;Box 70 -7 16 42 0 3;Box 78 -62.5 6 45 0 3;Hole 0 0 7 0 3;Corners 84 84 2.1 0 3;Corners 15 15 1.6 0 3;Hole 70 -8 1.6 0 3;Hole 70 8 1.6 0 3;SavePart
NewPart '12_Wheel_Guard' 'MaterialInv_048';Ring 80 78 49 17;Ring 80 74 66 1.5;Box 0 0 160 6 66 1.5;Box 0 0 6 160 66 1.5;Hole 0 0 12 66 1.5;foreach($x in @(-60,60)){foreach($y in @(-60,60)){Box $x $y 5 5 3 46;Box $x $y 5 5 49 18.5;Box ($x*0.95) ($y*0.95) 10 10 66 1.5}};Box -78 0 10 12 62 4.5 $true;SavePart
NewPart '13_Torsional_Coupling' 'MaterialInv_004';Ring 12.7 0 -41 35.3;Hole 0 0 3 -41 11.85;Hole 0 0 5 -17.55 11.85;Hole 0 0 5.5 -29.15 11.6;$doc.ComponentDefinition.MassProperties.Mass=.032;SavePart 'rotor'
NewPart '13B_Coupling_Sleeve_5_6' 'MaterialInv_003';Ring 3 2.5 -41 10.7;Box 0 3 .3 3 -41 10.7 $true;SavePart 'rotor'
NewPart '15_Motor_4221G024BXTH' 'MaterialInv_003';Ring 21 0 -65.3 22;Ring 8 0 -43.3 1.5;Hole 0 0 2.6 -43.3 1.5;BoltCircle 6 11 1.25 -46.3 3 90;$doc.ComponentDefinition.MassProperties.Mass=.140;SavePart
NewPart '16_Motor_Rotor_Shaft' 'MaterialInv_003';Ring 2.5 0 -43.3 13;SavePart 'rotor'
NewPart '17_Bearing_Retainer_Rear' 'MaterialInv_004';Box 0 0 40 40 4 2;Hole 0 0 6 4 2;Corners 15 15 1.6 4 2;SavePart
NewPart '17B_Bearing_Retainer_Front' 'MaterialInv_004';Box 0 0 40 40 34 2;Hole 0 0 6 34 2;Corners 15 15 1.6 34 2;SavePart
NewPart '21_Retaining_Clip' 'MaterialInv_003';Ring 6.6 4.8 54 1;Box 0 6.5 3 6 54 1 $true;$doc.ComponentDefinition.MassProperties.Mass=.0003;SavePart 'rotor'
foreach($x in @(-15,15)){foreach($y in @(-15,15)){NewPart ('22_Spacer_'+$x+'_'+$y) 'MaterialInv_004';$sk=Sketch -41.3;[void]$sk.SketchCircles.AddByCenterRadius($tg.CreatePoint2d($x/10,$y/10),.4);[void]$sk.SketchCircles.AddByCenterRadius($tg.CreatePoint2d($x/10,$y/10),.16);Extrude $sk 41.3;SavePart;NewPart ('29_Frame_Shim_'+$x+'_'+$y) 'MaterialInv_004';$sk=Sketch 3;[void]$sk.SketchCircles.AddByCenterRadius($tg.CreatePoint2d($x/10,$y/10),.4);[void]$sk.SketchCircles.AddByCenterRadius($tg.CreatePoint2d($x/10,$y/10),.16);Extrude $sk 1;SavePart}}
foreach($y in @(-10,10)){NewPart ('23_Brake_Guide_'+$y) 'MaterialInv_003';$sk=Sketch 32;[void]$sk.SketchCircles.AddByCenterRadius($tg.CreatePoint2d(6,$y/10),.15);Extrude $sk 13;SavePart}
NewPart '24_Lower_Pad_Carrier' 'MaterialInv_004';Box 55 0 20 28 33.5 1.65;Box 60 0 10 12 32.5 3 $true;PrismYZ 55 10 @(@(-6,33.89),@(6,33.11),@(6,35.15),@(-6,35.15));Hole 60 -10 1.6 33.5 1.65;Hole 60 10 1.6 33.5 1.65;SavePart 'pad_lower'
NewPart '24B_Upper_Pad_Carrier' 'MaterialInv_004';Box 55 0 20 28 41.35 1.65;Box 60 0 10 12 41.2 2.2 $true;PrismYZ 55 10 @(@(-6,41.35),@(6,41.35),@(6,43.21),@(-6,42.79));Hole 60 -10 1.6 41.35 1.65;Hole 60 10 1.6 41.35 1.65;SavePart 'pad_upper'
NewPart '27_Front_Hub_Shim' 'MaterialInv_003';Ring 9 5 52 .5;SavePart 'rotor'
NewPart '30_Dual_Wedge_Slider' 'MaterialInv_004';PrismYZ 55 10 @(@(-6,32),@(6,32),@(6,33.11),@(-6,33.89));Box 65 -18 2 24 32 .5;Box 65 -29 2 2 32 13;Box 65 -18 2 24 44.5 .5;PrismYZ 55 10 @(@(-6,42.79),@(6,43.21),@(6,45),@(-6,45));SavePart 'slider'
NewPart '31_Actuator_PQ12_Body_Envelope' 'MaterialInv_048';Box 64.5 -61.25 21.5 36.5 31 15;Box 62.5 -81.75 6 4.5 33.5 10;Hole 62.5 -82 1.5 33.5 10;$doc.ComponentDefinition.MassProperties.Mass=.0182;SavePart
NewPart '32_Actuator_PQ12_Rod_Envelope' 'MaterialInv_004';Box 65 -36.5 5 13 36 5;Hole 65 -31.5 1.5 36 5;$doc.ComponentDefinition.MassProperties.Mass=.0008;SavePart 'slider'
NewPart '33_Actuator_Clevis' 'MaterialInv_004';Box 65 -30.75 5 1.5 34 2;Box 65 -30.75 5 1.5 41 2;Box 67 -30.75 1 1.5 36 5;Hole 65 -31 1.5 34 9;SavePart 'slider'
NewPart '34_Actuator_Mount' 'MaterialInv_004';Box 65 -63 32 56 29 2;Box 78 -85 5 5 3 26;Box 78 -40 5 5 3 26;Hole 78 -85 1.6 3 28;Hole 78 -40 1.6 3 28;SavePart
NewPart '35_Slider_Stops' 'MaterialInv_004';Box 65 -31 2 2 29 16;Box 65 -17 2 2 29 16;Box 67 -24 6 16 27 2;Box 69 -17 2 2 4 23;SavePart
foreach($y in @(-10,10)){NewPart ('36_Spring_Seat_'+$y) 'MaterialInv_003';$sk=Sketch 38;[void]$sk.SketchCircles.AddByCenterRadius($tg.CreatePoint2d(6,$y/10),.30);[void]$sk.SketchCircles.AddByCenterRadius($tg.CreatePoint2d(6,$y/10),.15);Extrude $sk .4;SavePart;NewPart ('37_Return_Lower_'+$y) 'MaterialInv_003';$sk=Sketch 35.15;[void]$sk.SketchCircles.AddByCenterRadius($tg.CreatePoint2d(6,$y/10),.3);[void]$sk.SketchCircles.AddByCenterRadius($tg.CreatePoint2d(6,$y/10),.18);Extrude $sk 2.85;$doc.ComponentDefinition.MassProperties.Mass=.0002;SavePart 'spring';NewPart ('38_Return_Upper_'+$y) 'MaterialInv_003';$sk=Sketch 38.4;[void]$sk.SketchCircles.AddByCenterRadius($tg.CreatePoint2d(6,$y/10),.3);[void]$sk.SketchCircles.AddByCenterRadius($tg.CreatePoint2d(6,$y/10),.18);Extrude $sk 2.95;$doc.ComponentDefinition.MassProperties.Mass=.0002;SavePart 'spring'}
# Bearing mass is corrected to19g catalogue, separately reported from geometry savings.
foreach($name in @('14_Bearing_6000_2Z','14B_Bearing_6000_2Z')){$f=Join-Path $NativeDirectory ($name+'.ipt');$d=$app.Documents.Open($f,$false);$d.ComponentDefinition.MassProperties.Mass=.019;if($d.FullFileName -ne [IO.Path]::GetFullPath($f)){throw 'Wrong file'};$d.Save()}
Write-Output 'Rev B solids saved; finalize assembly next.'
