## Powershell Script to Install dependencies and Repricer Software ##
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$True)][string]$awsregion,
    [Parameter(Mandatory=$True)][string]$accesskey,
    [Parameter(Mandatory=$True)][string]$secretkey,
    [Parameter(Mandatory=$False)][string]$awscli,
    [Parameter(Mandatory=$False)][string]$javaurl,
    [Parameter(Mandatory=$False)][string]$dotneturl
    
)

## Time and Debug settings ##
$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
$DebugPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Continue'

# Script Required Variables ##
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
Set-Location $env:HOMEDRIVE
$accesskey = "define"
$secretkey = "define"
$awsregion = "define"
$awscli = "https://awscli.amazonaws.com/AWSCLIV2.msi"
$javaurl = "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=247136_10e8cce67c7843478f41411b7003171c"
$dotneturl = "https://download.visualstudio.microsoft.com/download/pr/9f4d3331-ff2a-4415-ab5d-eafc9c4f09ee/1922162c9ed35d6c10160f46c26127d6/dotnet-sdk-6.0.402-win-x64.exe"
$logs = "$env:HOMEDRIVE\repricerlogs.txt"
$logs1 = "$env:HOMEDRIVE\repricerlogs1.txt"
Set-AWSCredential -AccessKey $accesskey -SecretKey $secretkey -StoreAs awsloginprofile
Set-AWSCredential -ProfileName awsloginprofile
$bucketname = "defines3bucketname"
$objects = Get-S3Object -BucketName $bucketname -KeyPrefix 'Foldername/Subfoldername/'
$downloadlocation = "$env:HOMEDRIVE"


# Certificate Ignore Function ##
function certignore {
if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type)
{
$certCallback = @"
    using System;
    using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;
    public class ServerCertificateValidationCallback
    {
        public static void Ignore()
        {
            if(ServicePointManager.ServerCertificateValidationCallback ==null)
            {
                ServicePointManager.ServerCertificateValidationCallback += 
                    delegate
                    (
                        Object obj, 
                        X509Certificate certificate, 
                        X509Chain chain, 
                        SslPolicyErrors errors
                    )
                    {
                        return true;
                    };
            }
        }
    }
"@
    Add-Type $certCallback
 }
[ServerCertificateValidationCallback]::Ignore()
}


# Java JRE Function ##
function jreinstall {
    Param (    
        [Parameter(Mandatory=$True)][string]$javauri        
    )    
    if ($null -eq (Get-Command cmd -ErrorAction SilentlyContinue)) {
        Write-Host "Unable to find cmd.exe in your PATH."
    } else {
        $command = "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12"
        Invoke-Expression $command
        #Invoke-WebRequest -Uri "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=247136_10e8cce67c7843478f41411b7003171c" -Outfile C:\jre8u351.exe -UseBasicParsing
        Invoke-WebRequest -Uri $javaurl -Outfile "C:\jre8u351.exe" -UseBasicParsing
        Start-Process "C:\jre8u351.exe" -Verb runAs -ArgumentList "/s" -Wait -PassThru
        Set-Variable -Name "javaversion" -Value (java --version) -ErrorAction SilentlyContinue
        Write-Host "The Following JAVA version "$javaversion[0].tostring()" is installed" -ErrorAction SilentlyContinue        
    }
}
# Install Java Runtime 8 version ##

$Folder = "C:\Program Files\Java\jre*"
Write-Host "Test to see if JAVA Installer location "$Folder"  exists"
if (Test-Path -Path $Folder) {
    $javaversion = & cmd /c "java -version 2>&1"
    Write-Host "The Following "$javaversion[0].tostring()" is installed"
} else {
    Write-Host -ForegroundColor Magenta "Installing Java JRE version using SWITCH parameter"
    jreinstall -javauri $javaurl -ErrorVariable javahandle
    Write-Host "the function status "$javahandle.Count""
    while (0 -notmatch $javahandle.Count) {
        Write-Host "Running the Certificate Ignore Function"
        certignore
        Write-Host "Running The Java Installer Function after CertIgnore addition"
        jreinstall -javauri $javaurl -ErrorVariable javahandle
    }
    Write-Host -ForegroundColor Yellow "[Time consumed to install JRE "$stopwatch.Elapsed.TotalSeconds" seconds]"
}


# Dotnet Runtime 6.0.4 SDK Function  ##
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
    Write-Host -ForegroundColor Yellow "[Time consumed to install Dotnet "$stopwatch.Elapsed.TotalSeconds" seconds]"
}


