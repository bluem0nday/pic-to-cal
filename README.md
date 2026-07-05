# pic-to-cal

A [Claude skill](https://docs.claude.com/en/docs/agents-and-tools/agent-skills) that turns a picture of an event into a calendar hold. Attach a screenshot, flyer, poster, or a photo of a poster on the street, say "calendar this" (or any trigger phrase in [SKILL.md](SKILL.md)), and a 📌 Hold lands on a dedicated Google Calendar with everything needed to actually attend — tickets link on top, venue address, and the full flyer context with live links.

The part that makes it more than OCR: before filing, the skill finds the event's real page on the web and verifies the image against it. Flyers are wrong about dates and times more often than you'd think, and the page wins on conflict.

## How it works

1. Transcribe everything in the image and confirm it's an event.
2. Extract structured fields: title, date, time, venue, links, live speakers.
3. Find a source page — printed URLs, QR codes, and social handles in the image are checked first; web search is the fallback.
4. Verify the image's facts against the page. Every filing lands in one of three honest states: **✓ Verified**, **⚠ Unverified** (a link exists but couldn't confirm the facts), or no page found. The state is labeled in the event body, per field where it matters.
5. Show one confirm block (yes / no / fix), then file the hold — never to the primary calendar, always to a dedicated one that can be toggled off in the sidebar.

Some of the rules the spec encodes, each earned by a real test case: a timezone printed on the flyer beats one derived from the venue; a "midnight" event ends at 23:59 the listed day; a date with no findable time files as an all-day banner and says so; people are listed as speakers only if they appear live at the event, so a film's cast never shows up as event speakers.

## Install

Copy or symlink this folder into `~/.claude/skills/`. You'll need Claude with web search and a Google Calendar connector available.

The calendar ID pinned in SKILL.md step 8 is the author's — create your own dedicated calendar and swap in its ID before using.

## Evolution

[CHANGELOG.md](CHANGELOG.md) tracks every version; releases are tagged. The spec is hardened by a loop of real screenshot tests: file a hold, inspect it on the calendar, fold what was wrong back into the spec as a rule.

A note on history: the v0.1.0 and v0.2.0 commits were reconstructed on 2026-07-04 from the files as they stood on those earlier dates. Their commit messages say so.

## Status

A personal tool under active testing, and the working spec for a planned iOS share-intent app that does the same job without opening a chat.
