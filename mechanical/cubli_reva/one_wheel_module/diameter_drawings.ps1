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
foreach($name in @('01_Wheel_Rim','02_Wheel_Hub')){
 $idw=Join-Path $NativeDirectory ('drawings/'+$name+'.idw');$d=$app.Documents.Open($idw,$true);$sheet=$d.ActiveSheet;$view=$sheet.DrawingViews.Item(1);$lines=@();$dimCount=0
 $circles=@();foreach($curve in $view.DrawingCurves([Type]::Missing)){if($curve.CurveType -eq [Inventor.CurveTypeEnum]::kCircleCurve){$circles+=,[pscustomobject]@{curve=$curve;radius=$curve.Segments.Item(1).Geometry.Radius}}}
 foreach($row in ($circles|Sort-Object radius -Descending|Select-Object -First 2)){try{$intent=$sheet.CreateGeometryIntent($row.curve);[void]$sheet.DrawingDimensions.GeneralDimensions.AddDiameter($tg.CreatePoint2d(($sheet.Width*.30+4),($sheet.Height*.35-$dimCount*1.2)),$intent);$dimCount++}catch{Write-Output ('Diameter failed: '+$_.Exception.Message)}}
 [void]$d.Update2($false);if($d.FullFileName -ne [IO.Path]::GetFullPath($idw)){throw 'Unexpected drawing path'};$d.Save()
 $options=$app.TransientObjects.CreateNameValueMap();[void]$pdf.HasSaveCopyAsOptions($d,$ctx,$options);$options.Value('All_Color_AS_Black')=1;$options.Value('Vector_Resolution')=400;$out=$app.TransientObjects.CreateDataMedium();$out.FileName=Join-Path $PSScriptRoot ('drawings/'+$name+'.pdf');$pdf.SaveCopyAs($d,$ctx,$options,$out)
 $rows+=,[pscustomobject]@{drawing=$name;native_bytes=(Get-Item $idw).Length;pdf_bytes=(Get-Item $out.FileName).Length;native_dimensions=$sheet.DrawingDimensions.GeneralDimensions.Count;status='PARTIAL_HOLD'};Write-Output ('Dimensions '+$name+': '+$sheet.DrawingDimensions.GeneralDimensions.Count);$d.Close($true)
}
$existing=Get-Content (Join-Path $PSScriptRoot 'drawing_report.json') -Raw|ConvertFrom-Json;foreach($r in $rows){$target=$existing|Where-Object {$_.drawing -eq $r.drawing};$target.native_dimensions=$r.native_dimensions;$target.native_bytes=$r.native_bytes;$target.pdf_bytes=$r.pdf_bytes};$existing|ConvertTo-Json -Depth 4|Set-Content (Join-Path $PSScriptRoot 'drawing_report.json') -Encoding utf8
