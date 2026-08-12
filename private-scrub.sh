#!/bin/bash
# private-scrub.sh — one-step transcript cleanup for a private pic-to-cal run.
#
# Finds this session's transcript by its session id, confirms the file itself
# claims that id, deletes it, prints one line. It can never delete another
# session's transcript: the file must be named for the id AND carry the id
# inside, and exactly one such file may exist.
#
# The app writes back a small session card (title, one-line summary, last
# thing typed) seconds after the delete — after this script has already
# exited. That card is the documented limit of private mode (SKILL.md,
# "Private mode", fine print), not this script's job to chase.
#
# Usage: private-scrub.sh <session-id>
#   session-id  the running session's own id — the name of its scratchpad
#               directory. Nothing about the event ever goes on this
#               command line.
set -u

fail() { echo "ERROR: $1" >&2; exit 1; }

[ $# -eq 1 ] || fail "need exactly one argument: the session id"
SESSION_ID="$1"

case "$SESSION_ID" in
  *[!a-fA-F0-9-]*|"") fail "that doesn't look like a session id" ;;
esac

PROJECTS_DIR="$HOME/.claude/projects"
[ -d "$PROJECTS_DIR" ] || fail "no transcript directory at $PROJECTS_DIR"

COUNT=$(find "$PROJECTS_DIR" -maxdepth 2 -name "$SESSION_ID.jsonl" 2>/dev/null | wc -l | tr -d ' ')
[ "$COUNT" != "0" ] || fail "no transcript found for this session id"
[ "$COUNT" = "1" ] || fail "found $COUNT transcripts named for this session id; refusing to guess"

TRANSCRIPT=$(find "$PROJECTS_DIR" -maxdepth 2 -name "$SESSION_ID.jsonl" 2>/dev/null)

grep -q "$SESSION_ID" "$TRANSCRIPT" || fail "the file does not claim this session id inside it; refusing to delete"

rm "$TRANSCRIPT" || fail "delete failed"

echo "CLEAN"
