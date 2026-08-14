# pic-to-cal — Changelog

Semver for the skill itself — this file tracks what actually shipped in SKILL.md.
Every entry opens in plain English; the bullets underneath carry the technical
detail.

## 0.17.0 — 2026-08-14

One screenshot can produce more than one hold, and until now nothing
said each of them has to earn its verification separately. A single good
source page could have been stamped across every hold split from the
same image, which would tell the user facts were confirmed when they
weren't. It can't now.

- **Verification is decided per hold, not per source.** When one image
  or page yields several HOLDs, each is checked and badged on its own.
  The run that found it: an Instagram post whose artwork advertised a
  block party and whose caption added an after party inside the bar the
  same night. The co-host's event page confirmed the block party, so
  that hold filed ✓ Verified; the after party appeared nowhere but the
  caption, so it filed ⚠ Unverified. Same screenshot, two states.

## 0.16.0 — 2026-08-12

Private runs used to end with a hand-run cleanup: find the conversation
file, delete it, check what the app wrote back, report the leftovers. The
permission layer stopped and questioned the loose commands on every run,
and the closing report read like an error even when everything had worked.
The cleanup is now one pre-approved script, one yes covers filing and
cleanup, and the run closes with one word. Same promise, none of the
friction.

- **One script replaces the command sequence.** `private-scrub.sh` finds
  the session's transcript by its id, confirms the file claims that id
  inside, refuses to touch any other file, and deletes it. A project
  permission rule pre-approves exactly that script path, so the permission
  errors that hit every private run to date are gone. No broad delete
  permission exists anywhere.
- **The residue check is retired from routine runs.** The app rewrites a
  small session card after the delete, and the card names the event nearly
  every time, because the app writes it from what the conversation was
  about. Checking for a known, unchangeable outcome and announcing it each
  run made success read as failure — the author read the residue paragraph
  as an error twice before asking why it was there. The limit now lives once in
  the spec's fine print. The 0.14.1 scratch-file rule survives as a
  build-mode note for recorded tests; the check also never belonged inside
  the cleanup step, since the card is written back only after the run's
  last command has finished.
- **One yes covers filing and cleanup.** The private confirm now ends with
  "Save the event and delete the record of this session? (yes / no /
  fix)" — the author's wording, as is the close: the run ends with the
  calendar link plus "Cleaned, done." and nothing else.
- **The fine print went plain-English.** What private mode promises, what
  the app keeps regardless, and what lives beyond any local cleanup — the
  Mac's backups and Anthropic's own retention — in one short paragraph
  with no file formats and no tool names.
- **The order is now explicit: report, then clean up, then one closing
  line.** The cleanup erases only what came before it, so the report — which
  names the event in its link — goes out first and gets erased from the
  record while the user keeps it on screen. The day's own run had done it
  backwards, scrubbing first and reporting after, which wrote the event
  name straight back into the file it had just cleaned.
- **The 🤫 title marker (2026-08-12, unversioned until now) rides along in
  this release**, as promised when it shipped without one.

## 0.15.0 — 2026-08-07

The skill used to fetch a page first and open a browser only when the fetch
failed. It failed about half the time, and the workarounds had grown into
four separate rules. Those rules are now one rule: open the page in the
browser. The fetcher stays on as the stand-in for a session that has no
browser, which is the only job it was ever doing well.

The reason is not the failure rate. A blocked fetch says it was blocked. A
fetch that quietly summarizes the page says nothing at all, and reads just
as confident either way. Holds have to quote the venue word for word, so a
summary can never be the source, and a browser read has to happen on every
run regardless. Fetching first changed nothing that came after it.

- **Render first; fetch only without a browser.** Step 5 opens the page in
  the browser and reads it there. The four fetch failures seen in testing
  are now listed in one place as the reason, not as four exceptions: 403
  Forbidden, a login screen, site chrome with no event content, and the
  quiet one, a summary or a refusal returned under HTTP 200. Roughly 1,100
  words of exception-handling became about 400.
- **The no-browser path keeps everything it had.** Watch the content and not
  the status code. Never re-prompt a refusal, since firmer wording sometimes
  fixes a paraphrase and never fixes a decline. On a domain that has 403'd
  twice, skip the retry and corroborate from the search listing.
- **New evidence for the blocked list.** shiftux.rosenfeldmedia.com, an
  ordinary conference site with no apparent reason to block, 403'd a plain
  fetch and rendered fine in the browser.
- **Same change downstream.** Step 1's URL-input rule, step 4's won't-load
  rule, the tools list, and the two page-reader rows of the capability table
  all now name the browser as the reader and the fetcher as its stand-in.

