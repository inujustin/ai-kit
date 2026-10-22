# Frappe pack rules. Codes match .ai/packs/frappe/RULES.md (sources: official frappe/skills).
# rule CODE "file globs" "path ERE where it applies" "exempt ERE (path or text)" "pattern ERE" "message"
rule FR-1  "*.py"  "." "/(tasks|patches)/" "frappe\.db\.(commit|rollback)\(" "Frappe manages transactions; no commit/rollback in controllers or request handlers."
rule FR-2  "*.py"  "." ""                  "frappe\.db\.sql\([[:space:]]*f[\"']|frappe\.db\.sql\([^)]*[\"'][[:space:]]*\+" "Never build SQL with f-strings or concatenation; use qb or parameters."
rule FR-6  "*.py"  "." "/(tasks|patches)/" "ignore_permissions *= *True|set_user\([\"']Administrator" "Bypassing permissions: only in background logic, never in user-facing APIs."
rule FR-11 "*.vue" "." ""                  "v-html"                      "v-html renders raw HTML; sanitise or show as text."
