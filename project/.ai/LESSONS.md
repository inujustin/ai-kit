# Lessons: mistakes the AI made in this project, and the rule that prevents each one

Read this at the start of every session. Newest first. Each line: what went wrong → the rule now.
Starts with lessons learned in other kits (general words only); add this project's own below them.

## From other kits (kept in the template)
1. Stopped early to avoid popups and left work uncommitted. → Keep going until the request is done; commit each
   finished, tested step locally (AUTO_COMMIT in mode.conf). A needed popup is fine, stopping is not.
2. Too many popups: chained commands (`cd … && …`, `git reset && git add && git commit`) never match allow rules,
   `git -C <repo> commit` does not match `git commit *`. → One simple command per Bash call, absolute paths, no `cd`
   or `sleep`; commit with `git commit -F <scratchpad file>`; sandbox excludedCommands always "<cmd> *".
3. Reported a review "PASS" that never ran (`| tail` hid the exit code). → Never pipe gate or test output through
   tail/grep when the exit code matters; read the review log before saying PASS.
4. Did not use Codex although ROLE_DEV/ROLE_REVIEW = codex. → Tickets over ~30 lines go to `bin/dispatch`; every
   branch gets a real Codex review before "done".
5. Asked questions during a run the user marked "ask nothing". → "ask nothing", an unattended run and an opened kit
   override every grill hint; log the decisions in the footprint instead.
6. Worked strictly in sequence, waiting for each review. → Never wait: while Codex codes or reviews, do kit work
   (footprints, tickets, next plan) or start the next independent ticket. Never switch branches while a review or
   dispatch runs on the checkout.
7. Review kept finding edge cases round after round. → Fix every BLOCKER/MAJOR; MINOR = fix if cheap, else note it as
   a known limit in the footprint. Same area keeps breaking: simplify the design. After 3 rounds, move on and include
   it in one final gate over all branches.
8. Edited a kit script while a background task was running it (bash reads scripts while running). → Never edit a
   script a background task is executing; queue the change.
9. Whole-tree lint/format blocked by guard-repo. → Lint only changed files (pre-commit on commit).
10. Kit edits with KIT_GIT=none look like "no commits". → Say which changes are repo commits (SHA) and which are kit files.

## This project
