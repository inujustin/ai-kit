#!/usr/bin/env bash
# Is this project's kit "open" right now? The user can open every door of a project for a limited time
# (`run open <hours> "<why>"` writes $KIT/.ai/run/open-until = "<epoch> <why>"). While open, the guards behave like a
# repo without a kit (loose global defaults). Expired -> the file is removed, a note goes to run/progress.md and the kit
# is back to its mode.conf defaults by itself.
#   bash open-state.sh <kit>   exit 0 and print "<until-epoch> <why>" when open; exit 1 when closed
kit="$1"; f="$kit/.ai/run/open-until"
[ -n "$kit" ] && [ -f "$f" ] || exit 1
read -r until why < "$f"
if [ "${until:-0}" -gt "$(date +%s)" ] 2>/dev/null; then echo "$until ${why:-}"; exit 0; fi
rm -f "$f"
python3 "$kit/.ai/bin/run" note "open-all expired: back to mode.conf defaults" >/dev/null 2>&1
exit 1
