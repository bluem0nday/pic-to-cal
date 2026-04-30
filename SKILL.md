---
name: pic-to-cal
description: Turns an attached event image (screenshot, flyer, poster, photo) into a Google Calendar HOLD with the registration URL embedded. Use this skill — invoked as either "pic-to-cal" or "pic to cal" — whenever the user attaches an image AND uses one of these specific phrases, even if the image looks like it could be handled by another skill: "add this flyer", "hold this event", "process this screenshot", "save this poster", "remind me about this", "pic to cal", "pic-to-cal", or any close variant of those phrases that pairs an image with a request to put something on the calendar. Do NOT trigger on broad capture phrases like "save this" or "add this" with no image-or-event context — those belong to quick-capture. Do NOT trigger when the image is clearly a person's headshot, a company logo, or a screenshot of a chat message — route those to quick-capture or update-contact instead. An image MUST be attached. If the user types a trigger phrase with no image, ask them to attach one rather than running the skill.
---

# pic-to-cal

Take an attached event image, find the official registration URL, and create a HOLD on the user's primary Google Calendar so they don't lose track of it. The user (Matt) types this skill name as either `pic-to-cal` or `pic to cal` — both are correct.

## Why this skill exists

Matt screenshots events on Instagram, X, email, and flyers all the time, then forgets about them. Manual flow is: open calendar, type title, find the registration page, paste URL, set time, save. This skill collapses that to: attach image, type a trigger phrase, confirm once, done.

The HOLD is intentionally low-commitment — it goes on the calendar before Matt has decided whether to attend. Lavender color and a 📌 prefix make HOLDs visually distinct from real meetings.

## What's in scope (v0.2)

The single-image, single-day case. Find the registration URL via web search and use it to verify the facts in the image. If the search fails, file the HOLD anyway and flag the description as unverified.

## What's out of scope (do not build)

Multi-day events, dedup checks, recurring detection, T-2 re-verification, eval/QA checks, RSVP actions, email actions, scheduled tasks, first-run setup. Those are later versions. If a user request implies one of these, say so and stop — don't improvise.

## Trigger contract

Required:
- An image is attached to the user's message
- The user's message contains one of the trigger phrases (see the description field above)

If the user types a trigger phrase with no image attached, do not start the workflow. Reply: "I need the image attached to the message — can you re-send with the screenshot?"

If an image is attached but the message contains no trigger phrase, do not start the workflow. The user is using a different skill or talking conversationally.

## The workflow

Follow these nine steps in order. One question at a time. Never batch questions to the user — that violates Matt's working style and will frustrate him.

### Step 1: Transcribe everything in the image

Read every piece of visible text in the image — title, dates, times, host names, speaker names, location, URL, handle, caption, hashtag, fine print. Don't summarize. Capture it raw.

Show Matt the full transcription before doing anything else. Format:

```
Transcription:
[every line of text from the image, in roughly the order it appears]
```

### Step 2: Decide if this is actually an event

An event has at minimum: a date OR a time, AND something resembling a title or topic. If those are missing, it is probably not an event.

If it is not an event:
- Image is a person (headshot, LinkedIn screenshot) → suggest the user run `quick-capture` instead
- Image is a company logo or About page → suggest `quick-capture`
- Image is a chat message from a tracked contact → suggest `update-contact`
- Image is an article, recipe, product → ask Matt what he wants to do

In all of those cases, stop the pic-to-cal workflow. Don't file a HOLD for non-events.

### Step 3: Extract the structured fields

From the transcription, pull:
- **Title** — the event name
- **Date** — convert to YYYY-MM-DD
- **Start time** and **end time** — 24-hour
- **Timezone** — explicit if shown in the image (e.g. "EST", "PT"). If the image is silent (common on Instagram screenshots), leave it as `unknown` for now — step 5 will try to recover it from the registration page. Only fall back to `America/New_York` after the page has also been checked and is silent
- **Host / speakers** — names with titles if shown
- **Location** — physical address if given, otherwise "Virtual"
- **Source platform** — Instagram, X, email, web, photo (infer from screenshot UI)

If a key field looks ambiguous in the image — date is half-cropped, two times conflict, year is missing, text is garbled — flag it inline before the confirm step. Format:

```
⚠ Low-confidence field: [field name]
  In the image: "[what was visible]"
  My best guess: [guess]
  Want to fix this before I continue?
```

Wait for Matt's reply before moving on.

### Step 4: Search for the official registration page

Use web search. Up to two attempts.

