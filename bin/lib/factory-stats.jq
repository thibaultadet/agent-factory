def pct(a; b): if b == 0 then "-" else "\((a * 100 / b) | round)%" end;
def hours: (.merged_at | fromdate) - (.created_at | fromdate) | . / 3600;
def median: sort | if length % 2 == 1 then .[length / 2 | floor] else (.[length / 2 - 1] + .[length / 2]) / 2 end;
def nearest(p): sort | .[(length * p | ceil) - 1];
def fmt: if . < 48 then "\(. * 10 | round / 10) h" else "\(. / 24 * 10 | round / 10) d" end;

# The second marker headed pre-review comments before the rename; kept so past PRs still count.
def is_pre_review:
  . as $body
  | any(["<!-- pre-review -->", "<!-- sandcastle-pr-check -->"][]; . as $m | $body | contains($m));

def points($lines):
  [$lines[] | select(test("_\\(to confirm\\)_") | not)   | capture("^[0-9]+\\. (?<mark>\\S+) (?:(?<who>[a-z-]+) · )?")
   | {who, fate: (if .mark == "⚪" then "dismissed" else "open" end)}];

def passes($lines):
  [$lines[] | capture("^- review [0-9]+ · (?<who>[a-z-]+) → (?<rest>.*)")
   | {who, n: (.rest | capture("(?<n>[0-9]+) certain").n // "0" | tonumber)}];

def tally_one($body):
  ($body | split("\n")) as $lines
  | $lines[:($lines | map(test("<details>")) | index(true)) // ($lines | length)] as $findings
  | points($findings) as $points
  | if ($findings | map(test("^agent-head: ")) | any | not) or ($points | map(.who == null) | any)
    then {rows: []}
    else passes($lines) as $passes
    | {rows: [[$points[].who, $passes[].who] | unique[] as $r
        | {who: $r, certain: ([$passes[] | select(.who == $r) | .n] | add // 0),
           dismissed: ([$points[] | select(.who == $r and .fate == "dismissed")] | length),
           open: ([$points[] | select(.who == $r and .fate == "open")] | length),
           largest: ([$passes[] | select(.who == $r) | .n] | max // 0)}
        | .fixed = ([.largest - .dismissed - .open, 0] | max) | del(.largest)]}
    end;

def counts: reduce .[] as $l ({}; .[$l] += 1);
def symdiff($a; $b):
  ($a | counts) as $ca | ($b | counts) as $cb
  | [($ca + $cb) | keys[] | ($ca[.] // 0) - ($cb[.] // 0) | fabs] | add // 0;

def file_rework($a; $b):
  if $a and $b then
    if $a.sha == $b.sha then empty
    elif $a.lines and $b.lines then symdiff($a.lines; $b.lines)
    else $b.n end
  else ($a // $b).n end;

def similar($a; $b): $a.lines and $b.lines and symdiff($a.lines; $b.lines) < ($a.n + $b.n) / 2;
def pair_renames($only_agent; $only_final):
  reduce $only_agent[] as $a ({pairs: [], left: $only_final};
    (.left | map(similar($a; .)) | index(true)) as $i
    | if $i == null then .pairs += [[$a, null]] else .pairs += [[$a, .left[$i]]] | .left |= del(.[$i]) end)
  | .pairs + [.left[] | [null, .]];

def rework_diff($agent; $final):
  ($agent | map(.f)) as $af | ($final | map(.f)) as $ff
  | [($af - ($af - $ff))[] as $f
     | file_rework($agent | map(select(.f == $f))[0]; $final | map(select(.f == $f))[0])]
    + [pair_renames($agent | map(select(.f as $f | $ff | index([$f]) | not));
                    $final | map(select(.f as $f | $af | index([$f]) | not)))[]
       | if .[0] and .[1] and .[0].sha == .[1].sha then 0 else file_rework(.[0]; .[1]) end]
  | {files: length, lines: (add // 0)};

def merge_rate_section($prs; $merged):
  "Merge rate",
  "  merged \($merged | length) · closed unmerged \($prs | map(select(.state == "closed" and (.merged_at | not))) | length) · open \($prs | map(select(.state == "open")) | length) · \(pct($merged | length; $prs | length)) merged";

def rework_section($rework):
  ($rework | map(select(.head))) as $tracked
  | ($tracked | map(select(.files > 0))) as $reworked
  | "Rework (merged content differs from agent-head)",
    "  \($reworked | length) of \($tracked | length) tracked (\(pct($reworked | length; $tracked | length))) · no agent-head: \($rework | map(select(.head | not)) | length)",
    ($reworked[] | "  #\(.number): \(.files) files, ~\(.lines) lines"),
    ($rework | map(select(.head | not) | "#\(.number)") | if length > 0 then "  no agent-head: \(join(" "))" else empty end);

def findings_section($reviews):
  [$reviews[] | tally_one(.).rows[]] as $rows
  | ($rows | map(.who) | unique) as $reviewers
  | "Certain findings per reviewer (certain / fixed / dismissed / open)",
    (if ($reviewers | length) == 0 then "  none recorded" else empty end),
    ($reviewers[] as $r | [$rows[] | select(.who == $r)]
     | "  \($r): \(map(.certain) | add) / \(map(.fixed) | add) / \(map(.dismissed) | add) / \(map(.open) | add)"),
    "  all: \($rows | map(.certain) | add // 0) certain · \($rows | map(.fixed) | add // 0) fixed · \($rows | map(.dismissed) | add // 0) dismissed · \($rows | map(.open) | add // 0) open",
    "  (a pre-review counts only with an `agent-head:` line and a reviewer named on every point;",
    "   fixed is approximate: that reviewer's largest pass − dismissed − open, per pre-review, floored",
    "   at 0; it misses points first raised on a later pass, and counts a point another reviewer",
    "   raised first as fixed)";

def time_section($merged):
  "Open to merge",
  (if ($merged | length) == 0 then "  no merged PR"
   else "  median \($merged | map(hours) | median | fmt) · p90 \($merged | map(hours) | nearest(0.9) | fmt)" end);

def report($prs; $rework; $reviews; $since):
  ($prs | map(select(.merged_at))) as $merged
  | "Agent PRs opened since \($since): \($prs | length)",
    "",
    merge_rate_section($prs; $merged),
    "",
    rework_section($rework),
    "",
    findings_section($reviews),
    "",
    time_section($merged);
