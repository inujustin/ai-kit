# Frappe pack rules. Codes match .ai/packs/frappe/RULES.md.
rule R-A1 "*.py" "." "/(tasks|patches)/"  "frappe\.db\.commit\("        "No frappe.db.commit() outside tasks/ and patches/."
rule R-A2 "*.py" "." "/patches/"          "frappe\.db\.sql\("           "No raw SQL. Use get_list or qb.get_query."
rule R-A3 "*.py" "." "/(tasks|patches)/"  "frappe\.db\.set_value\("     "No db.set_value on documents. Use doc.save() or self.db_set."
rule R-A6 "*.py" "." ""                   "ignore_permissions *= *True|set_user\([\"']Administrator" "Never bypass permissions to make it work."
rule R-A8 "*.py" "." ""                   "_\(f[\"']"                   "No f-string inside _(). Use _(\"... {0}\").format(x)."
rule R-A8 "*.py" "." "/(tests|patches)/"  "^[[:space:]]*print\("       "Log with frappe.log_error or frappe.logger, not print()."
rule R-M1 "*.py" "." "/tests?/"           "datetime\.(now|utcnow|today)\(" "Use frappe.utils (now_datetime, nowdate, getdate)."
rule FE-2 "*.vue" "." ""                  "v-html"                      "No v-html. Plain text, or DOMPurify with a reason."
