---
name: improve-codebase
description: Cloud routine: pick the best architecture improvement, design it, build it and open a draft PR, unattended. Use only when a routine prompt names it.
---

# Improve codebase — cloud routine

A schedule (Mondays and Thursdays 03:00 Europe/Paris, cron `0 3 * * 1,4`) starts this session. It picks the best architecture improvement, designs it, builds it and opens a draft PR. Nobody reads or answers questions during the run: you play the user at every decision point.

`gh` GraphQL commands (`gh issue list`, `gh pr list`, `gh issue view`, `gh pr create`) are blocked here: reach GitHub through `gh api` (REST).

## 1. Report

First run the `docs/agents/factory.md` check of `${CLAUDE_PLUGIN_ROOT}/skills/factory/implement-issue/SKILL.md` § 1, before anything touches GitHub. There is no issue yet: where that check would comment on the issue, print `BLOCKED: docs/agents/factory.md has no § Feedback loops` instead and stop with GitHub untouched. Keep its notes of the other missing sections for § 5.

Run only once the previous run's PR is closed or merged: two open refactors would conflict, and a retry would duplicate work. Count the open ones: `gh api -X GET search/issues -f q='repo:{owner}/{repo} is:pr is:open "Opened by the improve-codebase routine"' --jq '.total_count'`. When it is above 0, print `SKIPPED: previous improve-codebase PR still open` and stop with GitHub untouched.

The `improve-codebase-architecture` skill cannot be called through the Skill tool (`disable-model-invocation`). Read its file and follow it: `ls ~/.claude/plugins/cache/mattpocock/mattpocock-skills/*/skills/engineering/improve-codebase-architecture/SKILL.md`. When that path is missing, print `BLOCKED: improve-codebase-architecture skill not installed` and stop with GitHub untouched.

Done when its report is written.

## 2. Pick

Take the report's Top recommendation, weighted toward quick wins (best improvement-to-effort ratio). Search open and closed issues and PRs for it: `gh api -X GET search/issues -f q='repo:{owner}/{repo} <keywords>' --jq '.items[] | {number,title,state,html_url}'` (this covers PRs too). When one already covers it, take the next-best candidate.

Done when you hold one uncovered candidate. When no candidate is uncovered, print `No uncovered candidate` and stop with GitHub untouched.

## 3. Design

Run the `mattpocock-skills:grilling` loop as a self-interview, answering each question from the codebase, `GLOSSARY.md`, `docs/adr/` and the coding standards doc of `docs/agents/factory.md`. Keep the domain-model updates the skill asks for: they ship in the same PR.

Done when every grilling question has an answer and the design is settled.

## 4. File the issue

The review and publish steps below read an issue. Open one for the candidate: `gh api repos/{owner}/{repo}/issues -f title=<title> -F body=@<file> -f 'labels[]=enhancement'`. Its body holds the problem, the design the grilling settled, the acceptance criteria, and a `## Mockup` section reading `No visible change` (a refactor keeps every screen as is; `docs/agents/mockup-section.md`), then the line `Filed by the improve-codebase routine (factory:improve-codebase).` Call its number `<n>`.

Rename the session's branch: `git branch -m claude/<n>-<slug>`, the slug 3 to 5 words of the title, kebab-case. Note the start time: `date -u +%Y-%m-%dT%H:%M:%SZ`.

Done when the issue exists, its number is known and the branch carries it.

## 5. Build, review, publish

Follow `${CLAUDE_PLUGIN_ROOT}/skills/factory/implement-issue/SKILL.md` from § 2 to the end for issue `<n>`, parent `main`. Its builder builds with the `tdd` skill through `implement.md`; the build is done when the new tests are green and the existing test suite of every touched area of `docs/agents/factory.md` § Feedback loops passes. Its § 1 does not apply: this routine filed the issue and ran the config check in this routine's § 1. The missing sections noted there go on the *Manual* line of `implement-issue.md` § 4.

One addition to its § 4: the PR body opens with `Opened by the improve-codebase routine (factory:improve-codebase).`

Done when the PR URL is printed.
