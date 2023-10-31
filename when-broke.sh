#!/usr/bin/env bash

# PSEUDOCODE:

# check out latest on <main>
#
# validate that "y" is currently erroring. (if not, throw)
#
# check out last known working commit for "y" (could vary by config or args) "z", validate that it did not error.
#
# iterate from "z" to HEAD trying "y"
# - when most recent functional commit is found, return a message sharing the SHA

echo "__ In $(pwd) __"

projectDir="$HOME/dev/past-projects/primasun-mira/primasun-mobile"
developmentBranch="main"
brokenCommand="yarn gql:compile"
lastWorkingCommit="cbfe239d"


echo "... Going to target directory: $projectDir ..."
cd $projectDir
echo "... Current pwd: $(pwd)"

echo "... Validating that current directory is a git project..."
echo "$ git status ..."
git status

if [ $? -eq 0 ]; then
    echo "[Command Executed Successfully]"
else
    echo "[Command Failed]"
fi

echo "__ Fin. __"




# Just ignore the notes below...
# _____________________________


# cat <<END
# # Long form notes
# _______________________
#
# ## Goal: given a yarn package script which is not working with the latest changes,
# get the most recent commit where the script was functioning.
#
# ### Input:
# - script to run
# - last working commit [initial commit of repo if none]
#
# ### Assumptions:
# - This script runs git commands in the correct working directory with the correct
# git account information.
#
# ### Steps:
#
# 1. Check current working directory,
#   a) validate that it's git directory,
#   b) validate that there is an authenticated git user (?)
#
# 2. Check out the latest on `main` (or other developmentBranch).
#
# 3. Check that the selected script is in fact, a script, and not working.
#   a) Try running it, expect it to fail.
#
# 4. Validate that the selected script did in fact work at the "last working commit".
#   a) try checking out the commit, (might fail)
#   b) run the script, expect it to succeed.
#
# 5. Search for the most recent commit where the script was working.
#
# ....
#
# ### Improvements:
# - load variables (script, last working commit, working directory) from args or
#   from a config file if no args are provided.
# - search alg efficiencies
# - breaking commit: squash commit recursion?
# - compile a platform-agnostic executable: make it packageable into npm?
# END
