# Factory config

<!-- Example for a repo with a backend/ and a frontend/ area. Copy it to docs/agents/factory.md and replace every command and path with your project's. Keep the section names: the factory finds each section by its heading. -->

## Feedback loops

One row per area of the repo. A change under an area runs its lint, then its tests, both green before every commit.

| Area | Path | Lint | Test |
|---|---|---|---|
| Backend | `backend/` | `cd backend && npm run lint` | `cd backend && npm test` |
| Frontend | `frontend/` | `cd frontend && npm run lint` | `cd frontend && npm test` |

## Coding standards

`docs/coding-standards.md`, plus the stack doc it points to for each area.

## Verification

- **Skill**: `verify-app`; its `## Mockup` section is the mockup comparison.
- **User-visible change**: a change under `frontend/`, or a `backend/` endpoint, job or email the frontend relies on. Such a change triggers the verification and the UI gate. An issue touches the UI when its brief names a screen or a path under `frontend/`.
- **Launch command** (named in an `UNVERIFIED` line when it fails): `bin/dev up`.
- **Publish evidence**: `bin/dev publish-evidence {issue} --since {since} --out {out}`. It writes comment-ready Markdown to `{out}`.
- **Evidence folder** reviewers read: the newest folders under `tmp/evidence/` (screenshots, `report.json`).

## Reviewer triggers

`spec`, `bugs` and `standards` run on every pass. A conditional reviewer runs when the pass's diff matches its trigger; read the trigger as intent, the paths are examples.

| Reviewer | Triggered when |
|---|---|
| `mockup` | a file under `frontend/src/` that renders UI changes (components, pages, styles) |
| `data` | migrations, the schema or models change |
| `security` | controllers, policies, auth or serializers change |
| `perf` | query code, serializers that load associations, a list endpoint, a list component or a data-fetching hook changes |

## Pre-review

### Sensitive deny-list

- auth and session config, OAuth code
- migrations and the schema
- lockfiles: a new or bumped dependency is supply chain the reviewer approves
- anything matching `*billing*`, `*payment*`, `*credential*`, `*secret*`, `*.env`

### Factory paths

- `.claude/settings.json`, `.claude/hooks/**`, `docs/agents/factory.md`, `docs/agents/checklists/**`
- `.github/workflows/**`
- the cloud setup script
