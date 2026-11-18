---
name: pre-review
description: Verdict, shape and agent-head of the pre-review, the single comment an agent posts on its PR. Use when writing or updating a pre-review.
---
# Pre-review comment

The single comment an agent posts on its PR. It tells the maintainer how much reading the PR needs. Every routine and prompt that writes one follows this skill.

## Verdict

Pick the first verdict whose criteria hold, checking 🔴 first:

- 🔴 **sensitive**: the diff touches a file on the deny-list below, or a `(certain)` finding of any tag is still open (the orchestrator marks a ledger `open` point 🔴). The maintainer reviews in full.
- 🟢 **merge after CI without reading line by line**: all of these hold:
  - no open `(certain)` finding from any reviewer, whatever its tag;
  - no `(to confirm)` finding and an empty `Manual:` line: a point left for the reviewer is a point to read;
  - for a UI change, every cited board rendered side by side with its screen in the evidence (an **unrendered** board caps the verdict at 🟡, unless a 🔴 rule holds);
  - the VM feedback loops green;
  - no deny-listed file;
  - a small diff: under ~300 changed lines and under ~15 files.
- 🟡 **read only the listed points**: anything else. Each point the verdict rests on goes in the numbered list: a finding, a red or missing loop, a missing mockup render, a large diff.

## Sensitive deny-list

Any match makes the verdict 🔴. The list is `docs/agents/factory.md` § Pre-review › Sensitive deny-list; without it, the check is skipped and the *Manual* line says so.

## Factory paths

The factory's own controls. Each one the diff touches goes on the `Factory:` line (§ Shape), so the maintainer's merge approves the change knowingly. The line informs only: it leaves the verdict where § Verdict puts it, so an otherwise 🟢 PR stays 🟢. A path on both lists keeps its deny-list 🔴.

The list is `docs/agents/factory.md` § Pre-review › Factory paths; without it, the `Factory:` line is left out and the *Manual* line says so.

## Shape

English, two tiers: the numbered points a maintainer reads in about a minute, then the detail behind `<details>`. The points come first, right under the heading line; every other section follows them.

```
<!-- pre-review -->
## 🤖 Pre-review

1. 🔴 bugs · `file:line` — <the failure, in one line> _(certain)_
2. ⚪ spec · `file:line` — <the failure, in one line>, dismissed: <reason> _(certain)_
3. ⚡ security · `file:line` — <the failure, in one line> _(to confirm)_

🟡 **N points** · X lines, Y files · CI ✅ · <sensitive file touched, or "none">
Factory: <touched factory path>, <touched factory path>

Manual: <point> · <point>

agent-head: <40-char sha>

<details>
<summary>The N points in detail</summary>

**1. `file:line` 🔴** — <mechanism, evidence, what is left to confirm>

</details>

<details>
<summary>Evidence</summary>

<the evidence Markdown, pasted unchanged>

</details>

<details>
<summary>Zones and interface</summary>

- **<zone>** — <what it does, how it fits in>
  Interface: `Module.call(x) -> Data[…]`, raises `…`

</details>
```

- Each point is one line: ``N. <mark> <reviewer> · `file:line` — <failure> _(<confidence>)_``.
- `<reviewer>` is the name of the reviewer that raised the point, as the Rounds log writes it (`bugs`, `spec`, `standards`, `security`, `perf`, `data`, `mockup`, …). When several reviewers raised it, name the first. The factory's stats count points per reviewer from this name.
- The mark is ⚪ for a dismissed point, followed by its reason in the failure text; else a tag (🔴 business · 🔒 security/auth · 🗃️ migration/data · 💥 breaking · ⚡ perf · 🧪 tests · 📐 spec · 🧹 standards, or a loop or mockup gap) for a point still open.
- `Factory:` sits on the line right after the summary line and names every touched factory path (§ Factory paths), one per entry. A diff touching none has no `Factory:` line.
- With nothing to report, the list is « Nothing to report. » and the collapsed sections stay. Without evidence, the evidence section goes.
- `agent-head:` sits alone on its line, exactly once, and holds the full PR head SHA at the moment the comment is posted: `gh api repos/{owner}/{repo}/pulls/<pr> --jq .head.sha`. Fill it last, right before posting, and refresh it on every update of the comment.
