###############################
# Registry
###############################
$RegistryKeys = Import-Csv ".\registry-keys.csv"
foreach ($Row in $RegistryKeys) {
  Write-Host "Category:`t$($Row.Category)`nDescription:`t$($Row.Description)"
  if ($Row.Type -eq 'Binary') {
    $Value = $Row.Value.Split(",") | ForEach-Object { "0x$_"}
    Set-ItemProperty -Path $Row.Path -Name $Row.Name -Type $Row.Type -Value ([byte[]]$Value) -Force  
    continue
  }
  Set-ItemProperty -Path $Row.Path -Name $Row.Name -Type $Row.Type -Value $Row.Value -Force
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
foreach ($AppxPackage in $AppxPackages) {
  Get-AppxPackage $AppxPackage | Remove-AppxPackage
}

###############################
# Services
###############################
Get-Service DiagTrack,Dmwappushservice | Stop-Service | Set-Service -StartupType Disabled

############################
# Chocolatey
############################

Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
$ChocolateyPackages = Import-Csv ".\choco-packages.csv"
foreach ($Row in $ChocolateyPackages) {
  if ($Row.Parameters) {
    choco install --confirm $Row.Name -params """$($Row.Parameters)"""
    continue
  }
  choco install --confirm $Row.Name
}