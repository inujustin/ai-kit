# T000: short title in GLOSSARY words

Spec: .ai/docs/spec/<file>.md#section · ADR: none · Size: tiny | S (one agent-hour at most) · Depends on: none
Commit: <subject in the repo's commit style; dispatch uses it as the commit title>
Executor: codex | claude | tiny (agy/gemini, Size: tiny only) · Split: yes (risky: tester then coder) | no · Tests: write | skip (asked the user on <date>)

## Goal
One or two sentences. What the user can do afterwards.

## Interfaces (what the tester tests against: function, endpoint, DocType method, component, with signatures)
- ...

## Owns (only these files may change)
- path/to/file

## Reads (context, do not change)
- path/to/other/file

## Acceptance (each item checkable by a command or a test)
- [ ] Given ..., when ..., then ...
- [ ] Tests: write → tests/test_x.py::test_y fails before the change and passes after
- [ ] Tests: skip → every item under "Manual checks" done by the user and confirmed by the reviewer

## Manual checks (Tests: skip; steps the user runs, e.g. bench console or a screen, with the expected result)
- ...
- [ ] bash $KIT/.ai/verify.sh --fast passes

## Out of scope
- ...
