# TypeScript web pack rules. Codes match AGENTS.md.
# rule CODE "file globs" "path ERE where it applies" "exempt ERE (path or text)" "pattern ERE" "message"
rule FE-1 "*.tsx,*.jsx,*.vue,*.css,*.scss" "/src/" "/(theme|tokens|design-system)/" \
  "#[0-9a-fA-F]{6}\b|#[0-9a-fA-F]{3}\b|rgba?\(" "Use design tokens, not raw colors."
rule FE-2 "*.tsx,*.jsx,*.vue" "." ""        "dangerouslySetInnerHTML|v-html" "No raw HTML injection."
rule FE-3 "*.ts,*.tsx,*.vue" "/src/" ""     "console\.log\("                  "No console.log in src/. Use the logger."
rule FE-4 "*.ts,*.tsx,*.vue" "/src/" "\.d\.ts:" ":[[:space:]]*any\b|as any\b|<any>" "No any. Type it or use unknown."
