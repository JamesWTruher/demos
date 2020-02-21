param ( [switch]$NoClean )
Write-Verbose -verbose "Initializing scale demo"
Write-Verbose -verbose "Checking for docker"
if ( -not (get-command -erroraction silentlycontinue docker)) {
    throw "Docker not installed, install and try again"
}

Write-Verbose -verbose "Building docker image"
@"
FROM mcr.microsoft.com/powershell:preview
RUN apt update > /dev/null
RUN pwsh -c install-module -force formattools -scope allusers
CMD ["pwsh"]
"@ > Dockerfile

$result = docker build -t scale:demo . 2>&1

if ( $LASTEXITCODE -eq 0 -and -not $NoClean ) {
    Write-Verbose -verbose "Removing docker file"
    Remove-Item Dockerfile
}
else {
    throw $result
}

Write-Verbose -verbose "Checking for formattools module"
if ( -not (Get-Module -Name formattools -erroraction silentlycontinue)) {
    install-module -confirm -scope currentuser -name formattools
}

Write-Verbose -verbose "Retrieving demo script"
$driver = "https://gist.githubusercontent.com/JamesWTruher/f721b6020b8bb6b6856cf58b12a6a4b9/raw/dbab454665a55e696ad00d65e74f9d60e9d7c3b1/Invoke-SCaLEDemo.ps1"
invoke-webrequest -uri $driver -outfile invoke-scaledemo.ps1

@"

To run the scale demo, just type:
PS> ./invoke-scaledemo.ps1

"@

