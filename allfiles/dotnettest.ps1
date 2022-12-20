## Powershell Script to Install dependencies and Repricer Software ##
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$True)][string]$dotneturl
   # [Parameter()][switch]$updatecontainerregistry
    
)

## Time and Debug settings ##
$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
$DebugPreference = 'SilentlyContinue'
#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
$ErrorActionPreference = 'Continue'

# Change the working directory PowerShell module path.
# Set-Location $env:PSModulePath
# $log = "$env:TEMP\repricerlogs.txt"
# $SubscriptionId = "ffed056e-0f97-4b1f-8c93-963008f53d3b"
# Get-AzSubscription -SubscriptionId $SubscriptionId | Set-AzContext 
# Write-Host "Getting AzContext for specific subscription"
# Get-AzContext






# Install Dotnet Runtime 6.0.4 SDK  ##
function dotnetinstall {
    Param (    
        [Parameter(Mandatory=$True)][string]$dotneturi        
    )     
    if ($null -eq (Get-Command cmd.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Unable to find cmd.exe in your PATH."
    } else {
        $command = "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12"
        Invoke-Expression $command
        Invoke-WebRequest -Uri $dotneturl -Outfile "C:\dotnet-sdk-6.0.402-win-x64.exe" -UseBasicParsing        
        #Invoke-WebRequest -Uri "https://download.visualstudio.microsoft.com/download/pr/9f4d3331-ff2a-4415-ab5d-eafc9c4f09ee/1922162c9ed35d6c10160f46c26127d6/dotnet-sdk-6.0.402-win-x64.exe" -Outfile C:\dotnet-sdk-6.0.402-win-x64.exe -UseBasicParsing
        Start-Process -Wait -FilePath "C:\dotnet-sdk-6.0.402-win-x64.exe" -ArgumentList "/S /v /qn" -PassThru
        Set-Variable -Name "dotnet" -Value (dotnet --version) -ErrorAction SilentlyContinue
        Write-Host "The Following dotnet version "$dotnet" is installed" -ErrorAction SilentlyContinue

    }
}

# Install Dotnet SDK version ##

$Folder = "C:\Program Files\dotnet\"
Write-Host "Test to see if Dotnet Installer location "$Folder"  exists"
if (Test-Path -Path $Folder) {
    $dotnet = & cmd /c "dotnet --version 2>&1"
    Write-Host "The Following dotnet version "$dotnet" is installed"
} else {
    Write-Host -ForegroundColor Magenta "Installing Dotnet SDK version using SWITCH parameter"
    dotnetinstall -dotneturi $dotneturl
    Write-Host -ForegroundColor Yellow "[Time consumed to install JRE "$stopwatch.Elapsed.TotalSeconds" seconds]"
}


##############END OF SCRIPT#######################################################