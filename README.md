# when-broke

`when-broke` is a bash script which aides in finding the exact commit when a
command broke within a git repository.
In other words it tells you when a command broke.
** In other words, it's `git bisect` (lol) **

It is not polished or maintained.
It just helped me find what I needed this one time.

## How to use

Edit the `./when-broke.sh` top-level config variables to match your use-case:

- `projectDir`
- `developmentBranch`
- `brokenCommand`
- `lastWorkingCommit`

### Pre-reqs:

- A git repository
- A command in the git repository which worked until some unknown point in time
- **Most importantly** the commit SHA for when the command in question was last known to be working.

## How it works

This script does the following:

1. Validates that the `projectDir` exists and is in fact a git repository.
2. Fetches all latest changes from remote origins.
3. Stashes and working changes (including unstaged changes!!), and notes the working branch.
4. Checks out the development branch (`main` by default).
5. Pulls the latest development branch changes.
6. Validates that the `brokenCommand` is broken with the latest changes.
7. Checks out the `lastWorkingCommit` and validates that the `brokenCommand` DID work then.
8. Clears any file changes that may have occurred from the `brokenCommand` running successfully.
9. Checks out latest on `developmentBranch` again.
10. Gathers a list of _ALL_ commits between `lastWorkingCommit` and the lastest on `developmentBranch`.
11. Uses binary search to find a commit where the `brokenCommand` breaks
    (it must not have been broken in the commit directly before the "breakingCommit").
12. Repeats step 8.
13. Checks out the initial working branch that had been noted in step 3.
14. Returns the breaking commit SHA.

### Notes

- I've put in a super arbitrary base case of 15 iterations just to prevent it from looping forever.
  If your initial array is many thousands of items, you'll possibly need more than 15 iterations.
- I used a lot of command output suppression (sometimes just `stdout` but sometimes also `stderr`
  depending). This could cause problems if errors other than the anticipated ones occur.
- I'm sure there are bugs all throughout. You're welcome to point them out or open a PR.
  I might not have time to apply any changes for awhile though.
- There are some additional potential improvements (like a config file / arg handling) which I've
  listed in a big comment at the bottom of the script file.