## 0.14.1 — 2026-08-07

Version 0.14.0's end-of-run check leaked what it was looking for. Searching
the file for the event's name put that name in the file. It now reads the
terms from a separate file and the command carries none of them. No private
event ran under the old version.

- **A check that names the thing it is checking for writes it down.** After a
  private run deletes its transcript, the runtime writes a small file back,
  and the skill looks in that file for the event's name, venue, and link. The
  search command is itself recorded there, so naming the event in order to
  run the search put it straight back into the one file the run had just
  cleaned. The terms now go in a scratch file outside the transcript folder,
  the search reads them from there, and the scratch file is deleted when the
  check is done. Found by 0.14.0's own verification run, on a public test
  event.

## 0.14.0 — 2026-08-07

Some events are nobody's business. The skill is still being built, so an
ordinary run leaves a paper trail behind the hold: a line in the test log,
a changelog entry, a new rule crediting the event that taught it, a saved
copy of the picture. During a private test in early August all of that was
suppressed by hand, one instruction at a time. It is a mode now.

Saying "private" or "incognito" alongside the usual ask files the hold and
records nothing else. The hold is untouched. Same body, same links, same
checks. Only the paperwork goes away.

- **A word on the ask turns it on.** "pic to cal private", "private hold",
  "calendar this, incognito". The word has to be part of the request. A
  flyer for a private party, or a members only page, leaves the mode off,
  because that describes the event and says nothing about how the user
  wants the run recorded. When a request reads both ways the skill asks
  once before starting.
- **A private run writes nothing down.** No test log entry, and the clean
  run streak stays where it is. No parked idea, no dated rule, no changelog
  line. No artifacts, no screenshots, no saved copy of the picture. No
  memory. No session notes.
- **Anything learned during a private run is thrown away.** If a real bug or
  a new case turns up, the skill says so in the chat and leaves it there. A
  dated rule recording what was learned also records that a run happened,
  and roughly when. The user can reproduce the finding later with an event
  they don't mind logging.
- **The hold is a normal hold.** Full description, exact quotes, cautions,
  links, the verification footer, and the read through that checks the body
  is safe to forward. Private mode changes what gets recorded. The hold is
  the one thing the user asked to keep.
- **The confirm block says the mode is on.** One line above the usual
  summary, so the user sees it before saying yes.
- **The run deletes its own session record.** The last thing a private run
  does, once the hold is filed, is delete the file holding the conversation.
  The trigger word is the permission, so the skill does not ask a second
  time. It does ask in one case: when the private run sat in the middle of a
  longer working session, deleting that file erases the whole session, so
  the user gets a say.
- **The scrub says where it stops.** The runtime writes a fresh file
  straight back, carrying the last thing the user typed and two versions of
  the session title, so the skill checks that file for the event and reports
  what it finds. It states the limit once: a run that ends early never
  reaches the scrub, and the runtime's own 30 day cleanup is the backstop.

## 0.13.0 — 2026-08-05

A cinema was showing one film two ways at the same time, on 35mm and on
digital. Each version had its own page, and the two pages read almost
alike: same title, same cast, same summary, even the same heading over
the Q&A list. The skill found the digital page first. That page listed
different times and was missing one of the three nights, the one night
the star of the film appeared. The skill had the right cinema, the right
film, and the wrong showing.

Version 0.12.0 fixed the same mistake in another form: a permanent film
page still holding dates from an old run. The two are now one rule with
three quick checks.

Sold-out events read differently now. The skill only learns an event is
sold out after it looks the event up, long after the user has moved on.
So the hold gets filed either way, with the status where it will be seen.

- **Three checks before the skill trusts a page's dates.** Do the page's
  dates fall in the month being filed? Does the title carry the same
  format as the picture? Is one field different, or several at once? A
  page that fails any of the three is about something else, so it no
  longer wins on conflict. It can still supply the summary, the credits,
  and the running time. The dates come from the venue's current listing.
  (Test 18: the old rule would have filed three holds with wrong times.)
- **A format in the title is part of what the event is.** 35mm, 70mm,
  IMAX, open captions, subtitled, director's cut. The skill used to treat
  a title difference as harmless, since titles vary. A format word is the
  exception. If the picture has one and the page does not, they are two
  different showings.
- **Finding the right page means reading the venue's own list.** The skill
  already refused to guess a page's address from the film's title. It now
  has something to do instead: load the venue's listing and read every
  link on it. The correct page in this test sat next to the wrong one in
  that list, and no search had surfaced it.
