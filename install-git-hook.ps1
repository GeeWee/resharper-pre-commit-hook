$ErrorActionPreference = "Stop"
Set-strictmode -version latest

$OutFile = "./archive.tar.gz"
$OutUnzippedDirectory = "./unzipped-archive"
$GitResharperFolder = "../.git/hooks/resharper"
$PreCommitFile = "../.git/hooks/pre-commit"
$CliUrl = "https://download-cf.jetbrains.com/resharper/ReSharperUltimate.2019.3.1/JetBrains.ReSharper.CommandLineTools.Unix.2019.3.1.tar.gz"

Invoke-WebRequest -Uri ${CliUrl} `
    -OutFile "./${OutFile}"

# Create outdir if not exists

if(!(Test-Path -Path $OutUnzippedDirectory )){
    New-Item -ItemType directory -Path $OutUnzippedDirectory
}
tar -xf "./${OutFile}" -C $OutUnzippedDirectory

#Copy into git directory
#Remove-Item -Path $GitResharperFolder - Having some permission problems when trying to delete this
Move-Item -Path $OutUnzippedDirectory -Destination $GitResharperFolder -Force

# Run the following git hook on pre-commit
@'
#!/bin/sh

# Exit on error
# exit when any command fails
set -e
set -o pipefail

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' ERR

echo "Current working dir ${pwd}"

# - Actual script
echo "Staged files"
STAGED_FILES=`git diff --name-only --cached`

# Build edit string, by replacing newlines with semicolons.
# --diff-filter=d only filters files that are not deleted, which means we won't have trouble adding them afterwards
INCLUDE_STRING=`git diff --name-only --cached --diff-filter=d | sed ':a;N;$!ba;s/\n/;/g'`
echo "Include string: $INCLUDE_STRING"

# Edit your project files here
echo "Editing files"
sh ./.git/hooks/resharper/cleanupcode.sh --profile="Built-in: Reformat Code" ./OAI.sln --include="$INCLUDE_STRING"

# Restage files
echo "Restaging files: $STAGED_FILES"
echo $STAGED_FILES | xargs -t -l git add

echo "pre-commit hook finished"
'@  | Set-Content -Path $PreCommitFile

# If chmod exists, use it on the file.
if (Get-Command chmod -errorAction SilentlyContinue)
{
    chmod u+x $PreCommitFile
}

echo "Git hook created. Make sure to delete the archived file afterwards"