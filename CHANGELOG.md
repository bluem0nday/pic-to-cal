# pic-to-cal — Changelog

Semver for the skill itself. (Separate from BACKLOG.md's roadmap versions, which describe feature *scope* — v0.2 scope, v0.3 eval, etc. This file tracks what actually shipped in SKILL.md.)

## 0.4.1 — 2026-07-05

- **Generalized the ignore-the-frame rule.** 0.4.0 worded the flyer-only transcription rule around pole clutter — misleadingly narrow. The rule is about the photograph's frame in any setting (billboard, subway poster, program on a desk): once the event is identified, everything else in the frame is ignored, without explanation.

## 0.4.0 — 2026-07-05

Live-testing session (tests 6–8: a Planning Pod registration-page screenshot, a multi-session tarot poster that correctly hit the multi-event guardrail, and a Dom Dolla street poster — first real flyer photo, wrapped around a pole in blackletter type, filed ✓ Verified).

- **Confirm shows the full invite.** The step-7 confirm block now includes the complete body, labeled `Description:` (Google Calendar's field name), rendered as it will read on the calendar. Never a header-only confirm.
- **Availability check.** Every page fetch looks for ticket-availability signals (sold out / waitlist / sales ended / N remaining). When present, a dated caution line goes directly under the main link. Page silence adds nothing.
- **The event's flyer only.** Street photos usually carry unrelated posters, tabs, and stickers around the event's flyer. None of it is transcribed anywhere — no cataloging, no "[unrelated]" footnotes. Token clutter and brain clutter.
- **No background knowledge in the invite.** Every fact traces to the image or a page checked during the run. Genre labels, artist facts, venue lore from the model's own knowledge stay out — synthesis lines re-say the sources' words only. (Exception: venue-to-address resolution for geocoding.)
- **Labeled calendar link.** The step-9 report delivers the event link as a labeled markdown link, never the bare URL (dedicated-calendar URLs run hundreds of characters).
- **In-image corroboration.** Signals inside the image (e.g. a countdown timer) can silently confirm an inferred field like a missing year — a check, not invite content.

## 0.3.0 — 2026-07-04

Live-testing session (tests 3–5: Lost Arts open studio, Angelika Twin Peaks double feature, Midsummer Ball — first ✓ Verified filing).

- **Dedicated calendar.** All HOLDs file to the "Pic to Cal Events" calendar by pinned ID — never primary. Reverses the April primary-calendar decision.
- **Printed timezone wins.** An explicit timezone in the image is trusted verbatim (platforms localize to the viewer); venue-derivation only applies when nothing is printed.
- **Source-first lookup.** A URL, QR code, or Instagram handle printed in the image is checked before any web search.
- **Body-copy principle.** The HOLD body carries ALL context from the image, and every reference becomes a live link (handles resolved to real profile URLs). The transcription block is backup; the body reads like the invite.
- **Stacked links.** When the best link isn't a per-event page, include two: the most specific page found plus the venue's main site.
- **Per-field honesty.** Fields corroborated by only one source get a plain caution line in the body ("⏰ times from organizer email — double-check when you get tickets").
- **Labeled enrichment.** Details from the pages checked during verification (ticket page description, FAQ items, venue character) join the body as blocks labeled by source — "From the ticket page:", "From the organizer's FAQ:" — never blended into the flyer's own words.
- **All-day wording.** Date-only events file as all-day banners with "⏰ No starting time found — filed as all-day banner."
- **Title prefix** changed to `📌 Hold:` (from `📌 HOLD — `); kept even when the event title has its own colon.
- **Desktop triggers.** "calendar this," "create a calendar event for this screenshot/photo/from this"; pasted/dragged desktop images count as attached.
- **Photo handling.** Street-photo inputs (glare, angles, torn corners) transcribe with `[illegible]` markers, never guesses.
- **Deliver the link.** Step 9's calendar link is mandatory in the reply, every time.

## 0.2.0 — 2026-06-25

Film-flyer testing round (two Spectacle Theater flyers).

- Three-state verification (✓ Verified / ⚠ Unverified / ℹ no page found) with source-checkability ranking.
- Venue timezone derivation; venue-address recovery for geocoding.
- Midnight screenings file at 23:59 on the listed day; missing end time defaults to +2h with a note.
- All-day path for date-only flyers.
- Title pattern: who/what at where, venue in the title.
- Live-speaker vs content-subject distinction (no film actors as "speakers").
- Action-label links (Tickets/RSVP/Reserve/Register/More info) chosen from the source's own wording.
- Verbatim flyer copy in the body; create→update two-call sequence for the connector's dropped-location bug; HTML double-spacing fix.

## 0.1.0 — 2026-04-30

First draft. Nine-step workflow: transcribe → event check → extract → search (2 tries max) → fetch & diff (page wins) → no-page fallback → single confirm (yes/no/fix) → create with structured HTML description → one-line report. Trigger contract (image + specific phrases). Scope guardrails.
