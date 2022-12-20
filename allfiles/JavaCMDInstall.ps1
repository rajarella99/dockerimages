## Time and Debug settings ##
$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
$DebugPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Continue'

# Script Required Variables ##
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force
#Set-Location $env:HOMEDRIVE
$javaurl = "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=247136_10e8cce67c7843478f41411b7003171c"

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
        Set-Location C:
        $command = "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12"
        Invoke-Expression $command        
        if (!(Test-path -LiteralPath C:\jre8u351.exe)) {
            Invoke-WebRequest -Uri $javaurl -Outfile "C:\jre8u351.exe" -UseBasicParsing
            Write-Host -ForegroundColor Magenta "downloading the java software completed "
        }        
        #$arguments = "start /wait C:\jre8u351.exe INSTALL_SILENT=Enable SPONSORS=Disable NOSTARTMENU=Enable REBOOT=Disable EULA=Disable AUTO_UPDATE=Disable STATIC=Enable"
        Write-Host -ForegroundColor Yellow "The Java Installation will be started"
        & cmd /c start /wait C:\jre8u351.exe INSTALL_SILENT=Enable SPONSORS=Disable NOSTARTMENU=Enable REBOOT=Disable EULA=Disable AUTO_UPDATE=Disable STATIC=Enable /L C:\javasetup.log
        #Start-Process "C:\jre8u351.exe" -Verb runAs -ArgumentList $arguments -Wait -PassThru
        Write-Host -ForegroundColor Yellow "The Java Installation will be completed quickly"
        $installedversion = Get-Wmiobject -Class win32_product | Where-Object {$_.Name -like "*Java*"} | Format-Table -Wrap
        Write-Output $installedversion > c:\app.txt
        $content = Get-Content C:\app.txt        
        Write-Host "The software Information" $content -Separator "`r`n"
        $Env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")      
        $javaversion = & cmd /c "java -version 2>&1"
        Write-Host -ForegroundColor Yellow "The Following "$javaversion[0].tostring()" is installed using function successfully"        
    }
}
# Install Java Runtime 8 version ##

$Folder = "C:\Program Files\Java\jre*"
Write-Host "Test to see if JAVA Installer location "$Folder"  exists"
if (Test-Path -Path $Folder) {
    $javaversion = & cmd /c "java -version 2>&1"
    Write-Host -ForegroundColor Magenta "The Following "$javaversion[0].tostring()" is already installed"
} else {
    Write-Host -ForegroundColor Magenta "Installing Java JRE version using SWITCH parameter"
    . jreinstall -javauri $javaurl -ErrorVariable javahandle
    Write-Host "the function status exit code "$javahandle.Count""
    while (0 -notmatch $javahandle.Count) {
        Write-Host "Running the Certificate Ignore Function"
        certignore
        Write-Host "Running The Java Installer Function after CertIgnore addition"
        jreinstall -javauri $javaurl -ErrorVariable javahandle
        if (0 -match $javahandle.Count) {Break}
    }
    Write-Host -ForegroundColor Yellow "[Time consumed to install JAVA JRE "$stopwatch.Elapsed.TotalSeconds" seconds]"
}



## JAVA CMD INSTALL ##
## IF ABOVE SCRIPT NOT WORKING THEN RUN BELOW FROM POWERSHELL or switch to CMD and start from start /w onwards full command below##
# & cmd /c start /w C:\jre8u351.exe INSTALL_SILENT=Enable SPONSORS=Disable NOSTARTMENU=Enable REBOOT=Disable EULA=Disable AUTO_UPDATE=Disable STATIC=Enable /L C:\javasetup.log


