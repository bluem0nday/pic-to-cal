---
name: pic-to-cal
version: 0.6.0
description: Turns an attached event image (screenshot, flyer, poster, photo) into a Google Calendar HOLD with the registration URL embedded. Invoked as either "pic-to-cal" or "pic to cal". Trigger whenever an image is attached AND the user asks to put it on the calendar, in any phrasing — "calendar this", "add to calendar", "hold this event", "save the date", "pencil this in", "pic to cal", or anything similar. Pasted or dragged desktop screenshots count as attached images, not just phone attachments. Do NOT trigger on broad capture phrases like "save this" or "add this" with no image-or-event context — those belong to quick-capture. Do NOT trigger when the image is clearly a person's headshot, a company logo, or a screenshot of a chat message — route those to quick-capture or update-contact instead. An image MUST be attached: if a trigger phrase arrives with no image, ask for one rather than running the skill.
---

# pic-to-cal

Take an attached event image, find the official registration URL, and create a HOLD on the "Event Holds" Google Calendar (or the primary calendar when no "Event Holds" calendar exists — see step 8) so it doesn't get lost. Both `pic-to-cal` and `pic to cal` are correct names for the skill.

## Why this skill exists

The user screenshots events on Instagram, X, and email all the time — and photographs posters out in the city: concert posters, street flyers, anything taped to a wall with a date on it. Then they forget about them. Manual flow is: open calendar, type title, find the registration page, paste URL, set time, save. This skill collapses that to: attach image, type a trigger phrase, confirm once, done.

The HOLD is intentionally low-commitment — it goes on the calendar before the user has decided whether to attend. Lavender color and a 📌 prefix make HOLDs visually distinct from real meetings.

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

Follow these nine steps in order. One question at a time. Never batch questions to the user.

### Step 1: Transcribe everything in the image

Read every piece of visible text in the image — title, dates, times, host names, speaker names, location, URL, handle, caption, hashtag, fine print. Don't summarize. Capture it raw.

Real-world photos (as opposed to screenshots) come with glare, angles, torn corners, and stickers over the text. Transcribe what's legible and mark unreadable spots as `[illegible]` — don't fill gaps with guesses. A guessed date on the calendar is worse than a flagged one.

**The event only — ignore the rest of the frame.** A photo's frame almost always holds more than the event: a flyer on a pole among tear-off tabs and stickers, a billboard over a street, a poster in a subway car, a program lying on a desk. The setting doesn't matter and neither does the count of unrelated things (3–20 is common). Once it's clear which thing in the photograph IS the event, transcribe that and nothing else. Everything else in the frame goes nowhere: not the transcription shown in chat, not the invite, not even as "[unrelated, ignored]" footnotes. It's token clutter and brain clutter (2026-07-05, Dom Dolla pole-poster test; generalized same day: the rule is about the frame, not poles).

A corroborating signal inside the image can confirm an inferred field — e.g. a countdown timer ("1 week 6 days until the event") confirming that a year-less date is this year. Use it silently; it's a check, not content for the invite.

Show the user the full transcription before doing anything else. Format:

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
- Image is an article, recipe, product → ask the user what they want to do

In all of those cases, stop the pic-to-cal workflow. Don't file a HOLD for non-events.

### Step 3: Extract the structured fields

From the transcription, pull:
- **Title** — the event name, phrased the way you'd say it out loud: *who/what at where*. Vary by event type rather than forcing one template, and put the venue in the title almost every time:
  - Film / screening → `CYBERPUNK (Spectacle Theater)`
  - Talk / performance → `Michael Jordan speaking at Madison Square Garden`
  - Exhibition / art show → `Catherine Blackburn's paintings at [Gallery], Chelsea, New York`
  This is still being tuned — watch how real events read across types and adjust. The `📌 Hold: ` prefix is added at step 8, not here
