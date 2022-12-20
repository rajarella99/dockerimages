## download otel collector and install ##
Param (
    [Parameter()][string]$version,
    [Parameter()][switch]$defaultversion
    
)
$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
$DebugPreference = 'Continue'
$start = Get-Date
$default = 33
#$username = "spaceshuttle\dcadmin"
#$secpasswd = '%Y&UERD(IP'
$log = "$env:TEMP\remote-otel-app.txt"
#$cred = New-Object System.Management.Automation.PScredential -ArgumentList @($username,(ConvertTo-SecureString -String $secpasswd -AsPlainText -Force))
#$SubscriptionID = "ffed056e-0f97-4b1f-8c93-963008f53d3b"
#$LocationName = "centralus"
#$ResourceGroupName = "rg-$EnvName-cus"
#$diagSa = 'phoenixwkstorage'
#$saRg = 'Dev-Rg'

## Funcation to Install Default version of OTEL COLLECTOR SERVICE ##
Function installdefaultotel {
Param (
    
    [Parameter(Mandatory=$True)][string]$mainversion
    
)
"Installing OTEL defaultversion $default "
$Foldername = "C:\Program Files\OpenTelemetry Collector Contrib\"
"Test to see if folder OTEL Insallation [$Folder]  exists"
if (Test-Path -Path $Foldername) {
    "Path already exists!"
    Get-Service | where name -eq otelcontribcol | Stop-Service -PassThru
    Start-Sleep -Seconds 5
    Remove-Item -Path "C:\Program Files\OpenTelemetry Collector Contrib\*" -Force -Recurse   
} 
Invoke-WebRequest -Uri "https://github.com/open-telemetry/opentelemetry-collector-contrib/releases/download/v0.$default.0/otel-contrib-collector-0.$default.0-amd64.msi" -OutFile "$env:TEMP\otel-contrib-collector-0.$default.0-amd64.msi" -UseBasicParsing
Unblock-File -Path "$env:TEMP\otel-contrib-collector-0.$default.0-amd64.msi"
$file = "$env:TEMP\otel-contrib-collector-0.$default.0-amd64.msi"
$msiargs = @(
    "/i"
    "$file"
    "/L*v"
    "$log"
    "/qb!"
)
Start-Process msiexec.exe -Verb runas -Wait -ArgumentList $msiargs 
#Start-Process msiexec.exe -Wait -ArgumentList "/i $file /L*V $log /quiet" 
#Start-Process msiexec.exe -Wait -ArgumentList "/i $file /L*V $log /quiet" -Credential $cred 
#Start-Process msiexec.exe -Wait -ArgumentList "/a /jm /lv $file /quiet"
Get-Service | where name -eq otelcontribcol | Stop-Service
$Foldername = "C:\Program Files\OpenTelemetry Collector Contrib\"
"Test to see if OTEL Installer location [$Folder]  exists"
if (Test-Path -Path $Foldername) {
    "Path is available and will rename existing default config to new name!"
    Rename-Item -Path "C:\Program Files\OpenTelemetry Collector Contrib\config.yaml" -Newname "default-config.yaml"
    Invoke-WebRequest -Uri "https://phoenixwkstorage.blob.core.windows.net/wk-axcess-automation-sa/custom.config.yaml?sp=r&st=2021-08-20T07:04:33Z&se=2022-04-20T15:04:33Z&sv=2020-08-04&sr=b&sig=08jYBxi%2FdiF8RD2wr%2F32M58JOBirBm6GJ8hNU6PJ1Xs%3D" -OutFile "$env:TEMP\custom.config.yaml" -UseBasicParsing
    Copy-Item -Path "$env:TEMP\custom.config.yaml" -Destination "$Foldername\config.yaml"
} 
Get-Service | where name -eq otelcontribcol | Start-Service
$stopwatch
}





## Main Script to Install OTEL Requested Versioin ##
#$version = 28
if (($version) -and ($defaultversion -ne $True)) {
Write-Host -ForegroundColor Green "Installing OTEL $version by providing version exclusively"
$Foldername = "C:\Program Files\OpenTelemetry Collector Contrib\"
"Test to see if folder OTEL Installer location [$Folder]  exists"
if (Test-Path -Path $Foldername) {
    "Path already exists before this installation process so we need to remove!"
    Get-Service | where name -eq otelcontribcol | Stop-Service
    Start-Sleep -Seconds 3
    Remove-Item -Path "C:\Program Files\OpenTelemetry Collector Contrib\*" -Force -Recurse   
}
Invoke-WebRequest -Uri "https://github.com/open-telemetry/opentelemetry-collector-contrib/releases/download/v0.$version.0/otel-contrib-collector-0.$version.0-amd64.msi" -OutFile "$env:TEMP\otel-contrib-collector-0.$version.0-amd64.msi" -UseBasicParsing
Unblock-File -Path "$env:TEMP\otel-contrib-collector-0.$version.0-amd64.msi"
$file = "$env:TEMP\otel-contrib-collector-0.$version.0-amd64.msi"
$msiargs = @(
    "/i"
    "$file"
    "/L*v"
    "$log"
    "/qb!"
)
Start-Process msiexec.exe -Verb runas -Wait -ArgumentList $msiargs 
#Start-Process msiexec.exe -ArgumentList $msiargs -Credential $cred -Wait
#Start-Process msiexec.exe -Wait -ArgumentList "/i $file /L*V $log /quiet" 
#Start-Process msiexec.exe -Wait -ArgumentList "/i $file /L*V $log /quiet" -Credential $cred 
#Start-Process msiexec.exe -Wait -ArgumentList "/i $file /quiet"
Get-Service | where name -eq otelcontribcol | Stop-Service
Start-Sleep -Seconds 2
$Foldername = "C:\Program Files\OpenTelemetry Collector Contrib\"
"Test to see if folder [$Folder]  exists"
if (Test-Path -Path $Foldername) {
    "OTEL Installer path already exists and now we can rename default config file to new name!"
    Rename-Item -Path "C:\Program Files\OpenTelemetry Collector Contrib\config.yaml" -Newname "default1-config.yaml"
    Invoke-WebRequest -Uri "https://phoenixwkstorage.blob.core.windows.net/wk-axcess-automation-sa/custom.config.yaml?sp=r&st=2021-08-20T07:04:33Z&se=2022-04-20T15:04:33Z&sv=2020-08-04&sr=b&sig=08jYBxi%2FdiF8RD2wr%2F32M58JOBirBm6GJ8hNU6PJ1Xs%3D" -OutFile "$env:TEMP\custom.config.yaml" -UseBasicParsing
    Copy-Item -Path "$env:TEMP\custom.config.yaml" -Destination "$Foldername\config.yaml"
} 
Get-Service | where name -eq otelcontribcol | Start-Service
$stopwatch
}

###  Function to install default OTEL version ##


if ((!$version) -and ($defaultversion -ne $True)) {
			
            Write-Host -ForegroundColor Yellow "Installing default OTEL collector version without any manual switch"
			installdefaultotel -mainversion $default
		}


###  Function to install default OTEL version if $defaulversion is specified as True ##

if ($defaultversion -eq $True) {
			
            Write-Host -ForegroundColor Magenta "Installing default OTEL collector version using SWITCH parameter"
			installdefaultotel -mainversion $default
		}



		

#Service Yaml location "C:\Program Files\OpenTelemetry Collector Contrib\otelcontribcol.exe"  --config="C:\Program Files\OpenTelemetry Collector Contrib\config.yaml"