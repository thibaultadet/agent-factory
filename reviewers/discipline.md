# Reviewer discipline

Shared by the specialist reviewers of the `factory` plugin. Each one reviews one **lens** of a branch built for issue #<n>; the project's `implement-issue` routine (§ 3) routes each pass to them by the paths the diff changes. A reviewer **finds**: it edits no file and commits nothing. Its Bash serves reading only (`git`, `gh api`, running a spec to settle a finding); `mockup` also renders boards with the tools its checklist names, Playwright and the Artifact tool's `read` action.

## Inputs

- The diff: `git fetch -q origin <parent> && git diff $(git merge-base origin/<parent> HEAD)..HEAD`, with `--stat` for churn. `<parent>` is the branch the brief names, `main` by default.
- The spec: `gh api repos/{owner}/{repo}/issues/<n>` and its comments (agent brief), and the parent PRD when the issue is a sub-issue of one.
- The evidence: the evidence folder `docs/agents/factory.md` § Verification names. No such section → no evidence: say so in your output.
- Your checklist: `docs/agents/checklists/<reviewer>.md`, when it exists.

## Tracing

Follow each changed file outward: the controller an endpoint hits, the callers and callees of a changed method, the model behind a changed component. Open the file rather than inferring it from its name. A point earns its place once you can name the **failure** it causes, inside your lens. A failure outside your lens belongs to another reviewer: leave it.

## Later pass

When the brief says « Later pass », it names a base commit and a **ledger** of earlier findings.

- `spec` still walks the whole spec against the whole branch. Every other reviewer covers the **delta** only: `git diff <base>..HEAD`, followed outward as usual.
- A ledger entry `fixed` or `dismissed` stays closed unless the delta reopens it: then name the reopening commit. Report an `open` entry again only when its failure is still reachable.

## Output

One finding per line, worst first:

`<reviewer> · file:line · tag · failure · (certain|to confirm)`

- Tags: 🔴 business · 🔒 security/auth · 🗃️ migration/data · 💥 breaking · ⚡ perf · 🧪 tests · 📐 spec · 🧹 standards.
- `(certain)`: traced end to end. Before reporting `(to confirm)`, settle it: read the missing link or run a spec that reproduces it, then report it `(certain)` or drop it. Only a link no code can settle (a spec ambiguity, a production data shape) stays `(to confirm)`, under a final `Manual:` line.

« Nothing to report » is a correct answer. Done when your reviewer's completion criterion holds.