- **Date** — convert to YYYY-MM-DD. If the year is missing (common on Instagram and event flyers — the post date is the context clue), assume the current year. Don't stop to ask. Only flag the date if it's also cropped, garbled, or self-contradictory — a bare missing year is not a low-confidence flag
- **Start time** and **end time** — 24-hour. A "midnight" screening belongs to the calendar day printed on the flyer. File it at `23:59` on the listed date — that keeps the event on the day the flyer names and in the real late-night slot, instead of jumping to `00:00` the following morning. (For Spectacle, "FRIDAY, MAY 29 – MIDNIGHT" → start `2026-05-29 23:59`. The end time can roll past midnight; a 60-min film ends `2026-05-30 00:59`.) **Try the page before falling back.** When the image is missing a start or end time, don't jump straight to a default — step 5 fetches the event page, so pull the real time from there if a verifiable page exists. Precedence for every time field: image → else verified page → else the fallbacks below. Only use a fallback when neither the image nor a page supplies the value.

If the source gives a start but no end time and no runtime to back one out of, default the end to **2 hours** after the start, and add a line in the body — `No end time or duration found` — so the user knows the end is a placeholder to adjust. It's a HOLD; an approximate block is fine.

If the source gives **no time at all — only a date**, don't invent a start time. File the HOLD as an **all-day** event: the thin bar across the top of the day, not a block that reserves 9-to-5 or any other span. Use the connector's `allDay: true`. Add a prominent line in the body — `⏰ No starting time found — filed as all-day banner` — so the user knows why it's a banner and that the time is the thing to look up on click-through. (Timezone doesn't apply to an all-day event, so the venue-TZ logic can be skipped in this case.)
- **Timezone** — if the image prints an explicit timezone (an IANA name like "America / New_York" or an abbreviation like EST), **trust it verbatim, even when it doesn't match the venue's city** — event platforms localize displayed times to the viewer, so the printed time+zone pair is already correct as a moment in time. Don't "fix" it to venue-local; that shifts the actual hour. (Learned 2026-07-04: a Chicago event displayed as "3:00 PM – 6:00 PM · America / New_York" — the platform had done the conversion; filing it as 3 PM Chicago would have been an hour off.) Only when NO timezone is printed: for a physical event, derive it from the venue's address (Brooklyn → `America/New_York`, San Francisco → `America/Los_Angeles`). That derivation is deterministic — never mark TZ `unknown` when there's an address. The time printed on the flyer is venue-local; store it in the venue's zone and Google Calendar auto-displays it in whatever zone the user is in. If the venue address isn't resolved yet at this step, leave TZ blank and let step 5 fill it once the address is known. Virtual events and the no-address fallback are handled in step 5
- **Host / speakers** — only people actually appearing **at the event**: the host, an MC, an intro speaker, a Q&A guest, a panel. Names with titles if shown. Do NOT list people who are merely subjects *within the content* — actors in a film, interviewees in a documentary, authors of a book being discussed. Those belong in the synopsis, not as event speakers. (For a CYBERPUNK screening, William Gibson and Timothy Leary are interviewed *in* the 1990 film; they are not speaking at the theater. Some screenings do add a live intro or Q&A speaker — capture that person here if the flyer names one.) If no one is named as appearing live, leave this empty.
- **Location** — physical address if given. If the image names a venue or host but no street address (common on Instagram screenshots), fetch the venue's full street address during step 5 (same web search) and use it. A full address lets Google Calendar geocode the event for maps and travel time. Only use "Virtual" when the event truly has no physical venue
- **Source platform** — Instagram, X, email, web, photo (infer from screenshot UI)

If a key field looks ambiguous in the image — date is half-cropped, two times conflict, year is missing, text is garbled — flag it inline before the confirm step. Format:

```
⚠ Low-confidence field: [field name]
  In the image: "[what was visible]"
  My best guess: [guess]
  Want to fix this before I continue?
```

Wait for the user's reply before moving on.

### Step 4: Find the official registration page

The image often names its own source — posters print URLs, ticket-site names, and Instagram handles. Check those before reaching for web search:

- If the transcription captured a **URL**, fetch it directly. If it loads and matches the event, that's the page — skip the search entirely.
- If it captured an **Instagram handle** (e.g. `@spectaclenyc`), search for that account's event page: handle + event title.

If the image gave no lead, or the printed lead is dead or unrelated, fall back to web search. Up to two attempts.

