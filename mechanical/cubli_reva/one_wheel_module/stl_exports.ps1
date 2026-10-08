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
$stl=$app.ApplicationAddIns.ItemById('{533E9A98-FC3B-11D4-8E7E-0010B541CD80}')
foreach($name in @('10_Encoder_Mount','11_Module_Frame','12_Wheel_Guard')){$model=$app.Documents.Open((Join-Path $NativeDirectory ($name+'.ipt')),$false);$options=$app.TransientObjects.CreateNameValueMap();[void]$stl.HasSaveCopyAsOptions($model,$ctx,$options);$options.Value('ExportUnits')=5;$options.Value('Resolution')=1;$out=$app.TransientObjects.CreateDataMedium();$out.FileName=Join-Path $PSScriptRoot ('stl/'+$name+'.stl');$stl.SaveCopyAs($model,$ctx,$options,$out)}
