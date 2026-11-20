---
name: take-over-pr
description: Take over a PR, typically one an agent opened. Rebase it on main (or sync its stack when stacked), resolve conflicts, then do a quick review against the spec and the pre-review points.
disable-model-invocation: true
---

Take ownership of a PR: bring it up to date with `main`, then run a **quick review** that answers one question: can this merge? A full standards audit belongs to `/code-review`.

The argument is a PR number. If there is none, use the PR of the current branch (`gh pr view`).

## 1. Check out the PR

- Require a clean working tree. If it is dirty, stop and ask.
- `gh pr checkout <n>`, then `git fetch origin main`.
- Note the PR state and its base (`gh pr view <n> --json state,isDraft,mergeable,baseRefName,statusCheckRollup`). If the PR is merged or closed, stop and report. A draft PR skips CI: its checks read `SKIPPED`, not green.
- Note `git merge-base origin/main HEAD` as the **old base**, before any rebase.

Done when HEAD is the PR head branch and `origin/main` is fresh.

## 2. Rebase on main if behind

A PR whose `baseRefName` is not `main` is **stacked**: its parent is another PR's branch. Never `git rebase origin/main` it, that replays the parent's commits and detaches the branch from its stack. Invoke the `gh-stack` skill and find the PR's stack on GitHub, not in local tracking (`gh stack view` reads local tracking only):

- `gh stack checkout <n>` succeeds → the stack is checked out.
- It answers that the PR is not part of a stack → check the **parent PR**, the open PR whose head is `baseRefName` (`gh pr list --head <baseRefName> --json number`). When `gh stack checkout <parent>` finds a stack, the PR was opened on top of it but never linked: `gh stack link <parent> <n>` adds it to that stack, then `gh stack checkout <n>`. Name the link in the report.
- Neither PR is in a stack → the stack was never initialised: say so and ask before rebuilding it by hand.

Then `gh stack sync` and `gh stack rebase`, and continue at the checks below.

- `git merge-base --is-ancestor origin/main HEAD` succeeds → already up to date. Skip to step 3.
- Otherwise run `git rebase origin/main`. On conflict, invoke the `resolving-merge-conflicts` skill. The PR's intent comes from its body and linked issue. `main`'s intent comes from the commits that landed since the branch diverged.
- After a rebase, run the checks for the areas the PR touches:
  - Run the lint then test commands of `docs/agents/factory.md` § Feedback loops for each area the PR touches. Scope the tests to the changed code and the code that caused a conflict; the whole suite runs in CI.
- Leave the rebased branch local. Pushing is the user's call.

Done when the branch contains `origin/main` and the checks are green. If a check stays red after one honest fix attempt, stop and report it.

## 3. Gather the review inputs

**Spec**: the issues the PR implements. Look in the `## Issues` section of the PR body, in `closingIssuesReferences`, and in the branch name (`issue/<n>`). Read each issue with `gh issue view <n> --json title,state,body,comments` (plain `--comments` can print nothing), and follow its parent PRD when it names one. An `## Interface` section in an issue is a contract (see the coding standards doc `docs/agents/factory.md` § Coding standards names).

**Siblings**: the other issues of that PRD own the work this PR leaves out. Find the parent with `gh api 'repos/{owner}/{repo}/issues/<n>/parent' --jq .number` (404: none) or the PRD the issue names, then list its sub-issues:
```sh
gh api 'repos/{owner}/{repo}/issues/<prd>/sub_issues' --jq '.[] | "#\(.number) [\(.state)] \(.title)"'
```
Read the body of every sibling whose title touches what the PR does.

**Mockup**: the design the issue or PRD names (a mockup file, a design artifact link, a board the repo's design index maps to the issue). The repo's verification skill says how to render it next to the app.

**Pre-review**: the latest PR comment whose body starts with `<!-- pre-review -->`. Its numbered points are the attention points. Its `Manual:` line lists checks only a human can run.

If the spec or the pre-review is missing, say so and review with the one you have.

## 4. Quick review

Read the diff (`git diff origin/main...HEAD`) with both inputs next to it. Give every item a verdict:

- **Each acceptance criterion / interface item**: ✅ implemented (cite `file:line`, plus the spec covering it) · ⚠️ partial · ❌ missing.
- **Each pre-review point**, checked against the code as it is now (after the rebase): 🔴 still true · ✅ fixed · ⚪ false positive (say why).
- **The mockup**, when the spec names one: each screen the PR changes, rendered by you side by side with its mockup → ✅ matches · ⚠️ differences (list each one). A pre-review that sends the mockup to `Manual:` hands that render to you.
- Anything the rebase changed in behaviour, even if both sides were fine alone.
- Shared code `main` gained since the branch diverged (a concern, hook, component or service: `git diff --stat <old base> origin/main`) that the PR's new code re-implements: ❌ owned by this PR, even when a sibling file still does it by hand.

Every ⚠️ and ❌ names its owner: **this PR**, or the sibling issue that covers it (cite `#n`). Propose a new issue only for a gap no sibling covers.

Done when every criterion, every pre-review point and every mockup screen has a verdict backed by code or screenshots you saw, not by the pre-review's own wording, and every gap has an owner.

## 5. Report

Keep it terse, in the terminal:

1. Rebase: `up to date` · `rebased locally, N conflicts resolved (files), push pending` · `blocked (why)`. For a stacked PR, add `stack #<s>` and `linked` when step 2 linked it.
   CI: `green` · `red (checks)` · `skipped: draft → gh pr ready <n>`.
2. Verdict: **ready to merge** · **needs fixes** · **blocked**. Any ⚠️ or ❌ owned by this PR, mockup differences included, makes it **needs fixes**.
3. Table: spec items, mockup screens, then pre-review points, with their verdicts and owners.
4. Manual checks still open, copied from the pre-review's `Manual:` line.

The terminal is the only output. Leave fixes, the push, PR comments and the merge to the user.
