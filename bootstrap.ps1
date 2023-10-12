###############################
# Registry
###############################
$RegistryKeys = Import-Csv ".\registry-keys.csv"
foreach ($Row in $RegistryKeys) {
  Write-Host "Setting registry key '$($Row.Category): $($Row.Description)' .."
  if (-not(Test-Path -Path $Row.Path)) { New-Item -Path $Row.Path -Force | Out-Null }
  if ($Row.Type -eq 'Binary') {
    $Value = $Row.Value.Split(",") | ForEach-Object { "0x$_" }
    Set-ItemProperty -Path $Row.Path -Name $Row.Name -Type $Row.Type -Value ([byte[]]$Value) -Force | Out-Null
    continue
  }
  Set-ItemProperty -Path $Row.Path -Name $Row.Name -Type $Row.Type -Value $Row.Value -Force  | Out-Null
}

###############################
# Windows 10 Metro App Removals
###############################
$AppxPackages = @(
  "king.com.CandyCrushSaga",
  "Microsoft.BingWeather",
  "Microsoft.BingNews",
  "Microsoft.BingSports",
  "Microsoft.BingFinance",
  "Microsoft.XboxApp",
  "Microsoft.WindowsPhone",
  "Microsoft.MicrosoftSolitaireCollection",
  "Microsoft.People",
  "Microsoft.ZuneMusic",
  "Microsoft.ZuneVideo",
  "Microsoft.Office.OneNote",
  "Microsoft.Windows.Photos",
  "Microsoft.WindowsComunicationsApps",
  "Microsoft.SkypeApp"
)
foreach ($Package in $AppxPackages) {
  Write-Host "Removing package '$Package' .."
  $PackageFullName = (Get-AppxPackage $Package ).PackageFullName
  $PackageFullNamePro = (Get-AppxProvisionedPackage -Online | Where-Object { $_.Displayname -eq $App }).PackageName
  if ($PackageFullName) { Remove-AppxPackage -Package $PackageFullName | Out-Null }
  if ($PackageFullNamePro) { Remove-AppxProvisionedPackage -Online -PackageName $PackageFullNamePro | Out-Null }
}

###############################
# Services
###############################
Get-Service DiagTrack, Dmwappushservice | Stop-Service | Set-Service -StartupType Disabled

############################
# Chocolatey
############################

Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
$ChocolateyPackages = Import-Csv ".\choco-packages.csv"
foreach ($Row in $ChocolateyPackages) {
  Write-Host "Installing package '$($Row.Name)' .."
  if ($Row.Parameters) {
    choco install --confirm $Row.Name -params """$($Row.Parameters)""" --limit-output
    continue
  }
  choco install --confirm $Row.Name --limit-output
}