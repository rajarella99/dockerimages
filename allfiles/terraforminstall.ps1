# Local path to download the terraform zip file
$DownloadPath = 'C:\Terraform\'

# Reg Key to set the persistent PATH 
$RegPathKey = 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment'

 # Create the local folder if it doesn't exist
 if ((Test-Path -Path $DownloadPath) -eq $false) { $null = New-Item -Path $DownloadPath -ItemType Directory -Force }
 
 #Download file path
 $DownloadFile = "$env:TEMP\terraform.zip"

 #Webrequest to download Terraform Zip file
Invoke-WebRequest -Uri  'https://releases.hashicorp.com/terraform/1.1.1/terraform_1.1.1_windows_amd64.zip' -OutFile $DownloadFile

#Extract Terraform Zip file
Expand-Archive -Path $DownloadFile -DestinationPath $DownloadPath -Force

#Remove after copied to destination
Remove-Item -Path $DownloadFile -Force

# Setting the persistent path in the registry if it is not set already
if ($DownloadPath -notin $($ENV:Path -split ';'))
{
     $PathString = (Get-ItemProperty -Path $RegPathKey -Name PATH).Path
     $PathString += ";$DownloadPath"
     Set-ItemProperty -Path $RegPathKey -Name PATH -Value $PathString
     # Setting the path for the current session
     $ENV:Path += ";$DownloadPath"
}
#Check the version of Terraform
Invoke-Expression -Command "terraform version"
$version = terraform version
Write-Host  "The Present version on this worker is $version"