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

if(-not $NativeDirectory){$NativeDirectory=Join-Path $PSScriptRoot 'local_native_b3'}
$file=Join-Path $NativeDirectory 'Cubli_OneWheel_Module_RevB.iam';$d=$app.Documents.Open($file,$true);$ac=$d.ComponentDefinition;$p=$ac.Parameters.UserParameters.Item('InputStroke');$rows=@()
foreach($mm in @(0,5,10)){$p.Expression=($mm.ToString()+' mm');[void]$d.Update2($false);$o=@{};foreach($x in $ac.Occurrences){$o[$x.Name]=$x};$rows+=,[pscustomobject]@{input_mm=$mm;slider_translation_y_mm=($o['30_Dual_Wedge_Slider'].Transformation.Translation.Y*10);rod_translation_y_mm=($o['32_Actuator_PQ12_Rod_Envelope'].Transformation.Translation.Y*10);lower_pad_translation_z_mm=($o['08_Brake_Mechanism'].Transformation.Translation.Z*10);upper_pad_translation_z_mm=($o['08B_Brake_Pad'].Transformation.Translation.Z*10)};$d.Activate();$cam=$app.ActiveView.Camera;$cam.ViewOrientationType=[Inventor.ViewOrientationTypeEnum]::kIsoTopRightViewOrientation;$cam.Apply();$app.ActiveView.Fit();$app.ActiveView.SaveAsBitmap((Join-Path $PSScriptRoot ('views/brake_state_'+$mm+'.bmp')),1600,1200)}
$p.Expression='0 mm';[void]$d.Update2($false);$d.Save();$rows|ConvertTo-Json -Depth 4|Set-Content (Join-Path $PSScriptRoot 'brake_kinematics_native.json') -Encoding utf8
Write-Output ($rows|ConvertTo-Json -Compress)
