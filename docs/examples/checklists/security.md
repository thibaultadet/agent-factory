# Security checklist

Project facts for the `security` reviewer, on top of its generic lens.

- **Auth**: session cookies for the web app, bearer tokens for the API; scopes as the neighbouring controllers use them.
- **Scoping root**: the current user's `Account`; a bare `find` on an id from params is the leak.
- **Roles**: `member`, `admin` (within its `Account`) and `staff`; admin routes (`/admin`) for `staff` only.
