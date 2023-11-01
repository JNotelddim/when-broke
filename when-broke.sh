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
if [ $? -ne 0 ]; then 
    echo "Failed to navigate to the target directory."
    exit 2
else
    echo "... Current pwd: $(pwd)."
fi

echo "... Validating that current directory is a git project..."
echo $'\n$ git status'
git status

if [ $? -eq 0 ]; then
    echo "[Command Executed Successfully]"
else
    echo "[Command Failed]"
fi

echo $'\n$ git fetch -a'
git fetch -a

initialBranch=$(git branch --show-current)
echo "... Current branch: $initialBranch."

echo "... stashing any work-in-progress changes ..."
echo $'\n$ git stash -u'
# `> /dev/null` redirects stdout to /dev/null: silencing this command's output.
git stash -u > /dev/null

echo $'\n$ git checkout '"$developmentBranch"
# silence command stdout
git checkout $developmentBranch > /dev/null 2>&1

echo $'\n$ git pull'
# silence command stdout
git pull > /dev/null

echo "... Validating that the target command: $brokenCommand is broken. ..."
echo $'\n$'"$brokenCommand"
# silence command stdout AND stderr
$brokenCommand > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "[Command Executed Successfully]"
    echo "\n\nYour broken command does not appear to be broken."
    exit 2
else
    echo "[Command Failed, as expected.]"
fi


echo "... Checking out latest known working commit: $lastWorkingCommit ..."
echo $'\n$ git checkout '"$lastWorkingCommit"
# silence command stdout AND stderr
git checkout $lastWorkingCommit > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "[Failed to check out 'lastWorkingCommit'.]"
    exit 2
fi

echo "... Validating that the target command: $brokenCommand is broken ..."
echo $'\n$ '"$brokenCommand"
# silence command stdout AND stderr
$brokenCommand > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "[Command Executed Successfully]"
else
    echo "[Command Failed]"
    echo "\n\nYour \"lastWorkingCommit\" does not appear to have a valid working state."
    exit 2
fi

echo "... Clear any changes ..."
echo $'\n$ git reset HEAD --hard'
# silence command stdout
git reset HEAD --hard > /dev/null

echo "... Back to top of developmentBranch: $developmentBranch ..."
echo $'\n$ git checkout '"$developmentBranch"
git checkout $developmentBranch > /dev/null

echo "... Gather list of all commits between HEAD and lastWorkingCommit ..."
echo $'\n$ git rev-list HEAD ^'"$lastWorkingCommit"
commits=$(git rev-list HEAD ^$lastWorkingCommit)
commitsArr=($commits)
numCommits=${#commitsArr[*]}
echo $'\n'"$numCommits found between HEAD and $lastWorkingCommit."

echo "... Searching  ..."

#### BINARY SEARCH OF COMMITS, LOOKING FOR ONE WHERE IT WORKS AND THE NEXT DOES NOT.

# Binary search:
# - input: sorted list of items
# - each iteration: 
#  - take middle item of list, compare to target, disqualify one half or the other.

found=false
i=0
workingArr=($commits)

# TODO: remove "10" hardcoded case and use a real $numCommits-derived value
# while [[ $found == false && i -lt $numCommits ]]; do
while [[ $found == false && i -lt 10 ]]; do
    # bash uses floor rounding natively
    numItems=${#workingArr[@]}
    midItemIndex=$(( $numItems / 2 ))
    midItem=${workingArr[$midItemIndex]}

    echo $'\n'"[$i]; workingArrCount: ${#workingArr[*]}; midIndex: $midItemIndex; commit: $midItem"
    echo "$ git checkout $midItem"
    git checkout $midItem > /dev/null 2>&1
    echo "$ $brokenCommand"
    $brokenCommand > /dev/null 2>&1

    isFunctioning=($? -eq 0)
    ## NOTE: the commits array is in ** reverse-chronological order ** !!!!
    if [ $isFunctioning == true ]; then
        echo "[Working] Go further forward."
        # Re-assign working array to be 0 => 'mid'
        workingArr=("${workingArr[@]:0:$midItemIndex}")
        echo "New Working Array, num items: ${#workingArr[*]}, midItemIndex: $midItemIndex, newFirstItem: ${workingArr[0]}, newLastItem: ${workingArr[-1]}"
    else
        echo "[Broken] Go further back."
        # Re-assing working array to be 'mid' => [-1]
        workingArr=("${workingArr[@]:$midItemIndex}")
        echo "New Working Array, num items: ${#workingArr[*]}, midItemIndex: $midItemIndex, newFirstItem: ${workingArr[0]}, newLastItem: ${workingArr[-1]}"
    fi

    i=$(( i + 1 ))
done



echo "... Cleaning up ..."
echo $'\n$ git reset HEAD --hard'
# silence command stdout
git reset HEAD --hard > /dev/null

echo $initialBranch
if [ $initialBranch != "" ]; then
    echo $'\n$ git checkout '"$initialBranch"
    git checkout $initialBranch > /dev/null
else
    echo $'\n$ git checkout '"$developmentBranch"
    git checkout $developmentBranch > /dev/null
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
