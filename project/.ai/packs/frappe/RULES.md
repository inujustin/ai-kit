# Pack: frappe (any Frappe / ERPNext app)

Source of truth: the official Frappe skills `frappe-app-dev` (writing) and `frappe-code-review` (reviewing),
from github.com/frappe/skills. Each rule points to where those skills say it; if a skill changes, the skill wins.
The team's own agreed rules (CLAUDE.md, CONTRIBUTING, docs the team has finalised) win over this pack. During onboarding,
add team rules to the project's AGENTS.md only after the user confirms they are agreed (drafts are not rules).
[CI] = flagged on changed files by `.ai/check_antipatterns.sh` (a flag means "look at it", not always "wrong").

## Data and transactions
- FR-1 [CI] No `frappe.db.commit()` / `rollback()` in controllers or request handlers; Frappe manages transactions.
  Rare exceptions (e.g. flushing before `frappe.enqueue`) carry a comment `# FR-1: <reason>`.
  (frappe-app-dev references/database.md "Transactions", references/controllers.md; frappe-code-review "No partial commits")
- FR-2 [CI] Never build SQL with f-strings or string concatenation. Prefer the ORM / `frappe.qb`; `frappe.db.sql` only for
  what qb cannot express, always with parameters. (frappe-code-review SQL section; frappe-app-dev references/database.md)
- FR-3 No `frappe.db.set_value` for fields with validation logic, status fields or state transitions; it skips `validate()`
  and lifecycle hooks. (frappe-app-dev references/controllers.md)
- FR-4 Guard `set_value` / `delete` / `get_value` against a `None` name or filter. (frappe-code-review)
- FR-5 No queries inside loops (N+1). Batch, then map. (frappe-app-dev references/database.md; frappe-code-review)

## Permissions and APIs
- FR-6 [CI] `ignore_permissions` / `flags.ignore_permissions` / `set_user("Administrator")` only in server-side background
  logic, never in user-facing APIs. (frappe-app-dev references/permissions.md)
- FR-7 `frappe.qb.get_query` is not permission-aware by default; pass `ignore_permissions=False` in user-facing code.
  (frappe-app-dev references/database.md)
- FR-8 Every `@frappe.whitelist` method: type hints on all parameters, explicit `methods=[...]`. (frappe-app-dev references/api.md)
- FR-9 Do not wrap a document's whitelisted method in a standalone API; doc-scoped logic is a doc-level method. Standalone
  APIs only for cross-document work. (frappe-app-dev references/api.md)

## Extending
- FR-10 Never edit framework or vendor code (apps/frappe, apps/erpnext, site-packages, node_modules); extend with hooks,
  doc_events and overrides. (frappe-app-dev references/hooks.md)

## Frontend
- FR-11 [CI] No `v-html` without sanitising; show text as text.
- Frontend stack, design system and API-client rules come from the project itself (onboarding), never from this pack.
