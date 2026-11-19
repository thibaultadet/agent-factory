---
name: dispatch
description: Dispatches GitHub issues to the cloud implement-issue routine through factory-dispatch, after a dry run the user approves. Use when the user wants to dispatch, launch or fire issues to the factory, or start agent runs on ready-for-agent issues.
allowed-tools: Bash
---

Start cloud `implement-issue` runs with `factory-dispatch` (on Claude's `PATH` through the plugin's `bin/`). Firing starts paid cloud runs and assigns each issue to the user.

## 1. Build the arguments

From the user's request, pick the flags `factory-dispatch` takes (header of `bin/factory-dispatch`):

- **targeted**: issue numbers named, or "this issue" when the conversation is about exactly one issue → pass the numbers (they skip the eligibility filter; the routine's gate still checks);
- "stacked", "on top of the open PR" → `--stack`;
- a count ("two issues", "max 3") → `--max=N`.

Nothing named → **sweep**: no argument, every eligible issue, 5 at most.

"This issue" with several candidate issues in the conversation → ask which one.

A targeted dispatch is the user's go: skip to step 4. A sweep goes through steps 2 and 3.

## 2. Dry run

```sh
factory-dispatch --dry-run <args>
```

Show the user, as a short table: each issue that would fire (and the branch it stacks on), then each skipped issue with its reason. For a skip that `--stack` would lift, say so.

`No eligible issue.` → report it with the skip reasons and stop.

Done when the user has seen every issue that would fire.

## 3. Get the go

Ask the user to confirm the list. Their answer may narrow it: rerun the dry run with the new arguments (issue numbers, `--max`) and show it again. Fire only on an explicit go for the list shown last.

## 4. Fire

```sh
factory-dispatch <the targeted args, or those of the approved dry run>
```

It fails on a missing `FACTORY_ROUTINE_URL` or `FACTORY_ROUTINE_TOKEN` → tell the user to fill `.claude/factory.env` (README, Install § 4: the routine's page shows both) and stop.

Report one line per issue: `#<n>` → its session URL. Done when every fired issue has its URL, or its error.
