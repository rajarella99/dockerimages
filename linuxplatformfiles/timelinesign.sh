#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail


#today=$(date +"%T_%h_%d_%Y")
today=$(date +"%T")
filename=otelcontribcol_windows_amd64.exe
find $PWD -maxdepth 4 -type f | grep "$filename" 2> /dev/null > path.txt
exepath=`cat path.txt`
echo $exepath
signfile=codesigning.p12
find $PWD -maxdepth 4 -type f | grep "$signfile" 2> /dev/null > codefile.txt
signpath=`cat codefile.txt`
echo $signpath




if [ -f `"$exepath" && "$signpath"` ]; then
echo "Signing the Otel Collector Contrib Executable using Timeline"
osslsigncode sign -pkcs12 "$signpath" -pass "apple@123" -n "opentelemetry contrib collector executable signing" -t "http://timestamp.digicert.com" -verbose -h sha256 -in "$exepath" -out "$PWD/bin/otelcontribcol_windows_amd64-${today}.exe"
else
echo "The required code signing certificate and otel collector contrib executable may be not available for signing"
exit 1
fi
