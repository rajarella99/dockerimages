#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail


filename=otelcontribcol_windows_amd64.exe
find $PWD -maxdepth 4 -type f | grep "$filename" 2> /dev/null > path.txt
exepath=`cat path.txt`
echo $exepath
signfile=codesigning.p12
find $PWD -maxdepth 4 -type f | grep "$signfile" 2> /dev/null > codefile.txt
signpath=`cat codefile.txt`
echo $signpath


osslsigncode sign -pkcs12 "$signpath" -pass "apple@123" -n "opentelemetry contrib collector executable signing" -t "http://timestamp.digicert.com" -verbose -h sha256 -in "$exepath" -out "/home/opentelemetry-collector-contrib/bin/otelcontribcol_windows_amd64-test8.exe"