# Install AWS PowerShell Tools ##
function Install-AWSPowerShellTools {
If($null -eq (Get-InstalledModule AWSPowerShell.NetCore -ErrorAction SilentlyContinue)){
    Write-Host "The Following Modules have been installed"
      Get-Module | Where-Object{$_.Name -like "AWS*"} | ForEach-Object { 
        [PSCustomObject]@{
            Name = $_.Name
            Version = $_.Version
        }
    }
} elseif ((Get-Module -ListAvailable) -like "AWS*") {
    <# Action when this condition is true #>
    $awsversion = Get-Module | Where-Object{$_.Name -like "AWS*"} | ForEach-Object { 
        [PSCustomObject]@{
            Name = $_.Name
            Version = $_.Version
        }
    }
    Write-Host "The Following Modules"$awsversion.Name"is Installed Properly"
} else {
        Install-Module AWSPowerShell.NetCore -Confirm:$False -Force -AllowClobber
        $modules = Get-Module -ListAvailable | Where-Object{$_.Name -like "AWS*"}
        Import-Module -ModuleInfo $modules
        Write-Host "List of Imported Modules"
        Get-InstalledModule | Where-Object{$_.Name -like "AWS*"} | ForEach-Object { 
            [PSCustomObject]@{
                Name = $_.Name
                Version = $_.Version
            }
        } -ErrorAction SilentlyContinue -Verbose
    }
}


# AWSCLI Tools Function #
function awscliinstall {
    Param (    
        [Parameter(Mandatory=$True)][string]$awsuri        
    )    
    if ($null -eq (Get-Command cmd.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Unable to find cmd.exe in your PATH."
    } else {
        $command = "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12"
        Invoke-Expression $command
        Invoke-WebRequest -Uri $awscli -Outfile "C:\AWSCLIV2.msi" -UseBasicParsing
        #Invoke-WebRequest -Uri "https://awscli.amazonaws.com/AWSCLIV2.msi" -Outfile "C:\AWSCLIV2.msi" -UseBasicParsing
        $arguments = "/i `"C:\AWSCLIV2.msi`" /quiet"
        Start-Process msiexec.exe -ArgumentList $arguments -Wait
        Set-Variable -Name "awscliversion" -Value (aws --version) -ErrorAction SilentlyContinue
        Write-Host "The Following AWSCLI version "$awscliversion" is installed" -ErrorAction SilentlyContinue
    }
}


# Install AWSCLI TOOLS ##

$Folder = "C:\Program Files\AMAZON\AWSCLI*"
Write-Host "Test to see if Dotnet Installer location "$Folder"  exists"
if (Test-Path -Path $Folder) {
    $awsversion = & cmd /c "aws --version 2>&1"
    Write-Host "The Following AWSCLI version "$awsversion" is installed"
} else {
    Write-Host -ForegroundColor Magenta "Installing AWSCLIV2 version using SWITCH parameter"
    awscliinstall -awsuri $awscli
    Write-Host -ForegroundColor Yellow "[Time consumed to install AWSCLIV2 "$stopwatch.Elapsed.TotalSeconds" seconds]"
}

# Set API Keys
Set-AWSCredentials -AccessKey $accesskey -SecretKey $secretkey

# Set AWS Region, for example au-west-1
Set-DefaultAWSRegion $region




## Install Repricer Software ##
if (Test-path -LiteralPath "$env:Homdrive/External_GRVUSetup_2022142-3e120cb_20220517.exe") {
    Set-Location $env:HOMEDRIVE
    $arguments = "start /w External_GRVUSetup_2022142-3e120cb_20220517.exe /VERYSILENT /LicenseKey=F1E57ECFB1FE201B91BABBF3AFA05A1FEB8BCC041946C6D899F54EF4C63F5288 /Launch=False /NTIS=Yes /SUPPRESSMSGBOXES /LOG=$logs"
    Write-Host -ForegroundColor Magenta "The Enterprise Repricer Software Installation Started"
    Start-Process 'cmd' -Verb runAs -ArgumentList "/K $arguments"
    Write-Host -ForegroundColor Yellow "[Time consumed to install Repricer "$stopwatch.Elapsed.TotalSeconds" seconds]"
    
} else {
    Set-AWSCredential -ProfileName awsloginprofile
    Copy-S3Object -BucketName $bucket -Key $objects -Localfile $downloadlocation
    $arguments = "start /w External_GRVUSetup_2022142-3e120cb_20220517.exe /VERYSILENT /LicenseKey=F1E57ECFB1FE201B91BABBF3AFA05A1FEB8BCC041946C6D899F54EF4C63F5288 /Launch=False /NTIS=Yes /SUPPRESSMSGBOXES /LOG=$logs1"
    Write-Host -ForegroundColor Magenta "The Enterprise Repricer Software Installation Started"
    Start-Process 'cmd' -Verb runAs -ArgumentList "/K $arguments"
    Write-Host -ForegroundColor Yellow "[Time consumed to install Repricer "$stopwatch.Elapsed.TotalSeconds" seconds]"

}


# Create Project for Repricer ##
$repricerpath = "C:\Program Files\Milliman\MedInsight\GRVU 2022\GRVUConsole.dll"
$projectname = "Default1"
if (Test-path -LiteralPath $repricerpath) {
    Write-Host -ForegroundColor Magenta "The New Repricer Project Provisioning.."
    dotnet $repricerpath --Project=$projectname
    Write-Host -ForegroundColor Yellow "[Time consumed to create Repricer project is "$stopwatch.Elapsed.TotalSeconds" seconds]"
}



## Setting back the defaults"
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
$command = "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12"
Invoke-Expression $command


############################END OF SCRIPT#######################################################