- **Sold out is the first line of the hold and sits in the title.** The
  title reads "Hold: SOLD OUT" and then the event. The word "Hold" stays,
  because it is still a hold. The skill asks once before filing. Waitlist
  and closed sales get the same handling, in the venue's own words.
  Cancelled and postponed events have no rule yet.
- **A page that loads but arrives empty now gets opened in a browser.**
  Some venue sites build themselves after the page loads, so fetching one
  returns a menu, a cookie notice, and no event. Asking the fetch again
  cannot help. Opening the page does, and it also reveals the venue's list
  of links.
- **Those sites cannot be verified without a browser.** No browser means no
  page and no list, so there is no way to tell the right showing from the
  wrong one. The hold still gets filed. It carries the venue's link and
  says the facts were not confirmed.

## 0.12.0 — 2026-08-05

A poster that lists what's playing but never says when. Venues announce a
month of films this way all the time. The skill now treats the picture and
the venue's website as two halves of one answer. The picture says which
films. The website says which nights. Both get checked against each other
before anything is filed.

Two ways this used to go wrong are now closed. Some venues keep one
permanent page per film and update it each time the film returns, so the
dates on it can be months old. The skill checks whether those dates fall in
the month it is filing, and takes the schedule from the venue's current
listing instead. And when the skill copies a venue's own description into a
hold, it now reads the page in a browser. Fetching the page can return a
summary written by a tool rather than the venue's words.

- **A picture with no date at all now has a path.** Lineup and season
  announcements name titles and runtimes and nothing else. The skill reads
  identity from the picture and the schedule from the venue's page. The
  hold is verified when titles, directors, years, and runtimes match across
  both. The footer says the picture had no dates and names the page that
  supplied them. If no schedule can be found, nothing is filed and the skill
  says so. Several showtimes means one question, then one hold each.
  (Test 17: one Instagram post became ten holds.)
- **A venue's current listing beats its permanent film page.** Repertory
  cinemas replay their catalog, so a per-film page carries whichever run
  was published to it last. The test is one question: are the page's dates
  in the month being filed? If not, the page is stale. Read it for the
  synopsis and take the dates elsewhere. Guessing a page's address from the
  film's title is also out. Those guesses usually fail, and the ones that
  work land on the stale page.
- **Exact quotes come from a rendered page.** Asked to reproduce a
  description word for word, a fetch tool may return a summary or decline
  outright. Rereading with firmer wording does not fix a decline. One
  browser page read returns the real text. Two signs you were handed a
  summary: the writing is smoother than a venue would write, or the tool
  describes the text instead of reproducing it.
- **Without a browser, the hold says the description is short.** It carries
  the credits and any exact quote that survived, plus a line pointing at the
  source for the rest. A summary presented as the venue's own words is the
  failure this avoids. Dates, times, and place are unaffected.

## 0.11.0 — 2026-07-28

Paste a link, get a hold. Hand the skill an event page's URL with "put a
hold on this" and it creates the same calendar hold.
No screenshot needed. There's nothing to check a page against, so no
verification badge. Instead, the calendar hold confirms that everything in
it came from the web page, and nothing additional was added by AI. Also
new: a final reread before any hold is created, after a real slip left a
family-travel note in one. Holds may get forwarded to friends, so the skill
rereads each one the way a friend receiving it would. Nothing about the
user's account or calendar. Every fact is re-checkable on the event's page.

- **A URL can now start the skill.** An event-page URL plus a filing ask
  starts the workflow. A bare pasted URL does not. Several URLs file one hold
  each. If a trigger phrase arrives with neither image nor URL, ask. (Test 16:
  three Film Forum pages filed clean this way.)
- **A plain promise replaces the verification badge on URL input.** The
  page can't disagree with itself, so ✓/⚠/ℹ are image-input states. A
  URL-filed hold ends with a footer instead. It gives the page's URL, the
  date it was read, and a note that every fact came from that page with
  nothing added. The risk on this path is the model adding things. The
  footer makes additions easy to catch: open the page and find every fact.
  Anything you can't find is a mistake.
- **Nothing about the user goes in the invite.** The invite never mentions
  anything else on the user's calendar. That context goes in
  chat instead. Before filing, reread the invite as a friend receiving it
  would. Everything in it should be on the event's own page. None of it
  should be about the user. Anything that fails that test gets deleted.
  Rewording is not enough.
- **Most of steps 4–6 doesn't apply to URLs.** No search, no ladder. If the
  page won't load even in the browser, stop. There's no fallback data. The
  whole page is read for everything the invite needs. A free protest march
  has no tickets, so there the organizer's site and handles are the best
  links. The action link is labeled by what the page asks. Never invent a
  buy step. One showtime on the page files directly. Several showtimes mean
  one question. A date named in the user's ask needs no question.
