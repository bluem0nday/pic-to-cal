# pic-to-cal — Changelog

Semver for the skill itself. (Separate from BACKLOG.md's roadmap versions, which describe feature *scope* — v0.2 scope, v0.3 eval, etc. This file tracks what actually shipped in SKILL.md.)

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
