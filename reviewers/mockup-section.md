# Mockup section

The factory's contract between an issue and its screens. The `factory:implement-issue` gate and the `mockup` reviewer read it.

## Contract

An issue that changes what a user sees (`docs/agents/factory.md` § Verification) carries a `## Mockup` section in its **body**, never a comment: the gate and the reviewer parse the body. Triage writes it when it moves the issue to `ready-for-agent`.

```markdown
## Mockup
- Board: <board ref>
- Delivers: <zones or states this issue builds>
- Leaves out: <zones or states left to other issues, with #<n> when known>
```

- **Board ref**: a reference the project's mockup checklist (`docs/agents/checklists/mockup.md`) lists as a board source. A versioned source is pinned at triage: the agent builds that version even if the board moves; a newer board means re-triage and an edited section.
- **Scope**: `Delivers` and `Leaves out` name zones or states in the board's vocabulary. The reviewer checks the screens within that scope only.
- **One group per board**: an issue spanning several screens repeats `Board` / `Delivers` / `Leaves out` per board.
- **No board yet**: the issue stays out of `ready-for-agent` until design delivers one.
- **No visible change** (a refactor, a hook, a type): the section is `## Mockup` followed by the line `No visible change`. This is the only exemption.

## Gate

A run stops before building when the issue is not `quick`, touches the UI, and its body has no `## Mockup` section. `No visible change` passes; a `## Mockup` heading in a comment does not.
