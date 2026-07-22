# pic-to-cal — Changelog

Semver for the skill itself — this file tracks what actually shipped in SKILL.md.

## 0.9.0 — 2026-07-22

Browser-fallback release, from a screenshot of an application-gated rooftop
party: the host's site 403'd every fetch and the run filed Unverified — then
one browser load verified everything.

- **Browser fallback on blocked fetches.** A 403 usually stops only
  server-side fetchers; the in-app browser loads the same page like a normal
  visitor. When a fetch is blocked and the session has browser tools, the
  page gets opened there instead of degrading — the first live test turned
  an Unverified hold into a Verified one and recovered the real apply URL.
  Sessions without browser tools degrade exactly as before.
- **Second query changes strategy, not keywords.** Two keyword-shuffles
  surfaced only the host's homepage while the event page never appeared. The
  second search now aims at where event pages live — a platform name or the
  host's own event-URL pattern — and when the host's site is already known,
  loading it in the browser beats a second blind search.
- **Gated addresses are a finding, not a failure.** Application-screened
  events publish the address only after approval ("Address Info: Available
  after application approval"). File the city, quote the gate in a dated 📍
  caution, and don't burn searches on an address that isn't public.
- **Emphasis survives the copy.** The Details block keeps the source's own
  bolds as `<b>` — same wording, same punctuation, same line breaks, same
  emphasis.

## 0.8.0 — 2026-07-21

Street-poster release: the first real photo of a wheat-pasted flyer — carrying
TWO events — and field feedback that overturned a day-old rule.

- **Two events, one flyer.** Multiple events printed on the same flyer are all
  real — the opposite of frame clutter. Transcribe the whole flyer once, ask
  which to file, then each chosen event becomes its own HOLD with its own
  confirm, verification, and links.
- **Fixed 2-hour hold replaces the end-time formulas.** The venue's close is
  the end only when doors sit within ~5 hours of it — when the event plausibly
  IS the venue's whole night. Otherwise the hold is a fixed 2 hours, never
  scaled: not by start time, not by act count, not by event type. Any formula
  that converts flyer content into a duration smuggles in world-knowledge, and
  a placeholder that varies "intelligently" reads as information. The caution
  line declares the convention and carries the real signals as facts; the
  block under-claims, the label carries the uncertainty.
- **Source orthography.** Quoted blocks stay character-for-character. Titles
  keep each name's own spelling — accents, internal caps, spacing — and the
  primary source wins spelling conflicts. Display caps are typesetting, not
  spelling: take letter-case from a source that prints the name in running text.
- **Calendar color, not event color.** Verified by rendering every candidate:
  the API accepts only colorId 1–11, and the UI's current 24-name palette is
  unreachable from it. The skill no longer sets a per-event color — HOLDs
  inherit the Event Holds calendar's own color, a preference the user sets
  once in the Google Calendar sidebar. (`colorId: "0"` on update resets a
  stray override from older versions.)
- **Less clutter in the body.** Printed handles get a bare `@handle - URL`
  line, no label around it; an action link that repeats a URL already in the
  body is dropped — one link, once.

## 0.7.0 — 2026-07-20

Body redesign release, from a club-flyer test: no end time printed anywhere,
a multi-room lineup, and a body order that read like a ticket ad.

- **Remember-first body order.** The HOLD is for remembering and deciding,
  not pushing a purchase. The event's own content leads; the action link sits
  below it: Venue → Details → cautions → summary → action link → enrichment →
  transcription → footer. "Details (from the [source])" replaces "From the
  flyer" as the lead block, naming the actual source type.
- **End-time precedence chain.** Replaces the flat 2-hour placeholder:
  a close time published for the exact event (rare) → the venue's posted
  hours for that day, filed as closing with a dated label → a placeholder
  scaled by start time (9 PM or later → 4 hours, else 2). Event-type
  folklore ("clubs run till 3") stays out — every derived end names its source.
- **No lineup assumptions.** Name order on a flyer carries no meaning; set
  order and billing stay out unless the promoter publishes a roster with
  times. "Artists" is the generic label; DJ / band / live PA only when a
  source prints it.
- **Price on the action line.** Quoted as the ticket page prints it, dated —
  never a structured field, never computed from tiers, nothing when not shown.
- **Short cautions.** Time judgments, derived ends, and availability each get
  one labeled, dated line in a single caution block after Details.

## 0.6.0 — 2026-07-07

Speed release. The Synthicide test filed correctly but took ~5 minutes on a flyer that already carried full event info — most of it on fetches that were never going to succeed.

- **Known fetch-blocked platforms.** ra.co, AXS, and Ticket Tailor 403 every fetch, every test. The skill now skips the fetch for these and corroborates from the search listing directly, with per-field cautions for what the listing can't show. Domains that 403 twice join the list.
- **Address from results in hand.** The venue's street address is pulled from search results already on screen when the event page doesn't provide it; a dedicated venue search is the last resort, not the default.

## 0.5.0 — 2026-07-07

- **Calendar by convention, not pinned ID.** Step 8 no longer hardcodes a calendar ID. The skill looks for a calendar named "Event Holds" (case-insensitive, whitespace trimmed) via `list_calendars` and files there; when none exists it files to `primary`, and the report says how to upgrade: create a calendar with that name and future holds file there. A fresh install now works on the first run with zero setup, and the author's personal calendar ID leaves the public spec.
- **Triggers simplified to intent.** The description's eleven-phrase enumeration is replaced by one rule — an attached image plus any request to put it on the calendar — with a few representative examples ("calendar this", "add to calendar", "save the date", "pencil this in"). Shorter, broader, and the exclusion rules keep their room.
- **Spec sanitized for publication.** The author's name and personal working-style notes are out of the spec; rules now speak of "the user," and dated test-case attributions keep the date and case name only. Private project-doc references removed.
- **Relative-time exception to the verbatim block.** A standalone hype line like "TOMORROW" or "LAST CALL" may be dropped from the From-the-flyer block, marked with "[…]" — it's false at read time. The transcription still carries every word. (From the Synthicide test.)
- **README truth pass.** Tickets reframed to the event's own best link (a sold-out notice seen on the page is carried into the hold, dated); the midnight rule corrected to say holds *start* at 23:59 on the flyer's day; the QR-code claim removed (never specced or tested — the 0.3.0 entry below carries the same correction).

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
- **Source-first lookup.** A URL or Instagram handle printed in the image is checked before any web search. (Corrected 2026-07-07: this entry originally claimed QR codes too — QR handling was never specced or tested.)
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
