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
$rows=@()
foreach($name in @('01_Wheel_Rim','04_Wheel_Shaft','09_Brake_Actuator_Bracket')){
 $file=Join-Path $NativeDirectory ($name+'.ipt');$d=$app.Documents.Open($file,$true);$d.Activate();$app.ActiveView.Fit();$app.ActiveView.SaveAsBitmap((Join-Path $PSScriptRoot ('views/'+$name+'.bmp')),1600,1200)
}
$file=Join-Path $NativeDirectory 'Cubli_OneWheel_Module_RevA.iam';$a=$app.Documents.Open($file,$true);$a.Activate();$ac=$a.ComponentDefinition;$visible=@{}
foreach($o in $ac.Occurrences){$visible[$o.Name]=$o.Visible;if($o.Name -eq '12_Wheel_Guard'){$o.Visible=$false}}
$app.ActiveView.Fit();$app.ActiveView.SaveAsBitmap((Join-Path $PSScriptRoot 'views/module_internal.bmp'),1600,1200)
foreach($o in $ac.Occurrences){$o.Visible=($o.Name -in @('04_Wheel_Shaft','05_Bearing_Housing','14_Bearing_6000_2Z','14B_Bearing_6000_2Z','17_Bearing_Retainer_Rear','17B_Bearing_Retainer_Front','26_Inner_Race_Spacer','20_Retaining_Washer','21_Retaining_Clip'))}
$app.ActiveView.Fit();$app.ActiveView.SaveAsBitmap((Join-Path $PSScriptRoot 'views/shaft_bearings.bmp'),1600,1200)
foreach($o in $ac.Occurrences){$o.Visible=($o.Name -in @('07_Brake_Drum','08_Brake_Mechanism','08B_Brake_Pad','09_Brake_Actuator_Bracket','23_Brake_Guide_-32','23_Brake_Guide_32','24_Lower_Pad_Carrier','24B_Upper_Pad_Carrier'))}
$app.ActiveView.Fit();$app.ActiveView.SaveAsBitmap((Join-Path $PSScriptRoot 'views/brake_mechanism.bmp'),1600,1200)
foreach($o in $ac.Occurrences){$o.Visible=$visible[$o.Name]};$app.ActiveView.Fit()
if($a.FullFileName -ne [IO.Path]::GetFullPath($file)){throw 'Wrong assembly'};$a.Save();$a.Close($true)
$a=$app.Documents.Open($file,$true);$rows=@();foreach($o in $a.ComponentDefinition.Occurrences){$d=$o.Definition.Document;$rows+=,[pscustomobject]@{part=$o.Name;file_exists=(Test-Path -LiteralPath $d.FullFileName);solid_bodies=$d.ComponentDefinition.SurfaceBodies.Count}}
$bb=$a.ComponentDefinition.RangeBox
$r=[ordered]@{Inventor=$app.SoftwareVersion.DisplayVersion;assembly_bytes=(Get-Item $file).Length;reopened_occurrences=$a.ComponentDefinition.Occurrences.Count;reopened_constraints=$a.ComponentDefinition.Constraints.Count;bounds_min_mm=@(($bb.MinPoint.X*10),($bb.MinPoint.Y*10),($bb.MinPoint.Z*10));bounds_max_mm=@(($bb.MaxPoint.X*10),($bb.MaxPoint.Y*10),($bb.MaxPoint.Z*10));references=$rows;viewport_source='Inventor ActiveView.SaveAsBitmap; not full GUI screenshots';computer_use='unavailable; node kernel failed before UI operation'}
$r|ConvertTo-Json -Depth 6|Set-Content (Join-Path $PSScriptRoot 'reopen_validation.json') -Encoding utf8
Write-Output ('Reopened '+$rows.Count+' native solid parts; missing '+@($rows|Where-Object {-not $_.file_exists}).Count)
