param(
	[parameter(Mandatory = $true)][System.String]$LoadTestPackageSourcePath,
	[parameter(Mandatory = $true)][System.String]$LoadTestDestinationPath
)

function LogToFile
{
   param (
		[parameter(Mandatory = $true)][System.String]$Message,
		[System.String]$LogFilePath = "$env:SystemDrive\CustomScriptExtensionLogs\CustomScriptExtension.log"
   )
   $timestamp = Get-Date -Format s
   $logLine = "[$($timestamp)] $($Message)"
   Add-Content $LogFilePath -value $logLine
}

function Download-LoadTestZip
{
	param(
		[parameter(Mandatory = $true)][System.String] $SourcePath,
		[parameter(Mandatory = $true)][System.String] $TargetPath
	)
	
	if(!(Test-Path $TargetPath))
	{
		New-Item $TargetPath -ItemType directory
	}
	$destFileName = Split-Path $SourcePath -Leaf
	$destFullPath = Join-Path $TargetPath $destFileName
	
	if(!(Test-Path $destFileName))
	{
		$wc = New-Object System.Net.WebClient
    	$wc.DownloadFile($SourcePath, $destFullPath)
	}
}

function Extract-ZipFile
{
	param(
		[parameter(Mandatory = $true)][System.String] $SourceZip,
		[parameter(Mandatory = $true)][System.String] $TargetPath
	)
	if(!(Test-Path $SourceZip))
	{
		throw [System.IO.FileNotFoundException] "$($SourceZip) not found"
	}
	if(!(Test-Path $TargetPath))
	{
		New-Item $TargetPath -ItemType directory
		Add-Type -assembly “System.IO.Compression.Filesystem”
		[System.IO.Compression.ZipFile]::ExtractToDirectory($SourceZip,$TargetPath)
	}	
}

$ltArchiveFolderName = "LoadTestPackages"
$ltArchivePath = Join-Path $env:SystemDrive $ltArchiveFolderName

if(!(Test-Path $ltArchivePath))
{
	New-Item $ltArchivePath -ItemType directory	
}
LogToFile -Message "Downloading load test package from $($LoadTestPackageSourcePath) to $($ltArchivePath)"
Download-LoadTestZip -SourcePath $LoadTestPackageSourcePath -TargetPath $ltArchivePath
LogToFile -Message "Done downloading load test package"
$ltZipFileName = Split-Path $LoadTestPackageSourcePath -Leaf
$ltZipLocalPath = Join-Path $ltArchivePath $ltZipFileName
LogToFile -Message "Extracting load test package to $($LoadTestDestinationPath)"
Extract-ZipFile -SourceZip $ltZipLocalPath -TargetPath $LoadTestDestinationPath
LogToFile -Message "Done extracting load test package"