- First query: build from event title + host + date (e.g. `"AI Strategy Summit" Section School June 4 2026`)
- If the first query returns nothing useful, try a second with different keywords (drop the date, add the speaker name, or add "registration")

What counts as "useful": a result on the host's own domain, an Eventbrite/Luma/Hopin page run by the host, or a clearly official landing page. Skip aggregator pages, news articles about the event, or the host's homepage.

**Rank sources by how checkable they are.** A "verified" badge is only worth something if the source is public and machine-readable. Prefer, in order:

1. A per-event page on a structured, public, no-login platform — Eventbrite, Luma, Partiful, Resident Advisor, Dice, Songkick. These show date/time/location in a fixed shape and are the easiest to verify against.
2. The host's own per-event page.
3. The host's schedule or calendar page (including a PDF).
4. The host's homepage or social profile (Instagram, etc.).

The further down this list, the more likely the result lands at "unverified." Login-walled pages (Facebook events, most Instagram posts) can't be read, so they never count as verification even when they're the source.

**Venues without per-event pages.** Not every host publishes a page per event. Indie microcinemas, bookstores, and small music venues often run low-tech: a single monthly schedule, sometimes only a downloadable PDF calendar they remake each month. Bigger venues (theaters, ticketed concerts, author events) usually do have per-event pages — try for those first. When no per-event page exists, fall back to the venue's schedule or calendar page (including a PDF) and verify the date against it. Use that schedule URL as the embedded link — not a guessed per-event URL, and not the bare homepage if a real schedule page exists. If the event date is already past, the venue may have replaced that month's schedule with the current one; if so, the date can't be re-verified — note it and move on.

If there's no per-event page and no findable schedule page, use the venue's homepage as the link. A homepage is better than no URL — it still gives the user a way back to the venue.

**Stack the rungs when the top one is missing.** Whenever the best link is NOT a per-event/tickets page, give the user two labeled links instead of one: the most specific page found (series page, schedule, organizer profile) AND the venue's main site (2026-07-04, Angelika test: series page + venue homepage). One link answers "what is this event," the other answers "how do I reach the venue." When the best link IS the event page, one link is enough. Spectacle is an unusually bare case; most venues (theaters, bookstores, live music) will have something more specific, so only fall to the homepage when the better options genuinely aren't there. When the link is just the homepage, mark the description as unverified.

Stop after two tries. Don't keep guessing.

### Step 5: Fetch the page and diff

If a registration URL was found, fetch it. Compare the page to the image transcription on these fields: title, date, start time, end time, timezone, location, speakers.

**Known fetch-blocked platforms — don't spend a fetch on them (2026-07-07 speed rule; a complete flyer took ~5 minutes, mostly on doomed fetches).** ra.co, AXS, and Ticket Tailor have returned 403 to every fetch attempt across tests. When the best source is on one of these, skip the fetch: corroborate from the search listing itself (the title carries event, venue, and date) and use the listing URL as the link, with the per-field caution on anything the listing doesn't show (times, usually). If another domain 403s in two different runs, treat it the same way.

**Timezone: printed beats derived.** A timezone printed in the image or on the page wins as-is (platforms localize to the viewer — see step 3). When nothing is printed, resolve from the venue: for a physical event, the timezone is the venue's. Get the address (from the page or one venue search) and map it to its IANA zone: Brooklyn → `America/New_York`, San Francisco → `America/Los_Angeles`, Chicago → `America/Chicago`. The printed start time is venue-local. For a **virtual** event with no physical address: use the TZ printed on the flyer or page if shown; if none is shown, fall back to the user's home timezone — read it from their primary calendar via `list_calendars`. Either way, Google Calendar displays the event in the user's current local time automatically, so they always see it relative to themselves while the stored moment stays correct for the venue. No need to flag TZ as low-confidence when there's an address.

If every field matches (allowing for small text differences like "Thursday Jun 4" vs "June 4, 2026"), say nothing — go straight to step 7. Don't show a comparison block when there's nothing to look at.

If at least one field actually conflicts, show the comparison so the user can see what changed:

```
Image vs. registration page:
- Title:    [image] → [page]   ✓ match  /  ✗ differ
- Date:     [image] → [page]   ...
- Time:     ...
- Speakers: ...
```

