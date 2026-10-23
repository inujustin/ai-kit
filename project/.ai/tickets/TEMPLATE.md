# T000: short title in GLOSSARY words

Spec: .ai/docs/spec/<file>.md#section · ADR: none · Size: S (one agent-hour at most) · Depends on: none
Executor: codex | claude · Split: yes (risky: tester then coder) | no

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
- [ ] tests/test_x.py::test_y fails before the change and passes after
- [ ] bash $KIT/.ai/verify.sh --fast passes

## Out of scope
- ...