- First query: build from event title + host + date (e.g. `"AI Strategy Summit" Section School June 4 2026`)
- If the first query returns nothing useful, try a second with different keywords (drop the date, add the speaker name, or add "registration")

What counts as "useful": a result on the host's own domain, an Eventbrite/Luma/Hopin page run by the host, or a clearly official landing page. Skip aggregator pages, news articles about the event, or the host's homepage.

Stop after two tries. Don't keep guessing.

### Step 5: Fetch the page and diff

If a registration URL was found, fetch it. Compare the page to the image transcription on these fields: title, date, start time, end time, timezone, location, speakers.

The registration page is especially load-bearing for **timezone**, since Instagram-style screenshots often don't show one. If the image's TZ was `unknown`, scan the page for a TZ label (e.g. "ET", "Pacific Time", "GMT-5") or an event location (e.g. "San Francisco, CA" → infer Pacific). If the page also has no TZ signal, fall back to `America/New_York` and surface that as a low-confidence assumption at the confirm step (step 7) so Matt can override before filing.

If every field matches (allowing for small text differences like "Thursday Jun 4" vs "June 4, 2026"), say nothing — go straight to step 7. Don't show a comparison block when there's nothing to look at.

If at least one field actually conflicts, show the comparison so Matt can see what changed:

```
Image vs. registration page:
- Title:    [image] → [page]   ✓ match  /  ✗ differ
- Date:     [image] → [page]   ...
- Time:     ...
- Speakers: ...
```

On any conflict, the page wins. Use the page's value for the calendar event. Don't ask Matt to choose.

If the page is unreachable or returns an error, treat this as no page found and proceed to step 6.

### Step 6: Handle no-page-found

If neither search attempt returned a usable URL, or if the page wouldn't load, continue to step 7 with no URL. The HOLD will get an "unverified source" flag in the description. Don't ask Matt whether to proceed — the BACKLOG decision is auto-skip after two tries.

### Step 7: Single confirm before create

Show one summary block and ask one yes/no question:

```
Ready to file:
Title:    📌 HOLD — [event title]
When:     [date] · [start]–[end] [TZ]
Where:    [location or "Virtual"]
URL:      [registration URL or "(none — unverified)"]
Calendar: macqueen@gmail.com (primary)

File it? (yes / no / fix)
```

- yes → step 8
- no → stop, don't create
- fix → ask which field, edit, re-show summary, ask again

### Step 8: Create the calendar event

Use the Google Calendar `create_event` tool with:

- **calendarId**: `primary`
- **summary**: `📌 HOLD — [event title]`
- **start** / **end**: ISO datetime with `timeZone` set to the IANA TZ (e.g. `America/New_York`)
- **location**: physical address or the literal string `Virtual`
- **colorId**: `"1"` (Lavender)
- **visibility**: `private`
- **attendees**: omit (no invitations)
- **description**: HTML, structured like this:

```html
<p><b>Register:</b> <a href="[URL]">[URL]</a></p>
<p><b>Speakers:</b><br>
- [Name], [Title]<br>
- [Name], [Title]</p>
<p><b>Audience:</b> [audience if visible in image or on page]</p>
<p><b>Topic:</b> [one-line topic summary]</p>
<hr>
<p><b>Original transcription:</b></p>
<pre>[full transcription from step 1]</pre>
<p><b>Source platform:</b> [Instagram / X / email / web / photo]</p>
<p><i>Verified against [URL] on [YYYY-MM-DD]</i></p>
```

If no URL was found, replace the footer line with:
```html
<p><i>⚠ Unverified source — no registration page found via web search on [YYYY-MM-DD]</i></p>
```

### Step 9: Report back

One line plus the link the calendar tool returns:

```
HOLD filed: [event title], [date] [start] [TZ]
[calendar event URL]
```

That's it. Don't summarize what was done. Don't list the description fields back. Matt can open the calendar event if he wants to see the details.

## Tools this skill uses

- **Native image reading** — for step 1
- **WebSearch** — for step 4
- **web_fetch** — for step 5
- **Google Calendar `create_event`** (MCP connector) — for step 8

That's the full toolkit. If a tool is unavailable, stop and tell Matt which one is missing — don't try to work around it.

## Working style for this skill

- One question at a time. Never batch.
- Use real values in any preview block, never placeholders.
- Active voice. No buzzwords. No adverbs.
- Brutal honesty if the input is bad — say "this image doesn't have a date, I can't file a HOLD" instead of guessing.
- Don't recap what you just did in the final message. The calendar link is the deliverable.
