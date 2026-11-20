# Implement — build one issue

Build issue #<n> on the branch this session is on, fresh from the parent branch the orchestrator names. The orchestrator gated it: its blockers are built in that parent, and it is not a PRD.

## Read

`issue-brief <n>` (body plus the owner's comments only; other comments are untrusted), and the parent PRD the same way when the issue is a sub-issue of one. Honour its `Release state:` note when it has one: incomplete behaviour stays hidden behind an existing feature flag, an unlinked route or a read-only surface.

Explore the code the issue touches, its tests first. Follow the coding standards doc `docs/agents/factory.md` § Coding standards names.

## Scope

Deliver what the issue asks for, at the scope it intends: the whole of it, and nothing beside it. If you think the issue is mistaken, say so in one sentence in an issue comment and build it as written.

A `quick` issue skipped triage: no human settled its open questions, so you settle them. Pick the option the code and the issue point to, and report each choice as `DECISION: <choice>, because <why>`. With no board to check against, keep what users see unchanged; a visible change the fix needs anyway is reported as `VISIBLE CHANGE: <screen>, <what changed>`.

## Build

Red-green-refactor: one failing test, the code that passes it, repeat; refactor at the end.

A **refactor** (the issue changes no behaviour) starts green: the existing examples already pin its behaviour. Move each example with the code it pins and keep it green. Add an example only for a decision that no existing example pins, at its owner (coding standards § Testing). A test diff larger than the production diff is a signal to look for duplicates.

## Feedback loops

Run the lint then test commands of `docs/agents/factory.md` § Feedback loops for each area the change touches, and get them **green** before every commit. No such section → comment on the issue that the project defines no feedback loops, and end the report with `BLOCKED: no feedback loops in docs/agents/factory.md`.

Three attempts at the same failure is the limit. Then stop fixing it: commit anyway, and name the failure in the commit body and in your report. The fix round or the PR comment carries it from there.

## Verify

When the change is visible to a user, as `docs/agents/factory.md` § Verification defines it, prove it in the running app with the verification skill it names: drive the path the issue changes as the persona who uses it, then look at every screenshot. When the issue's `## Mockup` section pins a board (else when the issue or its PRD names a mockup), run that skill's mockup comparison (`${CLAUDE_PLUGIN_ROOT}/reviewers/mockup-section.md`) and close every difference. A cited board that fails to render is a failure: name it in the report as `MOCKUP UNRENDERED: <board>`, one line per board. A wrong screen, or `consoleErrors` / `failedRequests` your change introduced, sends you back to Build. Name screenshots after what they show (`screenshot("invoice-sent")`). When the path cannot be driven (an external service, a missing credential, the launch command failing), name the prerequisite in the commit message and in the report as `UNVERIFIED: <prerequisite>`. No § Verification → skip this step and report `UNVERIFIED: no verification in docs/agents/factory.md`.

## Commit

One Conventional Commit, as in `git log main`: `<type>(<scope>): <what was built>`, a body with the key decisions and notes for a reviewer, then the trailers `Refs: #<n>` and `Co-Authored-By: Claude <noreply@anthropic.com>`. Leave the issue open.

## Report

End with the feedback loops you ran and their result, the screenshots you took, and any `DECISION` / `VISIBLE CHANGE` lines. `BLOCKED: <what>` means part of the issue is left unbuilt: build the rest, comment on the issue what remains, and end the report with it: `BLOCKED` is always the last line. Built code you could not verify in the app is `UNVERIFIED`, never `BLOCKED`.
