param([string]$NativeDirectory)
$ErrorActionPreference='Stop'
if(-not $NativeDirectory){$NativeDirectory=Join-Path $PSScriptRoot 'local_native_v4'}
if(-not ('Inventor.DocumentTypeEnum' -as [type])){Add-Type -Path 'C:/Program Files/Autodesk/Inventor 2025/Bin/Autodesk.Inventor.Interop.dll'}
Add-Type @'
using System;using System.Runtime.InteropServices;
public static class DrawingActive{[DllImport("oleaut32.dll",PreserveSig=false)]static extern void GetActiveObject(ref Guid g,IntPtr r,[MarshalAs(UnmanagedType.IUnknown)]out object o);public static object Get(){var g=Type.GetTypeFromProgID("Inventor.Application",true).GUID;object o;GetActiveObject(ref g,IntPtr.Zero,out o);return o;}}
'@
$app=[DrawingActive]::Get();if($app.SoftwareVersion.DisplayVersion -notlike '2026*'){throw '2026 required'};$tg=$app.TransientGeometry
foreach($dir in @('drawings','stl','views')){[void][IO.Directory]::CreateDirectory((Join-Path $PSScriptRoot $dir))};[void][IO.Directory]::CreateDirectory((Join-Path $NativeDirectory 'drawings'))
$template="C:/Users/Public/Documents/Autodesk/Inventor 2026/Templates/ja-JP/Metric/ISO.idw"
$pdf=$app.ApplicationAddIns.ItemById('{0AC6FD96-2F4D-42CE-8BE0-8AEA580399E4}');$ctx=$app.TransientObjects.CreateTranslationContext();$ctx.Type=[Inventor.IOMechanismEnum]::kFileBrowseIOMechanism
$names=@('01_Wheel_Rim','02_Wheel_Hub','03_Wheel_Spokes','04_Wheel_Shaft','05_Bearing_Housing','06_Motor_Mount','07_Brake_Drum','08_Brake_Mechanism','08B_Brake_Pad','09_Brake_Actuator_Bracket','10_Encoder_Mount','11_Module_Frame','12_Wheel_Guard','Cubli_OneWheel_Module_RevA')
$rows=@()
foreach($name in $names){
 $ext='ipt';if($name -like 'Cubli_*'){$ext='iam'};$model=$app.Documents.Open((Join-Path $NativeDirectory ($name+'.'+$ext)),$false)
 $idw=Join-Path $NativeDirectory ('drawings/'+$name+'.idw');if(Test-Path -LiteralPath $idw){throw 'Drawing exists; do not overwrite'}
 $d=$app.Documents.Add([Inventor.DocumentTypeEnum]::kDrawingDocumentObject,$template,$false);$d.PropertySets.Item('Inventor Summary Information').Item('Author').Value='Reaction Wheel Pendulum project';$sheet=$d.ActiveSheet
 if($sheet.TitleBlock){$sheet.TitleBlock.Delete()}
 $W=$sheet.Width;$H=$sheet.Height;$scale=.75;if($name -in @('01_Wheel_Rim','03_Wheel_Spokes','11_Module_Frame','12_Wheel_Guard','Cubli_OneWheel_Module_RevA')){$scale=.55}
 $orientation=[Inventor.ViewOrientationTypeEnum]::kFrontViewOrientation;if($name -eq '04_Wheel_Shaft'){$orientation=[Inventor.ViewOrientationTypeEnum]::kRightViewOrientation}
 $view=$sheet.DrawingViews.AddBaseView($model,$tg.CreatePoint2d(($W*.30),($H*.62)),$scale,$orientation,[Inventor.DrawingViewStyleEnum]::kHiddenLineRemovedDrawingViewStyle)
 [void]$sheet.DrawingViews.AddBaseView($model,$tg.CreatePoint2d(($W*.75),($H*.62)),($scale*.65),[Inventor.ViewOrientationTypeEnum]::kIsoTopRightViewOrientation,[Inventor.DrawingViewStyleEnum]::kHiddenLineRemovedDrawingViewStyle)
 [void]$d.Update2($false);$dimCount=0;$lines=@()
 foreach($curve in $view.DrawingCurves([Type]::Missing)){try{if($curve.StartPoint -and $curve.EndPoint){$len=$curve.StartPoint.DistanceTo($curve.EndPoint);if($len -gt .5){$lines+=,[pscustomobject]@{curve=$curve;len=$len}}}}catch{}}
 foreach($row in ($lines|Sort-Object len -Descending|Select-Object -First 2)){try{$p=$row.curve.StartPoint;$q=$row.curve.EndPoint;$intent=$sheet.CreateGeometryIntent($row.curve);[void]$sheet.DrawingDimensions.GeneralDimensions.AddLinear($tg.CreatePoint2d((($p.X+$q.X)/2),([Math]::Min($p.Y,$q.Y)-1.2-$dimCount*.7)),$intent);$dimCount++}catch{}}
 $note="Rev A PROTOTYPE / HOLD - NOT FOR FABRICATION`r`n$name`r`nDimensions in mm. Material and fit per assembly instructions.`r`nVerify supplier interfaces, brake actuator and retention before manufacture.`r`nFDM: density proxy PET; qualify print direction, fit and guard strength."
 if($name -eq '04_Wheel_Shaft'){$note+="`r`nSeats: diameter10 k5 HOLD; other shaft surfaces h6. Groove diameter9.2 x1.1.`r`nCustom3x3key seat: t1=1mm/t2=2mm; inspect fit, not standard DIN depth.`r`nAlloy steel grade/heat treatment HOLD; deburr, chamfers and fillets required."}
 if($name -eq '05_Bearing_Housing'){$note+="`r`nTwo diameter26 H7 x8 seats; centers20mm apart. Bore coaxiality0.02 HOLD.`r`nOuter-race axial float/preload and retention stack must be qualified."}
 if($name -eq '06_Motor_Mount'){$note+="`r`n6x diameter3.2 onPCD22,60degrees; pilot diameter16.1.`r`nMotor M3 engagement MUST<=3mm; use measured screw stack."}
 if($name -eq '01_Wheel_Rim'){$note+="`r`nOD150/ID136/thickness7;6x diameter3.2 onPCD142, start30degrees.`r`n6061 material certificate/temper HOLD; dynamic balance assembly."}
 [void]$sheet.DrawingNotes.GeneralNotes.AddFitted($tg.CreatePoint2d(1.5,($H*.28)),$note)
 [void]$d.Update2($false);$d.SaveAs($idw,$false)
 $options=$app.TransientObjects.CreateNameValueMap();[void]$pdf.HasSaveCopyAsOptions($d,$ctx,$options);$options.Value('All_Color_AS_Black')=1;$options.Value('Vector_Resolution')=400
 $out=$app.TransientObjects.CreateDataMedium();$out.FileName=Join-Path $PSScriptRoot ('drawings/'+$name+'.pdf');$pdf.SaveCopyAs($d,$ctx,$options,$out)
 $rows+=,[pscustomobject]@{drawing=$name;native_bytes=(Get-Item -LiteralPath $idw).Length;pdf_bytes=(Get-Item -LiteralPath $out.FileName).Length;native_dimensions=$dimCount;status='PARTIAL_HOLD'}
 Write-Output "Drawing saved $name ($dimCount dimensions)";$d.Close($true)
}
$stl=$app.ApplicationAddIns.ItemById('{533E9A98-FC3B-11D4-8E7E-0010B541CD80}')
foreach($name in @('10_Encoder_Mount','11_Module_Frame','12_Wheel_Guard')){$model=$app.Documents.Open((Join-Path $NativeDirectory ($name+'.ipt')),$false);$options=$app.TransientObjects.CreateNameValueMap();[void]$stl.HasSaveCopyAsOptions($model,$ctx,$options);$options.Value('ExportUnits')=5;$options.Value('Resolution')=1;$out=$app.TransientObjects.CreateDataMedium();$out.FileName=Join-Path $PSScriptRoot ('stl/'+$name+'.stl');$stl.SaveCopyAs($model,$ctx,$options,$out)}
$rows|ConvertTo-Json -Depth 4|Set-Content (Join-Path $PSScriptRoot 'drawing_report.json') -Encoding utf8