On any conflict, the page wins. Use the page's value for the calendar event. Don't ask the user to choose.

While you're here, recover the venue's full street address if the image only named a venue or host. The registration page usually lists it; if not, check the results already on screen from the step-4 search first — addresses routinely appear in listing snippets (Yelp, maps, venue directories). Only run a dedicated venue search when the address genuinely isn't already in hand (2026-07-07 speed rule). Carry the full address into the `location` field at step 8 so Google Calendar can geocode it.

**Always check ticket availability while reading the page** (2026-07-05, LIXIL sold-out test). Look for the signals: "sold out", "waitlist", "sales ended", "N tickets remaining". If one is present, carry it as a dated caution line directly under the main link in the body — e.g. `🎟 Heads up: the page showed a "tickets have sold out" notice when checked (YYYY-MM-DD) — spots may still open up; the ticket page is the place to watch.` The date matters: availability moves, so the line records when it was true. If the page says nothing about availability, add nothing — silence isn't a finding.

If the page is unreachable or returns an error, treat this as no page found and proceed to step 6.

### Step 6: Handle no-page-found

If neither search attempt returned a usable URL, or if the page wouldn't load, continue to step 7 with no URL. The HOLD will get a "no source found" flag in the description. Don't ask whether to proceed — the locked decision is auto-skip after two tries.

### Verification status — three states

Every HOLD lands in exactly one of these. The body of the event records which.

- **✓ Verified** — found a public, no-login event page (see the source ranking in step 4) AND its date and time match the image. List the URL. On a conflict the page wins and it still counts as verified — against the page. Don't gate on the title matching; titles vary ("CYBERPUNK" vs "Cyberpunk (1990)").
- **⚠ Unverified** — a link exists but it didn't confirm the facts: a venue homepage, a monthly schedule, or a login-walled page that can't be read. Always include the best available link — the next-highest rung on the step-4 ladder — because the link has two jobs and verification is only one of them. Even when it verifies nothing, it's the user's starting point for finding out more about the event, venue, or organizer (the Lost Arts test: the exact event page was members-only, but lostarts.xyz still gets them to the community). A HOLD with no link at all should only happen when the image and two searches produced literally nothing.
- **ℹ No verification page found** — neither search attempt returned anything usable. This is an FYI, not an error: the HOLD is still filed, it just carries the image data as-is. Word it gently — "Couldn't find a webpage to verify against — filed from screen shot as-is" — never like a failure.

Reserve "verified" for actual corroboration. A link existing is not verification — that's the whole point of the badge.

**Per-field honesty (2026-07-04).** Verification isn't all-or-nothing. When the page corroborates some fields (date, venue) but is silent on another (start time), the badge can still say Verified — but the un-corroborated field gets its own plain-language caution line, prominent in the body, right under the main link. Pattern: `⏰ Start/end times from [the only source] — couldn't be re-confirmed on [what was checked]. Double-check the time when you get tickets.` Silence on a field is not a conflict; it's a gap, and the body says so in words the user's future self will understand at a glance.

### Step 7: Single confirm before create

Show one summary block and ask one yes/no question. **The block includes the full invite body, labeled `Description:` (Google Calendar's own name for the field), rendered as it will read in the calendar** — links, caution lines, labeled blocks, transcription, verification footer. Never a header-only confirm: the user inspects the body before saying yes (2026-07-05).

```
Ready to file:
Title:       📌 Hold: [event title]
When:        [date] · [start]–[end] [TZ]
Where:       [location or "Virtual"]
Calendar:    [the resolved destination from step 8 — "Event Holds" or your main calendar]

Description:
[the full body from step 8, rendered as plain text the way Google
Calendar will display it]

