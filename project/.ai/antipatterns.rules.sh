# Core rules for .ai/check_antipatterns.sh (every project). Pack rules are loaded after these from
# .ai/packs/<name>/antipatterns.rules.sh for each pack listed in .ai/packs.conf.
# rule CODE "file globs" "path ERE where it applies" "exempt ERE (path or text)" "pattern ERE" "message"
rule G-1 "*.py,*.ts,*.tsx,*.js,*.jsx,*.vue,*.go,*.php,*.java,*.kt" "." "/tests?/|\.test\.|\.spec\.|example" \
  "([Aa][Pp][Ii][_-]?[Kk]ey|[Ss]ecret|[Pp]assw(or)?d|[Tt]oken)[\"' ]*[:=] *[\"'][A-Za-z0-9_/+=-]{16,}" \
  "Hard-coded secret? Read it from env or the secret store."

PACKS=()
# shellcheck source=/dev/null
[ -f .ai/packs.conf ] && . .ai/packs.conf
for p in "${PACKS[@]}"; do
  # shellcheck source=/dev/null
  [ -f ".ai/packs/$p/antipatterns.rules.sh" ] && . ".ai/packs/$p/antipatterns.rules.sh"
done
