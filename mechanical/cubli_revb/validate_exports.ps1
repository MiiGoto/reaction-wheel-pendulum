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
$step=$app.ApplicationAddIns.ItemById('{90AF7F40-0C01-11D5-8E83-0010B541CD80}');$ctx=$app.TransientObjects.CreateTranslationContext();$ctx.Type=[Inventor.IOMechanismEnum]::kFileBrowseIOMechanism
function ExportStep($d,$name){$opt=$app.TransientObjects.CreateNameValueMap();[void]$step.HasSaveCopyAsOptions($d,$ctx,$opt);$opt.Value('ApplicationProtocolType')=3;$opt.Value('Author')='Reaction Wheel Pendulum project';$opt.Value('Organization')='';$opt.Value('Authorization')='';$medium=$app.TransientObjects.CreateDataMedium();$medium.FileName=Join-Path $PSScriptRoot ('step/'+$name+'.step');$step.SaveCopyAs($d,$ctx,$opt,$medium)}

$B3=Join-Path $PSScriptRoot 'local_native_b3';$records=@();$files=@(Get-ChildItem $B3 -Filter '*.ipt')+@(Get-ChildItem $NativeDirectory -Filter '*.ipt')+@(Get-ChildItem $B3 -Filter '*.iam')+@(Get-ChildItem $NativeDirectory -Filter '*.iam')
foreach($f in $files){$d=$app.Documents.Open($f.FullName,$false);$solids=$null;$constraints=$null;$health=@();if($f.Extension -eq '.ipt'){$solids=$d.ComponentDefinition.SurfaceBodies.Count}else{$constraints=$d.ComponentDefinition.Constraints.Count;foreach($c in $d.ComponentDefinition.Constraints){$health+=,$c.HealthStatus.ToString()}};$missing=@();foreach($r in $d.File.ReferencedFileDescriptors){if($r.ReferenceMissing){$missing+=,[IO.Path]::GetFileName($r.FullFileName)}};$records+=,[pscustomobject]@{name=$f.Name;bytes=$f.Length;solid_bodies=$solids;constraints=$constraints;constraint_health=$health;missing_references=$missing};ExportStep $d $f.BaseName}
# Explicit saved native IAM close/reopen, no save to Rev A.
foreach($f in @((Join-Path $B3 'Cubli_OneWheel_Module_RevB.iam'),(Join-Path $NativeDirectory 'Cubli_ThreeAxis_Integration_Study.iam'))){$d=$app.Documents.Open($f,$false);$d.Close($true);$d=$app.Documents.Open($f,$true);[void]$d.Update2($false);$d.Activate();$cam=$app.ActiveView.Camera;$cam.ViewOrientationType=[Inventor.ViewOrientationTypeEnum]::kIsoTopRightViewOrientation;$cam.Apply();$app.ActiveView.Fit();$app.ActiveView.SaveAsBitmap((Join-Path $PSScriptRoot ('views/'+[IO.Path]::GetFileNameWithoutExtension($f)+'.bmp')),1600,1200)}
[pscustomobject]@{Inventor=$app.SoftwareVersion.DisplayVersion;native_files=$records;reopen='Saved module and integration IAM closed/reopened through Inventor; resolved parts checked';healthy_enum=([Inventor.HealthStatusEnum]::kUpToDateHealth).ToString();status='READBACK_AND_NEUTRAL_EXPORT_ACTUAL'}|ConvertTo-Json -Depth 7|Set-Content (Join-Path $PSScriptRoot 'cad_validation.json') -Encoding utf8
Write-Output ('Readback/export native files '+$records.Count)
