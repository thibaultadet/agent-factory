repo_slug() { git remote get-url origin | sed -E 's#(\.git)?/?$##; s#.*[:/]([^/]+/[^/]+)$#\1#'; }