- **Verbatim capture rule.** Fetch summarizers paraphrase. The event's own
  description must be requested character-for-character, and re-fetched if
  it comes back as a summary (two of three Test 16 blurbs did).
- **Confirm skipped when the ask already answered it.** When a URL comes
  with a clear file-it instruction and the page shows exactly one clean
  showtime, the skill files directly and reports. Anything less shows the
  confirm. Past dates still get the heads-up question.
- **Published runtime joins the end-time chain** (both input types), as rung 2
  of 4. The end time is the start plus the listed runtimes, labeled with ⏱.
  It sits above venue hours and the 2-hour fallback. Legal because the
  source printed the number.
- **Degradation table updated per input type.** Image reading and web search
  are image-input rows. Page fetch is required for URL input (no page, no
  hold; stop and say so).

## 0.10.0 — 2026-07-25

A locked door is not a blank wall. Instagram and Facebook show a login screen
to automated readers, so the skill used to treat those posts as unreadable and
move on. A real browser sees the post the way anyone scrolling past would — so
now the skill looks, and the extra detail comes back with the hold: the price,
the organizer's own words, the artist handles the flyer left off. What it finds
there still can't verify anything, because a page behind a login isn't proof.
This release also writes down what the skill loses when a tool is missing,
which matters because the phone version won't have the same ones.

- **A login wall means "can't verify," not "can't read."** When the source is
  login-walled and the runtime can render a page, open it and read it. Every-
  thing it returns is enrichment: a walled source never earns the ✓ badge and
  nothing load-bearing may rest on it. Logged-out rendering is inconsistent —
  a login screen means degrade and move on. (Learned from a Brooklyn block
  party flyer whose Instagram post carried the price and seven artist handles
  the flyer never printed.)
- **The degradation contract is now written down.** One table naming each
  capability and what breaks without it, plus the rule underneath: a missing
  capability costs detail, never correctness. A hold filed with none of the
  optional rungs is still a correct hold — right date, right place, a link
  back — it just carries less.
- **Two rules that hold in any runtime.** Verification is never assumed: with
  no proof, the hold says so instead of filing a confident-looking guess. And
  enrichment is never load-bearing: if a block of body copy would change the
  date, time, or place, it isn't enrichment.

## 0.9.0 — 2026-07-22

The skill learned to use a browser. Some event sites block automated readers,
and until now those events filed as "couldn't confirm." The skill now opens
blocked pages in a real browser, the way a person would, so more holds come
back verified with the real sign-up link attached. It also searches smarter
on its second try, and when an event hides its address until an application
is approved, the hold says exactly that. (Learned from a rooftop party
screenshot whose site blocked every automated read.)

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

One poster can advertise two shows. A photographed street poster carried two
concerts at two venues, so the skill now asks which to file and gives each
its own hold. It also stopped guessing how long events run: with no end time
printed anywhere, the hold is a flat two hours plus a note that the end is
unknown, because a guess dressed as a fact misleads more than an honest
placeholder. Names keep their own spelling, exactly as the artist writes
them, and hold color now comes from the calendar itself.

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

This release reordered the hold to read the way a reminder should: what the
event says about itself comes first, and the buy link sits below it. It also
set rules for missing end times, unlisted set orders, and prices — in every
case the hold reports what a source actually says and flags what nobody
knows. (From a club-flyer test with no end time printed anywhere.)

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

A speed release. One test filed correctly but took about five minutes, most
of it waiting on websites that refuse automated readers. The skill now
recognizes those sites, skips the doomed step, and works from the search
results it already has.

- **Known fetch-blocked platforms.** ra.co, AXS, and Ticket Tailor 403 every fetch, every test. The skill now skips the fetch for these and corroborates from the search listing directly, with per-field cautions for what the listing can't show. Domains that 403 twice join the list.
- **Address from results in hand.** The venue's street address is pulled from search results already on screen when the event page doesn't provide it; a dedicated venue search is the last resort, not the default.

## 0.5.0 — 2026-07-07

The clean-up release that made the skill shareable. It no longer depends on
the author's personal calendar setup — anyone can install it, and it finds
an "Event Holds" calendar by name or files to the main calendar and explains
the upgrade. Personal details left the public text.

