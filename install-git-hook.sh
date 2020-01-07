#!/usr/bin/env bash
# Exit on error
# exit when any command fails
set -e
set -o pipefail

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' ERR

outFile="./resharper-cli.tar.gz"
gitResharperFolder="./.git/hooks/resharper"
preCommitFile="./.git/hooks/pre-commit"
cliUrl="https://download-cf.jetbrains.com/resharper/ReSharperUltimate.2019.3.1/JetBrains.ReSharper.CommandLineTools.Unix.2019.3.1.tar.gz"

echo "Fetching Resharper CLI tools"
curl ${cliUrl} > ${outFile}

echo "Cleaning up old versions"
rm -rf ${gitResharperFolder} # Delete any old versions
mkdir -p ${gitResharperFolder}
echo "Extracting into ${gitResharperFolder}"
tar -xf "./${outFile}" -C ${gitResharperFolder}

echo "Adding pre-commit hook"
# The pre-commit hook
cat > ${preCommitFile} <<'EOL'
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
EOL

echo "Cleaning up..."
rm -f ${outFile}