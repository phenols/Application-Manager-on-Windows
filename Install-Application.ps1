param (
    [Parameter(Position = 0, ValueFromPipeline = $true)]
    [string[]]
    $Applications,
    [switch]$Force,
    [switch]$All
)
$ImagePath = Join-Path -Path $PSScriptRoot -ChildPath 'image'
$InstallPath = Join-Path -Path $PSScriptRoot -ChildPath 'install'
if ((Test-Path -Path $InstallPath) -eq $false) {
    New-Item -ItemType Directory -Force -Path $InstallPath
}
if ($All) {
    $Applications = Get-ChildItem -Path $ImagePath
}
foreach ($Application in $Applications) {
    $ApplicationDirectory = Join-Path -Path $ImagePath -ChildPath $Application
    $ApplicationPath = Join-Path -Path $ApplicationDirectory -ChildPath 'application.zip'
    $ApplicationInstallPath = Join-Path -Path $InstallPath -ChildPath $Application
    if (Test-Path -Path $ApplicationInstallPath) {
        if (!$Force) {
            continue
        }
        Remove-Item $ApplicationInstallPath -Recurse -Force
    }
    Expand-Archive -Path $ApplicationPath -DestinationPath $InstallPath
    Write-Output $Application
}
$Object = Get-ChildItem -Path $InstallPath
$Object = Foreach-Object -InputObject $Object -Process { $_.Fullname }
$Object = $Object -join ';'
[System.Environment]::SetEnvironmentVariable("APPLICATION", ';' + $Object + ';', 'User')
