# Mockup checklist

Project facts for the `mockup` reviewer, on top of its generic lens.

- **Copy language**: every string a screen shows is in English.
- **Design system**: the components under `frontend/src/ui/`; raw colours and spacing go through its tokens.
- **Board sources** and how to render them:
  - `docs/mockups/<file>.html#<screenId>`: an in-repo mockup, opened at that screen id with Playwright.
  - a design artifact link: read with the Artifact tool's `read` action.