- **Calendar by convention, not pinned ID.** Step 8 no longer hardcodes a calendar ID. The skill looks for a calendar named "Event Holds" (case-insensitive, whitespace trimmed) via `list_calendars` and files there; when none exists it files to `primary`, and the report says how to upgrade: create a calendar with that name and future holds file there. A fresh install now works on the first run with zero setup, and the author's personal calendar ID leaves the public spec.
- **Triggers simplified to intent.** The description's eleven-phrase enumeration is replaced by one rule — an attached image plus any request to put it on the calendar — with a few representative examples ("calendar this", "add to calendar", "save the date", "pencil this in"). Shorter, broader, and the exclusion rules keep their room.
- **Spec sanitized for publication.** The author's name and personal working-style notes are out of the spec; rules now speak of "the user," and dated test-case attributions keep the date and case name only. Private project-doc references removed.
- **Relative-time exception to the verbatim block.** A standalone hype line like "TOMORROW" or "LAST CALL" may be dropped from the From-the-flyer block, marked with "[…]" — it's false at read time. The transcription still carries every word. (From the Synthicide test.)
- **README truth pass.** Tickets reframed to the event's own best link (a sold-out notice seen on the page is carried into the hold, dated); the midnight rule corrected to say holds *start* at 23:59 on the flyer's day; the QR-code claim removed (never specced or tested — the 0.3.0 entry below carries the same correction).

## 0.4.1 — 2026-07-05

A wording fix to one rule: ignore everything in a photo that isn't the
event's own flyer, wherever the photo was taken.

- **Generalized the ignore-the-frame rule.** 0.4.0 worded the flyer-only transcription rule around pole clutter — misleadingly narrow. The rule is about the photograph's frame in any setting (billboard, subway poster, program on a desk): once the event is identified, everything else in the frame is ignored, without explanation.

## 0.4.0 — 2026-07-05

First real street-poster session, and three lessons stuck: the user approves
the full invite text before anything is filed, a sold-out notice seen on a
ticket page is carried into the hold with the date it was seen, and the hold
contains only what the flyer or a checked page actually says — never the
model's own trivia. (Tests 6–8: a registration-page screenshot, a
multi-session tarot poster that correctly hit the multi-event guardrail, and
a Dom Dolla street poster wrapped around a pole in blackletter type, filed
✓ Verified.)

- **Confirm shows the full invite.** The step-7 confirm block now includes the complete body, labeled `Description:` (Google Calendar's field name), rendered as it will read on the calendar. Never a header-only confirm.
- **Availability check.** Every page fetch looks for ticket-availability signals (sold out / waitlist / sales ended / N remaining). When present, a dated caution line goes directly under the main link. Page silence adds nothing.
- **The event's flyer only.** Street photos usually carry unrelated posters, tabs, and stickers around the event's flyer. None of it is transcribed anywhere — no cataloging, no "[unrelated]" footnotes. Token clutter and brain clutter.
- **No background knowledge in the invite.** Every fact traces to the image or a page checked during the run. Genre labels, artist facts, venue lore from the model's own knowledge stay out — synthesis lines re-say the sources' words only. (Exception: venue-to-address resolution for geocoding.)
- **Labeled calendar link.** The step-9 report delivers the event link as a labeled markdown link, never the bare URL (dedicated-calendar URLs run hundreds of characters).
- **In-image corroboration.** Signals inside the image (e.g. a countdown timer) can silently confirm an inferred field like a missing year — a check, not invite content.

## 0.3.0 — 2026-07-04

The release where holds got their own calendar and the invite body grew up:
every link printed on a flyer becomes a tappable link in the hold, printed
timezones are trusted as printed, and anything only one source claims gets
flagged for double-checking. (Tests 3–5: Lost Arts open studio, Angelika
Twin Peaks double feature, Midsummer Ball — first ✓ Verified filing.)

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

Lessons from two movie-theater flyers: how to verify an event against a real
page and say so honestly, how to file a midnight movie on the right day, and
how to name events so they're recognizable at a glance.

- Three-state verification (✓ Verified / ⚠ Unverified / ℹ no page found) with source-checkability ranking.
- Venue timezone derivation; venue-address recovery for geocoding.
- Midnight screenings file at 23:59 on the listed day; missing end time defaults to +2h with a note.
- All-day path for date-only flyers.
- Title pattern: who/what at where, venue in the title.
- Live-speaker vs content-subject distinction (no film actors as "speakers").
- Action-label links (Tickets/RSVP/Reserve/Register/More info) chosen from the source's own wording.
- Verbatim flyer copy in the body; create→update two-call sequence for the connector's dropped-location bug; HTML double-spacing fix.

## 0.1.0 — 2026-04-30

The first working version: read the image, check it's really an event, find
the sign-up page, confirm once, file a hold on the calendar.

First draft. Nine-step workflow: transcribe → event check → extract → search (2 tries max) → fetch & diff (page wins) → no-page fallback → single confirm (yes/no/fix) → create with structured HTML description → one-line report. Trigger contract (image + specific phrases). Scope guardrails.
