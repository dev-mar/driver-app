param(
  [ValidateSet("passenger", "driver")]
  [string]$App = "driver"
)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

$projectNumber = "935442837361"
$projectId = "texi-prod"
$storageBucket = "texi-prod.firebasestorage.app"
$apiKey = "AIzaSyBjgqer8v1_GaXV6zzwl5UQhTMV9GUBSTs"

if ($App -eq "driver") {
  $prodPackage = "com.taxitexi.texi_driver_app"
  $prodAppId = "1:464855616265:android:065bf042e1885d4ac6a1d8"
  $prodProjectNumber = "464855616265"
  $prodProjectId = "prodtexiappgm"
  $prodStorageBucket = "prodtexiappgm.firebasestorage.app"
  $prodApiKey = "AIzaSyC9tAzsQNcJOh91C5JlZxVXYmGW9j67WNk"
  $devPackage = "com.taxitexi.texi_driver_app.dev"
  $devAppId = "1:935442837361:android:c68446c652c01a37df50d0"
  $devProjectNumber = "935442837361"
  $devProjectId = "texi-prod"
  $devStorageBucket = "texi-prod.firebasestorage.app"
  $devApiKey = "AIzaSyBjgqer8v1_GaXV6zzwl5UQhTMV9GUBSTs"
} else {
  $prodPackage = "com.taxitexi.texi_passenger_app"
  $prodAppId = "1:935442837361:android:94a27f405c552edddf50d0"
  $devPackage = "com.taxitexi.texi_passenger_app.dev"
  $devAppId = $prodAppId
}

function New-GoogleServicesJson {
  param(
    [string]$PackageName,
    [string]$MobileSdkAppId,
    [string]$ProjectNumber,
    [string]$ProjectId,
    [string]$StorageBucket,
    [string]$ApiKey
  )

  $obj = @{
    project_info = @{
      project_number = $ProjectNumber
      project_id = $ProjectId
      storage_bucket = $StorageBucket
    }
    client = @(
      @{
        client_info = @{
          mobilesdk_app_id = $MobileSdkAppId
          android_client_info = @{
            package_name = $PackageName
          }
        }
        oauth_client = @()
        api_key = @(
          @{ current_key = $ApiKey }
        )
        services = @{
          appinvite_service = @{
            other_platform_oauth_client = @()
          }
        }
      }
    )
    configuration_version = "1"
  }

  return ($obj | ConvertTo-Json -Depth 8)
}

$devDir = Join-Path $repoRoot "android\app\src\dev"
$prodDir = Join-Path $repoRoot "android\app\src\prod"
New-Item -ItemType Directory -Force -Path $devDir | Out-Null
New-Item -ItemType Directory -Force -Path $prodDir | Out-Null

if ($App -eq "driver") {
  New-GoogleServicesJson `
    -PackageName $devPackage `
    -MobileSdkAppId $devAppId `
    -ProjectNumber $devProjectNumber `
    -ProjectId $devProjectId `
    -StorageBucket $devStorageBucket `
    -ApiKey $devApiKey |
    Set-Content -Path (Join-Path $devDir "google-services.json") -Encoding UTF8

  New-GoogleServicesJson `
    -PackageName $prodPackage `
    -MobileSdkAppId $prodAppId `
    -ProjectNumber $prodProjectNumber `
    -ProjectId $prodProjectId `
    -StorageBucket $prodStorageBucket `
    -ApiKey $prodApiKey |
    Set-Content -Path (Join-Path $prodDir "google-services.json") -Encoding UTF8
} else {
  New-GoogleServicesJson `
    -PackageName $devPackage `
    -MobileSdkAppId $devAppId `
    -ProjectNumber $projectNumber `
    -ProjectId $projectId `
    -StorageBucket $storageBucket `
    -ApiKey $apiKey |
    Set-Content -Path (Join-Path $devDir "google-services.json") -Encoding UTF8

  New-GoogleServicesJson `
    -PackageName $prodPackage `
    -MobileSdkAppId $prodAppId `
    -ProjectNumber $projectNumber `
    -ProjectId $projectId `
    -StorageBucket $storageBucket `
    -ApiKey $apiKey |
    Set-Content -Path (Join-Path $prodDir "google-services.json") -Encoding UTF8
}

Write-Host "google-services.json generado para dev ($devPackage) y prod ($prodPackage)." -ForegroundColor Green
if ($App -eq "driver") {
  Write-Host "Prod Firebase: prodtexiappgm | Dev Firebase: texi-prod" -ForegroundColor DarkGray
}
