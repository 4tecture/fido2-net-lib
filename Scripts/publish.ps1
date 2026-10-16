param(
    [Parameter(Mandatory=$true)]
    [System.IO.FileInfo]
    [String] $path,
    [Parameter(Mandatory=$true)]
    [String] $source,
    [Parameter(Mandatory=$true)]
    [String] $apiKey) #Must be the first statement in your script

# if ($nupkgPath -eq "") {
#     $scriptDir = Split-Path $myinvocation.mycommand.path -Parent
#     $root = Split-Path $scriptDir -Parent
#     $target = Join-Path $root "Src" | Join-Path -ChildPath "bin" | Join-Path -ChildPath "release"
    
#     Write-Error "No nupkg path supplied"
#     Write-Host "nupkgs found in release folder $target\:"
#     $files = Get-ChildItem $target -Filter *.nupkg
#     Write-Host $files
#     exit 1
# }

$path2 = $path;

$path = Resolve-Path $path
if($path2 -ne $path) {
Write-Host "Resolved $path2 -> $path"
}
Write-Host "Publishing $path..."
dotnet nuget push $path --source $source --api-key $apiKey

Write-Host "Done $path..."
