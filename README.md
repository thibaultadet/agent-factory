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

Requires the [`mattpocock-skills`](https://github.com/mattpocock/skills) plugin (`tdd`, `grilling`, `improve-codebase-architecture`).

Routines, skills a cloud routine's prompt names (« Run the `factory:implement-issue` skill. »):

- **implement-issue** — gate one issue, then build → polish → review → fix until clean, and open a draft PR with its pre-review.
- **improve-codebase** — pick, design and build the best architecture improvement, unattended.
- **cloud-retro** — turn the maintainer's rework of agent PRs into harness-fix issues.

Scripts, on Claude's `PATH` while the plugin is enabled (`bin/`):

- **factory-dispatch** — fire one `implement-issue` run per issue an agent can start now (`--dry-run`, `--stack`, `--max=N`). Reads `FACTORY_ROUTINE_URL` and `FACTORY_ROUTINE_TOKEN` from the project's `.claude/factory.env`; add that path to the project's `.gitignore`.
- **issue-brief** — an issue as an agent may read it: body plus the owner's comments only.
- **factory-stats** — merge rate, rework and findings per reviewer of the agent PRs (`--since=YYYY-MM-DD`).

The routines read the project's `docs/agents/factory.md` (feedback loops, coding standards, verification, reviewer triggers, pre-review lists).

Reviewers, read-only subagents each covering one lens of a branch, dispatched as `factory:<name>`:

- **bugs** — business bugs, crashes, breaking changes, missing tests.
- **data** — migrations, indexes, backfills, deploy-time compatibility.
- **mockup** — screenshots against the issue's mockup board, screen copy, design system.
- **perf** — N+1, query per row, missing indexes, needless re-renders.
- **security** — auth, record scoping, per-role permissions.
- **spec** — every line of the issue: delivered, missing or extra.
- **standards** — the project's coding standards on the changed modules.

Each reviewer follows the plugin's `reviewers/discipline.md` (inputs, tracing, later passes, output), reads the project's config in `docs/agents/factory.md` (coding standards, verification, reviewer triggers) and its checklist in `docs/agents/checklists/<name>.md`: the project's facts for its lens (auth, scoping root, roles, copy language, design system). Without a checklist the reviewer runs generic.

Skills:

- **pre-review** — verdict, shape and `agent-head` of the pre-review comment an agent posts on its PR.
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
