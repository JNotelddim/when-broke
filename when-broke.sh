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

# notes for improvements:
# - load from config file + args
# - use a legit search alg rather than just iterating.
# - once the "breaking commit" is found, check if it's a squash commit, and if so, expand into that branch to repeat. (Q: does this open the door to recursion? Maybe that's opt-in?)
# - put it in an npm package: include a README and an example repo showing a use-case?