Schedule it? (yes / no / fix)
```

- yes → step 8
- no → stop, don't create
- fix → ask which field, edit, re-show summary, ask again

**Past dates don't matter.** A date in the past is not an error and not noise — the data is the data — old flyers file the same as upcoming ones. The only courtesy: if the resolved date is already past, add one neutral line to the confirm — `Heads up: this date is already past. Still schedule it? (yes / no)` — then proceed on yes. Don't moralize, don't refuse, don't call it noise.

### Step 8: Create the calendar event

**Sourcing rule for everything in the invite (2026-07-05):** every fact traces to the image or a page checked during this run. Never add background knowledge — genre labels, artist facts, venue lore — no matter how confident. If it isn't in a source the user can open, it doesn't go in. (The cut that set the rule: "house/dance" as a genre gloss on a Dom Dolla show — true, but sourced from the model, not the flyer or pages.) Synthesis lines like Topic re-say the sources' own words, nothing more. The only exception: resolving a named venue to its standard street address for geocoding — that's plumbing, not content.

Use the Google Calendar `create_event` tool with:

- **calendarId**: resolve by name, never by a pinned ID. Call `list_calendars` and look for a calendar named **"Event Holds"** — match case-insensitively with surrounding whitespace trimmed ("event holds" counts). If it exists, file there. If it doesn't, file to `primary` and append one line to the step-9 report: `Filed to your main calendar — create a Google calendar named "Event Holds" and future holds will file there instead, toggleable in the sidebar.` Don't create the calendar (the connector can't) and don't ask a setup question — the calendar's existence IS the configuration. Resolve the destination before the step-7 confirm so the block shows where the hold will actually land. If the create against a found calendar fails, stop and say which calendar was tried
- **summary**: `📌 Hold: [event title]` — always this exact prefix, even when the event title contains its own colon ("📌 Hold: Twin Peaks: Fire Walk With Me…" is correct; confirmed 2026-07-04, don't restructure to avoid the double colon)
- **start** / **end**: ISO datetime with `timeZone` set to the IANA TZ (e.g. `America/New_York`). **Date-only event:** set `allDay: true` and pass the date(s) instead of datetimes — this renders as the thin all-day banner, not a timed block. Omit `timeZone` for all-day events
- **location**: physical address or the literal string `Virtual`. This is the highest-value field on a HOLD — it's what gives the user the map, the directions, and the travel-time estimate. Always pass the full street address here. **Filing is a two-call operation, by design.** The connector drops `location` on `create_event` every time it's been observed, so don't treat the first call as enough: always follow `create_event` with an `update_event` that sets `location`. Don't bother branching on whether the create kept it — just always patch. If a create ever returns the location intact, fine, but never design around that.
- **colorId**: `"1"` (Lavender)
- **visibility**: `private`
- **availability**: `AVAILABILITY_FREE` (shows the time as **Free**, not Busy). A HOLD is a placeholder, not a commitment — it shouldn't block the user's availability or make them look booked. Default every HOLD to Free + Private.
- **attendees**: omit (no invitations)
- **description**: HTML, structured like this. **Formatting caution:** Google Calendar renders *both* `<br>` tags and literal newline characters as line breaks, so never put an actual newline next to a `<br>` in the description string — you'll get double-spacing. Keep each block's markup contiguous (no literal line breaks inside it); use `<br>` alone for a single line break and `<br><br>` for a blank line. Let the `<p>` tags handle spacing *between* sections.

```html
<p><b>[action label]:</b> <a href="[URL]">[URL]</a></p>
<!-- Label this link by what the source actually asks of the user — don't hardcode "Register". Most events (a movie, a free show) need no signup, and telling the user to "Register" for a walk-up screening is wrong. Default to the neutral "More info". Switch the label only when the image or page uses an action word:
       tickets / buy tickets  → "Tickets"
       RSVP                    → "RSVP"
       reservation required    → "Reserve"
       register / registration → "Register"
     Show the literal URL as the visible link text (e.g. https://www.spectacletheater.com/ ), not a friendly title. -->

<p><b>From the flyer:</b><br>
[the event's own description / caption text from the image, copied EXACTLY as written — same wording, same punctuation, same line breaks. Do not summarize, paraphrase, condense, fix grammar, or re-order it. If the screenshot cut it off, reproduce what's visible and append " … [truncated in screenshot]" at the break. ONE narrow exception (2026-07-07, Synthicide "🔥 TOMORROW 🔥" test): a standalone relative-time hype line (TOMORROW, TONIGHT, LAST CALL, DON'T MISS) may be omitted and replaced with "[…]" — it reads as false by the time the hold is opened. The Original transcription block below still keeps every word. No other edits, ever.]</p>
<!-- THE PRINCIPLE (2026-07-04): the HOLD body is the jumping-off point for deciding to attend — so ALL context from the image goes into the body, and every reference the image makes becomes a LIVE LINK, if it exists in the photo. Event page, tickets link, organizer site, venue, Instagram/X handles (resolve the handle to its real profile URL with one quick search/fetch — a dead "@name" in plain text is a miss), tag/category lines, capacity ("7 spots remaining, at time of screenshot"), the flyer artwork in one line so the event is visually recognizable later. Don't cherry-pick a "clean" excerpt; the <pre> transcription below is the raw backup, but the body itself should let the user reach the venue, the organizer, and the tickets without re-finding anything. Only skip what the image genuinely doesn't reference.
     ENRICHMENT (2026-07-04): the pages checked in steps 4–5 usually know things the image doesn't — the ticket page's own description, FAQ details (dress code, age limit, accessibility, hardship tickets), the venue's character. Bring the good ones into the body as their own labeled blocks: "From the ticket page:", "From the organizer's FAQ:". The label IS the anti-pollution rule — more context is better, but every block says where it came from, and nothing gets blended into the flyer's own words. -->

<p><b>Appearing live:</b><br>
- [Name], [Title]  ← only people present AT the event (host, intro, Q&A). Omit this whole block if the flyer names no live speaker. Never list film actors, documentary interviewees, or discussed authors here.</p>
<p><b>Audience:</b> [audience if visible in image or on page]</p>
<p><b>Topic:</b> [one-line topic summary]</p>
<hr>
<p><b>Original transcription:</b></p>
<pre>[full transcription from step 1]</pre>
<p><b>Source:</b> <a href="[source URL]">[source URL]</a></p>
<!-- Link to the source's own page (e.g. the Instagram profile https://www.instagram.com/spectaclenyc/ ). Show the literal URL string as the visible link text, not a friendly title. -->

[verification status footer — one of the three lines below]</p>
```

Footer line, pick the one matching the verification state from step 6:
```html
<!-- Verified -->
<p><i>✓ Verified against <a href="[URL]">[URL]</a> on [YYYY-MM-DD]</i></p>

<!-- Unverified (a link exists but didn't confirm the facts) -->
<p><i>⚠ Unverified — facts not confirmed. Closest source: <a href="[URL]">[URL]</a> (checked [YYYY-MM-DD])</i></p>

<!-- No verification page found (FYI, not an error) -->
<p><i>ℹ Couldn't find a webpage to verify against — filed from screen shot as-is</i></p>
```

### Step 9: Report back

One line plus the link the calendar tool returns, **delivered as a labeled markdown link — never the bare URL** (event links on a dedicated calendar run hundreds of characters; 2026-07-05):

```
HOLD filed: [📌 Hold: [event title] — [Mon D, time]]([calendar event URL])
```

That's it. Don't summarize what was done. Don't list the description fields back. The clickable calendar link IS the deliverable — put it directly in the reply, every single time, formatted as a link the user can tap. Never make them ask for it, never make them go find the event in their calendar themselves (2026-07-04).

## Tools this skill uses

- **Native image reading** — for step 1
- **WebSearch** — for step 4
- **web_fetch** — for step 5
- **Google Calendar `create_event`** + **`update_event`** (MCP connector) — for step 8. Filing always takes both calls: `create_event` to make the HOLD, then `update_event` to set `location` (the connector reliably drops location on create). `list_calendars` is also used to resolve the destination calendar by name (step 8) and to read the user's home timezone for virtual events with no printed TZ.

That's the full toolkit. If a tool is unavailable, stop and say which one is missing — don't try to work around it.

## Working style for this skill

- One question at a time. Never batch.
- Use real values in any preview block, never placeholders.
- Active voice. No buzzwords. No adverbs.
- Brutal honesty if the input is bad — say "this image doesn't have a date, I can't file a HOLD" instead of guessing.
- Don't recap what you just did in the final message. The calendar link is the deliverable.
