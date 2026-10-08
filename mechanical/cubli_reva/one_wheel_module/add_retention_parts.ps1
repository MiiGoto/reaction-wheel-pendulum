param([string]$NativeDirectory)
$ErrorActionPreference='Stop'
if(-not $NativeDirectory){$NativeDirectory=Join-Path $PSScriptRoot 'local_native_v4'}
if(-not ('Inventor.DocumentTypeEnum' -as [type])){Add-Type -Path 'C:/Program Files/Autodesk/Inventor 2025/Bin/Autodesk.Inventor.Interop.dll'}
Add-Type @'
using System;using System.Runtime.InteropServices;
public static class RetainActive{[DllImport("oleaut32.dll",PreserveSig=false)]static extern void GetActiveObject(ref Guid g,IntPtr r,[MarshalAs(UnmanagedType.IUnknown)]out object o);public static object Get(){var g=Type.GetTypeFromProgID("Inventor.Application",true).GUID;object o;GetActiveObject(ref g,IntPtr.Zero,out o);return o;}}
'@
$app=[RetainActive]::Get();if($app.SoftwareVersion.DisplayVersion -notlike '2026*'){throw '2026 required'};$tg=$app.TransientGeometry
$pt=$app.FileManager.GetTemplateFile([Inventor.DocumentTypeEnum]::kPartDocumentObject,[Inventor.SystemOfMeasureEnum]::kMetricSystemOfMeasure)
foreach($spec in @(@('26_Inner_Race_Spacer',6,5,34,2.5),@('27_Front_Hub_Shim',9,5,51,1.5),@('28_Clip_Stack_Shim',9,5,53.5,.5))){
 $file=[IO.Path]::GetFullPath((Join-Path $NativeDirectory ($spec[0]+'.ipt')));if(Test-Path -LiteralPath $file){throw 'Refusing existing part'}
 $d=$app.Documents.Add([Inventor.DocumentTypeEnum]::kPartDocumentObject,$pt,$false);$d.PropertySets.Item('Inventor Summary Information').Item('Author').Value='Reaction Wheel Pendulum project'
 $lib=$app.AssetLibraries|Where-Object {$_.DisplayName -eq 'Inventor Material Library'}|Select-Object -First 1;$d.ActiveMaterial=$lib.MaterialAssets.Item('MaterialInv_003').CopyTo($d)
 $wp=$d.ComponentDefinition.WorkPlanes.AddByPlaneAndOffset($d.ComponentDefinition.WorkPlanes.Item(3),($spec[3]/10),$false);$wp.Visible=$false;$s=$d.ComponentDefinition.Sketches.Add($wp,$false)
 [void]$s.SketchCircles.AddByCenterRadius($tg.CreatePoint2d(0,0),($spec[1]/10));[void]$s.SketchCircles.AddByCenterRadius($tg.CreatePoint2d(0,0),($spec[2]/10))
 $ef=$d.ComponentDefinition.Features.ExtrudeFeatures;$def=$ef.CreateExtrudeDefinition($s.Profiles.AddForSolid(),[Inventor.PartFeatureOperationEnum]::kJoinOperation);$def.SetDistanceExtent(($spec[4]/10),[Inventor.PartFeatureExtentDirectionEnum]::kPositiveExtentDirection);[void]$ef.Add($def);$s.Visible=$false;[void]$d.Update2($false);$d.SaveAs($file,$false);Write-Output "Saved $($spec[0])"}
