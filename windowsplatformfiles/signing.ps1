$VerbosePreference = 'continue'
$FileName = "D:\build\opentelemetry-collector-contrib\cmd\otelcontribcol\otelcontribcol.exe"
while (!(Test-Path $FileName)) { Start-Sleep 10 }
if (Test-Path $FileName) {
  signtool.exe sign /tr http://timestamp.digicert.com /td sha256 /fd sha256 /f "D:\build\opentelemetry-collector-contrib\cmd\otelcontribcol\mainpublicprivate.pfx" /p apple@123 $FileName
}

#signtool.exe sign /tr http://timestamp.digicert.com /td sha256 /fd sha256 /f .\mainpublicprivate.pfx /p apple@123 .\hello.exe


#osslsigncode sign -pkcs12 "/mnt/c/path/to/certificate.p12" -pass "certificate password" -n "My Application Name" -i "https://www.mywebsite.com" -t "http://timestamp.comodoca.com/authenticode" -in "/mnt/c/path/to/executable.exe" -out "/mnt/c/path/to/executable.exe"


#osslsigncode sign /tr http://timestamp.digicert.com /td sha256 /fd sha256 /f .\mainpublicprivate.pfx /p apple@123 .\otelcontribcol_windows_amd64-test.exe

