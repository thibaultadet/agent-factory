# Agent factory

Agent skills I use with Claude Code.

## Install

```sh
npx skills add thibaultadet/agent-factory
```

Or as Claude Code plugins:

```sh
claude plugin marketplace add thibaultadet/agent-factory
claude plugin install factory@thibaultadet
claude plugin install engineering@thibaultadet
claude plugin install explain@thibaultadet
```

## Skills

### Factory (`factory`)

Reviewers, read-only subagents each covering one lens of a branch, dispatched as `factory:<name>`:

- **bugs** — business bugs, crashes, breaking changes, missing tests.
- **data** — migrations, indexes, backfills, deploy-time compatibility.
- **mockup** — screenshots against the issue's mockup board, screen copy, design system.
- **perf** — N+1, query per row, missing indexes, needless re-renders.
- **security** — auth, record scoping, per-role permissions.
- **spec** — every line of the issue: delivered, missing or extra.
- **standards** — the project's coding standards on the changed modules.

Each reviewer follows the project's `docs/agents/reviewer-discipline.md`, reads the project's config in `docs/agents/factory.md` (coding standards, verification, reviewer triggers) and its checklist in `docs/agents/checklists/<name>.md`: the project's facts for its lens (auth, scoping root, roles, copy language, design system). Without a checklist the reviewer runs generic.

Skills:

- **push-pr** — clean the commits, check the pre-review points, push the branch and open (or update) a PR with a body from the `pr` skill.

### Engineering (`engineering`)

- **architect** — from a GitHub issue: implement → review → fix loop, verify, then PR — subagents sized per role (model/effort) to save tokens. Adapted from [Adrien Lupo's `ventilate`](https://github.com/adrienlupo/Claude-code-config/tree/main/skills/ventilate).
- **catch-up** — interactive zone-by-zone walkthrough of an agent-built branch, with attention points.
- **review-changes** — review staged and unstaged changes before committing.
- **take-over-pr** — rebase an agent-opened PR on main, resolve conflicts, quick review.

### Explain (`explain`)

From Taha K's article [Quatre façons d'expliquer un harnais](https://tahak.me/posts/quatre-facons-expliquer-un-harnais/).

- **diagram** — explain a technical subject as a single SVG diagram.
- **sim** — interactive step-by-step HTML page with scenarios.
- **ste** — dense explanation in Simplified Technical English style.
