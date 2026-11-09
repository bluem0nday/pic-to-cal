---
name: pic-to-cal
version: 0.27.0
description: Files and updates event entries on Google Calendar: a Hold for an event the user might attend, and a Confirmed entry once they are going. Invoked as "pic-to-cal" or "pic to cal". Trigger on intent, whatever the input: an event image (screenshot, flyer, poster, photo), an event-page or ticket link, a ticket PDF, a receipt or order email, or words alone. Phrasings include "calendar this", "add to calendar", "hold this event", "save the date", "pencil this in", "I got tickets", "I'm going to that show", "change it to Confirmed", "add the tickets to the hold", "did I get tickets for", "I'm not going to". Pasted or dragged screenshots count as attached. A bare pasted URL with no ask is NOT a trigger. Do NOT trigger on broad capture phrases like "save this" or "add this" with no event context; those belong to quick-capture. Do NOT trigger on a headshot, a company logo, or a screenshot of a chat message; route those to quick-capture or update-contact. If the ask names no event Claude can find, ask which one.
---

# pic-to-cal

Take an event image, an event-page URL, a ticket PDF, an email, or the user's own words, find the official registration URL, and create a HOLD on the "Event Holds" Google Calendar (or the primary calendar when no "Event Holds" calendar exists — see step 8) so it doesn't get lost. When the event is already there, change that entry instead (see "Actions on a found entry"). Both `pic-to-cal` and `pic to cal` are correct names for the skill.

## Why this skill exists

The user screenshots events on Instagram, X, and email all the time — and photographs posters out in the city: concert posters, street flyers, anything taped to a wall with a date on it. Then they forget about them. Manual flow is: open calendar, type title, find the registration page, paste URL, set time, save. This skill collapses that to: attach image, type a trigger phrase, confirm once, done.

The HOLD is intentionally low-commitment — it goes on the calendar before the user has decided whether to attend. The 📌 prefix and the Event Holds calendar's own color make HOLDs visually distinct from real meetings (the color is a calendar-level setting — see step 8). A Confirmed entry takes the color of the user's regular appointments, because it is one.

## What's in scope (v0.2)

The single-image, single-day case. Find the registration URL via web search and use it to verify the facts in the image. If the search fails, file the HOLD anyway and flag the description as unverified.

Also in scope since v0.12.0 (2026-08-05): **the dateless announcement** — a lineup or season post that names the events but never says when. The image supplies identity and the venue's schedule page supplies the calendar; see the "No date anywhere" rule in step 3. One announcement can yield many holds (Test 17 filed ten from one post).

Also in scope since v0.11.0 (2026-07-28): **URL-only input** — the user hands an event-page link instead of an image. Same protocol, cheaper path: the page is the source, so there's nothing to search for, and instead of a verification badge the hold ends with a plain promise — all facts from this page, nothing added. This is the iOS share-intent app's primary path — a share sheet delivers URLs more often than images.

Also in scope since v0.21.0 (2026-11-01): **proof of purchase**, such as an order confirmation, a receipt, or a ticket. The decision is already made, so the entry files as a confirmed plan: `📌 🎟 Confirmed:` and Busy. See "Confirmed entries" below.

Also in scope since v0.24.0 (2026-11-02): **the lookup**. Before any create, the skill checks Event Holds for an entry that already covers the event, and reports that entry instead of filing a second one. See "The lookup" below.

Also in scope since v0.25.0 (2026-11-02): **the two states and the actions on a found entry**. A hold changes to Confirmed when proof of purchase arrives, later proof adds to a Confirmed entry, and the user can remove an entry. See "The two states" and "Actions on a found entry" below.

Also in scope since v0.26.0 (2026-11-03): **starting on intent**. The skill starts when the user wants an event on the calendar or wants to change one that is there, whatever the input: an image, a link, a ticket PDF, an email, or words alone. See "Trigger contract" and "Starting from words" below.

Also in scope since v0.27.0 (2026-11-08): **Confirmed on the user's word, and color by state**. An entry is Confirmed when the user says so, with or without a ticket. A Hold keeps its calendar's color, and a Confirmed entry takes the color of the user's regular appointments, or red when it is private. See "Confirmed entries" and "The two states" below.

## What's out of scope (do not build)

Multi-day events, matching entries that other apps add to the calendar, changing a Confirmed entry back to a Hold (Remove covers a user who is no longer going), recurring detection, T-2 re-verification, eval/QA checks, RSVP actions, sending email or acting on it (RSVPs, replies), scheduled tasks, first-run setup. Those are later versions. If a user request implies one of these, say so and stop — don't improvise. Reading email is in scope: a receipt for a confirmed entry since v0.23.0 (see "Confirmed entries"), and an email as the input since v0.26.0 (see "Trigger contract").

## Trigger contract

**The skill starts on intent (2026-11-02).** It runs when the user wants an event on the calendar, or wants to change one that is there, whatever form the input takes. Read what the user wants, never a fixed phrase or word order, as private mode does.

**What never starts it.**

- A bare pasted URL with no ask. The user may be doing something else with it.
- An image with no ask. The user is using a different skill or talking conversationally.
- The broad capture phrases, such as "save this" or "add this" with no event context. Those belong to quick-capture.
- A headshot, a company logo, or a screenshot of a chat message. Step 2 routes them.

**When the ask names no event Claude can find,** ask one question: `Which event?` Never ask for an image and stop.

**The words decide the action, and the input decides the facts.** Words that name an action win: "I got tickets", "I'm going", "we're going", "change it to Confirmed", "I'm not going", "hold it for now". Plain filing words name no action, so "calendar this" and "pic to cal" leave the action to the input and the lookup. The phone app gets no words, so there the input always decides.

**What each input usually is.**

- **An image.** A flyer, poster or event screenshot is an event. A receipt or ticket is proof of purchase, by the cues in "Confirmed entries". A screenshot of an email reads as that email.
- **A link.** An event page or a ticket-sale page is an event. A link that opens the user's own order or tickets is proof. Links came in on 2026-07-28 (Test 16), and they are the iOS share-intent app's primary path.
- **A PDF.** A ticket or receipt is proof. A program or flyer is an event. Step 1 says how to read it.
- **An email.** An order confirmation or ticket email is proof. A mailing-list email or an invitation is an event. Step 1 says how to read it.
- **Words alone.** The user names the event and the action. See "Starting from words".

When an input reads both ways, ask before the confirm: `Do you have tickets for this? (yes / no)`.

Several URLs in one message = one HOLD per URL, each with its own body and report (same shape as two-events-on-one-flyer, 2026-07-21).

**What URL input changes downstream (map, details in each step):** step 1 reads the page word for word instead of transcribing pixels; most of steps 4–6 doesn't apply (the URL is the source — no search); the verification footer becomes the nothing-added promise (see "Verification status"); everything else — body structure, sourcing rules, calendar mechanics — runs unchanged.

## Private mode (2026-08-07)

Some events are nobody's business. A skill that files holds gets pointed at real life, and this one is also under construction, so every ordinary run leaves a paper trail: a run-log entry, a changelog line, a dated rule crediting the event that taught it, a saved copy of the image, a note in the session doc. Private mode files the hold and leaves no trail. It changes what gets **recorded**, never what gets **filed**.

**The trigger is a modifier on the ask, not a word in the event.** Either word turns it on — private or incognito — anywhere in a normal filing ask.

**Position and wording don't matter (2026-08-12).** Before the skill name, after it, or wrapped around it; the bare word, the adverb, or "private mode"; with or without a connecting verb. All of these fire it, and the list is illustrative, not exhaustive: "pic to cal private", "private pic to cal", "run pic to cal in private", "private mode pic to cal", "pic to cal, private mode", "private hold", "calendar this, incognito", "put this on my calendar privately". Read the intent — never pattern-match a fixed phrase and never make the user guess the magic word order. If the ask says to file it and also says private, the mode is on.

What does NOT turn it on is the word appearing in the event's own copy: a flyer for a private party, a page that says private members only, a venue with Private in its name. Those describe the event; they say nothing about how the user wants the run recorded. When an ask genuinely reads both ways, ask one question before starting — `Private run (nothing recorded in this project), or a normal one?` — and wait. Don't guess. Guessing wrong one way leaves a trail the user didn't want; guessing wrong the other way silently skips the test log.

**What changes: this run writes nothing down.** The covenant is over the whole session, not just the nine steps. A private run produces:

- no run-log entry, and the clean-run streak does not move in either direction
- no parked idea, no dated rule, no changelog line, no version bump
- no artifact, no 2-up, no invite screenshot, no saved copy of the image anywhere on disk
- no memory write
- no session doc, resume note, or handoff line
- no mention in a later summary of "what we did today"

**Lessons from a private run are discarded.** If something spec-worthy surfaces — a new input shape, a source trap, a bug — say it out loud in the chat reply and stop there. Don't write it down anywhere, not even in sanitized form, because a dated rule that says what was learned also says a run happened and roughly when. The user can reproduce the finding later with an event they don't mind recording. One rule is worth less than the promise that private means private.

**What doesn't change: the hold itself.** Full body, exact-copy Details, cautions, links, verification footer, the guest check, the no-life-context rule, Free + Private + no attendees. A private hold is a normal hold; the calendar entry is the one artifact the user asked for. Nothing about this mode makes the body thinner.

**One exception, in the title only (2026-08-12): 🤫 rides after the pushpin.** A private hold reads `📌 🤫 Hold: [event title]` instead of `📌 Hold: [event title]`, so the user can spot it in a month of calendar entries without opening it. The full spec is in step 8's `summary` field. Nothing else about a private hold differs, and the marker is a deliberate trade: the title is the one record this mode keeps, so the 🤫 is also the one lasting sign that a run was private — it travels with the hold if it's ever forwarded or the calendar is shared. A private Confirmed entry also turns red (2026-11-08; see step 8's `colorId` field).

**The confirm block opens with the signal line**, so the user can see the mode is on before saying yes (rewritten in plain English 2026-08-12 — the old line read like a systems audit):

```
PRIVATE RUN — files the hold, writes nothing down in this project, and deletes this session's record from this Mac at the end. (A small session card the app keeps can't be removed — fine print in the spec.)
```

One line, at the top of the block, above `Ready to file:`. **The closing question changes too (2026-08-12, the user's wording):** a private confirm ends with `Save the event and delete the record of this session? (yes / no / fix)` instead of `Schedule it? (yes / no / fix)` — one yes covers the filing and the cleanup, so the cleanup is never a second conversation. On a run that skips the confirm (URL input, step 7), the signal line leads the report instead and the trigger word itself is the yes.

**Last step: clean up.** After the hold is filed and reported, and only then. The user already said yes to this at the confirm — never ask again. Since v0.16.0 the cleanup is one script call. It replaced a hand-run command sequence (find the file, verify it, delete it, check what came back) that the permission layer stopped and questioned on every private run — the errors were the safety system doing its job on loose delete commands, and a single pre-approved script removes the cause instead of arguing with the symptom (2026-08-12).

1. **Run the script, alone.** `~/.claude/skills/pic-to-cal/private-scrub.sh <session-id>` — with `~` written out as the real home path when calling, so the command matches the pre-approved permission rule. One call, nothing bundled with it, nothing about the event on the command line. The session id is the name of the session's own scratchpad directory. The script finds the transcript named by that id, confirms the file claims that id internally, refuses to touch anything else (including when two files somehow share the id), deletes it, and prints `CLEAN` — or a plain `ERROR:` line. A project permission rule pre-approves exactly this script path, so the call runs without prompts; no broad delete permission exists anywhere.
2. **Close with one line: `Cleaned, done.`** Nothing more (wording locked 2026-08-12: the close carries the run's only new fact — the cleanup ran — plus one word of closure, and deposits nothing about the event in the record). The order is the privacy (2026-08-12): the step-9 report — which names the event in its link — has already gone out, so the cleanup erases it from the record while the user keeps it on screen; only this closing line lands in the record. Never send the link after the script. Within seconds of the delete the app writes back a small session card — a title, a one-line summary, the last thing typed — and that card usually names the event, because the app writes it from what the conversation was about. That is the routine outcome, documented once in the fine print below, and it is not news to report (2026-08-12: the old per-run residue paragraph made a working cleanup read as a failure, twice). Speak up only when something unexpected happens — the script printed `ERROR:`, or the delete was refused. Then say what happened plainly and stop.
3. **The one case that gets a question.** If the private run happened part-way through a longer working session, the cleanup erases that whole session's record, not only the private part. Say so and ask before running the script. This is the only place where the yes at the confirm isn't permission enough.

**Build-mode note, kept from 0.14.1:** when a *recorded* test needs to inspect what the session card carries, never name the event on a command line — the command is itself recorded in the file being searched. Put the terms in a scratch file outside the transcript folder, point the search at that file, and delete the scratch file after. Routine private runs skip this check entirely; it answers a question the fine print has already answered.

**The fine print — stated once here, never repeated on every run (plain-English rewrite 2026-08-12).** What private mode promises: nothing about the run is written into this project's files, and that part is kept completely. The conversation's record on this Mac is deleted at the end, and that part is kept whenever the run finishes normally — a run that crashes or gets cut off never reaches the cleanup, and its record stays on this Mac until you delete that session. What no cleanup can reach, ever: the app rewrites a small card for every session (a title, a one-line summary, the last thing typed) and that card usually names the event; the Mac's own backups may hold copies made before the cleanup ran; and Anthropic's servers processed the conversation like any chat, under their retention policy. Deleting here doesn't delete there — the same way deleting a text from a phone doesn't delete it from the carrier. And the cleanup erases only what came before it: the closing line and anything typed afterward are recorded like any conversation, which is why the run's report goes out ahead of the cleanup and nothing after it names the event. The calendar entry is the one record a private run keeps. Any later session that reads those dates sees it, and that session's record on this Mac holds its title and body. A session you did not call private is recorded like any other, even when it is about a private entry.

## Confirmed entries (2026-11-01, widened 2026-11-08)

A hold exists so the user can decide later. A Confirmed entry means they decided. **An entry is Confirmed when the user says so, or when the input is proof of purchase (2026-11-08).** Many events have no ticket or confirmation to show, so the user's word is enough. "I'm going", "we're going" and "change it to Confirmed" confirm an entry with no ticket. "I got tickets" confirms it with one.

**What counts as proof of purchase:** an order or confirmation number, an "Order Confirmation" heading, a receipt, or a ticket with a QR code or a seat. An event page or flyer with a Tickets button offers a purchase, so it still files as a hold unless the user says they are going. When the input reads both ways, ask one question before the confirm: `Do you have tickets for this? (yes / no)`.

**What changes:**

- **The title.** `📌 Confirmed: [event title]` with no ticket, and `📌 🎟 Confirmed: [event title]` with one. `Confirmed:` takes the place of `Hold:`. This is the one exception to step 8's rule that every hold says `📌 Hold:`. The pin stays, so everything the skill files still lines up in a month view. The 🎟 goes after the pin, and it means only that a ticket exists: proof of purchase, or the user's word that they have one. Later proof adds it. It changes no color and no Free or Busy. A private run reads `📌 🤫 Confirmed: [event title]` or `📌 🤫 🎟 Confirmed: [event title]`, in that order: pin, 🤫, 🎟, word, name.
- **Busy.** `availability` is `AVAILABILITY_BUSY`. A hold stays Free so a placeholder never makes the user look booked. A Confirmed entry means the user is going.
- **The color (v0.27.0).** The color of the user's regular appointments, or red when the title carries 🤫, ticket or not. Step 8's `colorId` field holds the values.
- **The order number (v0.22.0).** It sits on its own line right under Venue, labeled the way the receipt labels it: `Order Number: 12345678`, `Confirmation #: 12345678`. The user needs it at the door, and searching email for it there is slow. It is the one personal detail a confirmed entry carries. The user's name, the ticket count, and the payment stay out, as on every hold. When the input shows no number, the receipt from email can supply it (v0.23.0). Otherwise the line is left out.
- **No availability check with a ticket.** Step 5's sold-out and waitlist checks are skipped, because the user already has a ticket. With no ticket the checks still run, and what they find goes in the body. The title of a Confirmed entry never carries SOLD OUT or WAITLIST ONLY, ticket or not, because the user is going.
- **The confirm and the report.** The step-7 Title line shows the confirmed title, and a `Show as: Busy` line follows the Calendar line. The step-9 report opens `Filed:` instead of `HOLD filed:`.
- **The body with no ticket (2026-11-08).** It is the Hold body, action line included, because a user who is going may still need to buy. Ticket lines replace the action line when a ticket arrives (see "Add to Confirmed" in "Actions on a found entry").

**The receipt from email (v0.23.0).** When the input is proof of purchase, ask one question before the confirm: `Search your email for the order confirmation? (yes / no)`. Never search without a yes. The question asks even on the URL path that skips the confirm. Words that say only that the user is going ask nothing about email and search nothing (2026-11-08). One exception (2026-11-02): the user's own question or claim about tickets counts as the yes for one search. "Did I get tickets?", "I think I got tickets", "I got tickets" and "Where are my tickets?" all count. On a yes, search for the matching receipt (the seller or venue, the event title, and the order number when known) and read only that message. From it take:

1. The order number, when the input didn't show it.
2. Each ticket link the receipt gives ("View tickets", "Add to Wallet", "Download tickets"), labeled the way the email labels it. A receipt with one link per ticket gets one line per link.
3. A link to the receipt email itself, labeled `Order email:`. Remove the account part from the link (an `authuser=` value or an address), so a forwarded entry doesn't carry the user's address. Only the user can open it, since it needs their login. It is the way back to tickets that come only as a PDF attachment.

These lines go under the order number, in that order. Some ticket links open without a login, so anyone who receives a forwarded entry may be able to open the tickets.

Receipts often arrive after the screenshot. When the receipt isn't there yet, file without these lines and add one line to the report: `The receipt isn't in your email yet. Say "check again" to add the ticket links.` On "check again", search again and add the lines to the existing entry: that is Add to Confirmed (see "Actions on a found entry").

**No action line with a ticket (2026-11-02, narrowed 2026-11-08).** A Confirmed entry with a ticket carries no action line with a price and status. The ticket lines take its place (see "The two states").

**What stays the same:** verification, the exact-copy Details block, the end-time ladder, the guest check (apart from the order-number, ticket-link, and Order email lines), Private visibility, and no attendees. The ticket and the event page are both sources. When they agree, the entry earns ✓ against the page as usual.

The run that set it: a BAM order confirmation for a screening that night. It filed as `📌 Hold:` and Free, and the user set the rule. A two-page ticket PDF in August first raised the question. The user widened the rule on 2026-11-08: an entry is Confirmed when they say it is, with or without proof, because many events have no proof to give.

## The lookup: is it already on the calendar? (2026-11-02)

Before any create, look for an entry that already covers the event. Matching is plain comparison, with no judgment call, so it gives the same answer every time.

**When it runs.** On every filing, at the end of step 3, after any past-date question. When step 5 changes the date or the place, run it again before the confirm. When there is no Event Holds calendar, skip it.

**Where it looks.** Event Holds only. Every entry there counts, whatever its title says. Call `list_events` on Event Holds from the day before the input's date to the day after, then apply the four steps.

**What it reads from the input.** The date. The start time, when there is one. The place: a street address, or the venue name when no address is known yet. The event name.

**The four steps.**

1. **Same day.** Keep the entries that start on the input's date, in the venue's timezone. All-day entries count. The connector returns an all-day entry's date as midnight UTC. Read that date as written: converting it to the venue's timezone puts it on the day before.
2. **Same place.** Cut each address down to the street number and street name. Lowercase it, drop punctuation, and write street words one way: Street becomes St, Avenue becomes Ave, South becomes S. Drop the venue name in front and the city, state, ZIP and country behind. The two must match. When the input has no address yet, its venue name must appear in the entry's location or title.
3. **Same name.** Cut each name down to its words. Drop the skill's own markers (📌, 🤫, 🎟, `Hold:`, `Confirmed:`, and SOLD OUT or WAITLIST ONLY with the dash after it), other emoji, punctuation, small words (a, an, the, at, and, with, in, of), and the words of the venue's name. The names match when every word of the shorter name is in the longer one. A shared link never counts as a match: a series page links every film in the series.
4. **Same showtime.** Compare the start times.
   - Within 2 hours: this is the entry.
   - More than 2 hours apart: a different showtime. The input becomes a new entry.
   - Two entries equally near: ask.
   - No start on one side, as on an all-day entry or a receipt with no time: this is the entry when only one is left. When more than one is left, ask.

**One more case asks.** An entry that fails step 3, but shares the day and the place and starts within 2 hours, may be the same event under a new name. A page that renamed its event between two filings lands here. Ask before filing a second entry.

**Three answers.**

- **Found:** one entry. What it does next is below.
- **Not found:** the run goes on to the confirm and files a new entry.
- **Ask:** one question that lists the entries that came close, with a new entry as the last choice. A pick of an entry counts as Found. A new entry lets the run go on.

```
This may already be on your calendar:
1. 📌 Hold: THE CURSE OF HER FLESH (Spectacle Theater) (Oct 23, 10 PM)
2. A new entry
Which one?
```

**Reading an entry's state.** An entry is Confirmed when its title carries "confirmed", 🎟 or "tickets", in any letter case. Every other entry is a Hold.

**What a found entry does.** A found entry stops the create. Never file a second entry beside it, and skip the confirm block.

- **Already held:** the input is an event, and the entry is a Hold. The report opens `Already held:` (step 9). When the input gives a different start or end, the report says so and asks one question, with the real values: `The page now says 8 AM. The hold says 9 AM. Update the hold? (yes / no)`. Name the source the way it is: the page, the flyer, the screenshot. On a yes, change only the start and the end with `update_event`, notifications off, and give the footer the new check date. News the new read turns up, such as SOLD OUT, goes in the report and not in the entry.
- **Already confirmed:** the input is an event or the user's word that they are going, and the entry is Confirmed. The report opens `Already confirmed:`. Nothing changes.
- **Proof of purchase or the user's word for a held showtime:** Hold to Confirmed (see "Actions on a found entry").
- **Proof of purchase or "I got tickets" for a Confirmed entry:** Add to Confirmed (see "Actions on a found entry").

**Private entries.** A 🤫 entry counts like any other. On a run that is not private, never write its title: the report and the ask list call it `a private entry on [Mon D]`, with its link.

**What it never does.** It reads Event Holds and no other calendar. What it finds goes into chat and into the next step, never into a body. The lookup changes nothing by itself: only the actions below change an entry, and only the found one.

## The two states (2026-11-02)

Every entry the skill files has one state, and the title word carries it. The title is what the user scans, so the title is the record. Free or Busy, the color and the body follow from the title.

| | Hold | Confirmed |
|---|---|---|
| Means | The user might go. | The user is going to this showtime, ticket or not. |
| Title | `📌 Hold: [name]` | `📌 Confirmed: [name]`, or `📌 🎟 Confirmed: [name]` with a ticket |
| The body is for | Deciding | Attending. With no ticket, the Hold body stays. |
| Leads with | The event's own words | With a ticket, the Venue line, then the lines that get the user in the door |
| Buying | The action link, with its dated price and availability | With a ticket, none: the ticket lines take its place. With no ticket, the action link stays. |

**What the title decides (2026-11-08).** This is the whole rule for Free or Busy and the color. Step 8's `colorId` field holds the values.

| The title starts | Shows as | Color |
|---|---|---|
| `📌 Hold:` or `📌 🤫 Hold:` | Free | The calendar's own color. The entry sets none. |
| `📌 Confirmed:` or `📌 🎟 Confirmed:` | Busy | The color of the user's regular appointments |
| `📌 🤫 Confirmed:` or `📌 🤫 🎟 Confirmed:` | Busy | Red (Tomato) |

- **The 🎟 marks a place the user holds:** a ticket, a reservation or a confirmed RSVP, free ones included. It changes nothing else: no color, and no Free or Busy.
- **A private run** adds 🤫 after the pin in both states. Private means 🤫 in the title. Only the Confirmed state also changes color: a private Hold keeps the calendar's color, and a private Confirmed entry is red.
- **Both states keep** Details, Source, the dated footer and the calendar's default reminders.
- **Set Free or Busy and the color only when filing an entry or changing its state.** A hold the user marked Busy or colored by hand stays the way they left it until its state changes.
- **A ticket drops the lines written for deciding:** the action line with its price and status, and any 🎟 availability line. Details and Source stay, so a guest who wants a ticket is one tap from the event page. A Confirmed entry with no ticket keeps them, because the user may still need to buy.
- **The title has one slot for news,** between the state word and the name, with a dash after it. Holds use it for SOLD OUT and WAITLIST ONLY, which never apply to a Confirmed entry. The body's top line, above Venue, is the news line in both states.
- **Travel time stays out of both states,** and no action adds it. When the user asks for travel time on a run, add it to that entry only.

## Actions on a found entry (2026-11-02)

The lookup runs first. What it found and what the input is decide the action.

| Action | The input | The lookup found |
|---|---|---|
| Nothing to Hold | An event | Nothing |
| Nothing to Confirmed | Proof of purchase, or the user's word | Nothing |
| Already held | An event | A Hold |
| Hold to Confirmed | Proof of purchase, or the user's word | A Hold |
| Add to Confirmed | Proof of purchase, "I got tickets", or "check again" | A Confirmed entry |
| Already confirmed | An event, or the user's word that they are going | A Confirmed entry |
| Remove | The user's word | Either state |

**Four rules for every action.**

1. **One entry.** Change the found entry with `update_event`. Never file a second entry beside it.
2. **The body ends in its state's shape** (see "The two states"). An action on an older entry also clears what its state drops.
3. **Free or Busy and the color change only when the state changes.** Already held, Add to Confirmed, Already confirmed and Remove never set them, even on an older entry whose color does not match its state.
4. **Notifications stay off** (`notificationLevel: NONE`). Guests see the change when they open the entry.

Each action reports the way step 9 does: one line that links the entry, plus one line for each thing that changed. Busy and the color come with `Changed to Confirmed:` and get no line of their own.

**Nothing to Hold and Nothing to Confirmed** run the workflow as written. After Nothing to Confirmed, ask about the other showtimes (below).

**Already held and Already confirmed** are in "The lookup".

**Hold to Confirmed.** The user says they are going, or proof of purchase arrives for a held showtime. It happens on the word or the proof, and the report says what changed.

- **The user's word is enough (2026-11-08).** "I'm going" and "change it to Confirmed" change the entry at once, with no email search and no question. "I got tickets" changes it too. Those words count as the yes for one email search (see "Starting from words"). When no receipt turns up, the entry still changes, with the 🎟, and the report adds one line: `No receipt found.`
- **A hedge or a question is not the user's word.** "I think I got tickets" and "Did I get tickets?" search the same way. When no receipt turns up, ask once: `No receipt found for IN THE WOODS. Change it to Confirmed anyway? (yes / no)`. A yes covers tickets that live in an app or on someone else's account, so the title takes the 🎟. A no changes nothing.
- **Before a change on proof,** ask the receipt question from "Confirmed entries": `Search your email for the order confirmation? (yes / no)`. Skip it when the user's words about tickets already count as the yes.
- **The title:** `Hold:` becomes `Confirmed:` after the pin, or `🎟 Confirmed:` with a ticket. A SOLD OUT or WAITLIST ONLY marker drops. The 🤫 and the name stay. A private run adds the 🤫 when the title lacks it, which makes the entry red.
- **Free becomes Busy.**
- **The color changes** to the Confirmed color, or to red when the finished title carries 🤫, whatever confirmed the entry: proof, or the user's word. This replaces a color set by hand. Step 8's `colorId` field holds the values.
- **With a ticket, the body loses** the top availability line, the action line with its price and status, and any 🎟 availability caution.
- **With a ticket, the body gains** the order number, the ticket links and the order email, under Venue. They come from the proof, and from the receipt after a yes.
- **With no ticket, the body stays as it is.** The change sets only the title, Busy and the color.
- **The start** takes the proof's time when the two differ, and the report says so. The end changes only when the proof prints an end or a runtime, by the end-time ladder in step 3.
- **Everything else stays:** Details and the blocks under it, the ⏰ cautions, the ⏱ caution, Source, and the dated footer.
- **When the entry has a guest,** the report says what the guest now sees: the new title and the booking lines. Some ticket links open without a login.

**The other showtimes.** After Hold to Confirmed or Nothing to Confirmed, look for the other holds of the same run: every entry on Event Holds in the next 90 days that passes steps 2 and 3 of the lookup, other than this one. List Holds only, since a user can have tickets to two showtimes. When there are any, one question follows the report:

```
You also have holds for IN THE WOODS on Oct 12 and Oct 28. Delete them or leave them? (delete / leave)
```

Delete removes every hold listed with `delete_event`, notifications off. Leave changes nothing. When a hold has a guest, the question says so, because deleting it takes it off the guest's calendar too.

**Add to Confirmed.** Later proof for an entry that is already Confirmed: the receipt email arriving after the screenshot, a wallet link, "check again", or "I got tickets". Add the 🎟 when the title lacks it. The 🤫 and the name stay. Add the booking lines the entry lacks, and repeat none it has. Clear any hold text, by rule 2. Busy and the color stay as they are. When the receipt adds no line, the report says the entry already has what the receipt gives. When "I got tickets" finds no receipt, add the 🎟 alone and report `No receipt found.`

**Remove.** The user's words: "I'm not going to that show", "I sold my tickets", "delete that hold". Find the entry the words name on Event Holds. When more than one could be it, ask which. Then name the entry and ask first, saying so when it is Confirmed or has a guest: `Delete 📌 Hold: THE CURSE OF HER FLESH (Spectacle Theater) on Oct 23? (yes / no)`. Never delete without that yes. On a yes, delete it with `delete_event`, notifications off.

## Starting from words (2026-11-02)

Words alone carry no image to transcribe, and often too little for the lookup. Work with what they give, in this order:

1. **A date:** list Event Holds on that date and on the day either side, since a remembered date can be off by a day.
2. **No date, but a name or a venue:** search the Event Holds entries from today on for it.
3. **Neither:** ask one question: `Which event?`

The same three steps find the entry for Remove.

**When the words say only that the user is going,** search nothing. Find the entry and run Hold to Confirmed. When more than one candidate is left, ask which one. When nothing is there, the run files a new entry: Nothing to Confirmed.

**When the words are about tickets,** search email for a receipt. The words count as the yes (see "Confirmed entries"). Search on each candidate's name and venue, and read only the messages whose sender or subject marks them as a receipt, such as "Your tickets" or "Order confirmation". A release notice or a forwarded copy is not the receipt. Then say what was found in one message:

- **A receipt matches one candidate** on name, venue and date: that receipt picks the entry. A Hold changes to Confirmed, and a Confirmed entry gets Add to Confirmed. The report links the entry.
- **No receipt turns up:** when more than one candidate is left, ask which one. Then a plain claim ("I got tickets") changes the entry and reports `No receipt found.`, and a hedge or a question ("I think I got tickets") asks the fallback question from Hold to Confirmed.

For example, "I think I got tickets for a concert on the 7th" lists Event Holds from the 6th to the 8th. "Concert" matches no title, so every entry there stays a candidate. The email search finds one receipt that matches one entry on name, venue and date, and that entry changes to Confirmed. Without the receipt, the skill lists the candidates and asks which one.

**What asks first.**

- Remove, and deleting the other showtimes.
- The lookup's ask answer.
- Updating a held entry's times.
- Hold to Confirmed when a hedge or a question about tickets finds no receipt.
- Any email search the user's own words did not ask for.

**What happens, and is reported after.**

- Hold to Confirmed on proof or on the user's word.
- Add to Confirmed.
- Already held and Already confirmed, which change nothing.

New entries keep step 7's confirm rules.

## The workflow

Follow these nine steps in order. One question at a time. Never batch questions to the user.

### Step 1: Transcribe everything in the image

Read every piece of visible text in the image — title, dates, times, host names, speaker names, location, URL, handle, caption, hashtag, fine print. Don't summarize. Capture it raw.

Real-world photos (as opposed to screenshots) come with glare, angles, torn corners, and stickers over the text. Transcribe what's legible and mark unreadable spots as `[illegible]` — don't fill gaps with guesses. A guessed date on the calendar is worse than a flagged one.

**The event only — ignore the rest of the frame.** A photo's frame almost always holds more than the event: a flyer on a pole among tear-off tabs and stickers, a billboard over a street, a poster in a subway car, a program lying on a desk. The setting doesn't matter and neither does the count of unrelated things (3–20 is common). Once it's clear which thing in the photograph IS the event, transcribe that and nothing else. Everything else in the frame goes nowhere: not the transcription shown in chat, not the invite, not even as "[unrelated, ignored]" footnotes. It's token clutter and brain clutter (2026-07-05, Dom Dolla pole-poster test; generalized same day: the rule is about the frame, not poles).

Comments are frame clutter too (2026-08-07). Only the posting account is accountable for the event details, so the caption and that account's own replies are the source. Everyone else's comments, questions, and likes are editorial and go nowhere — not the transcription, not the invite.

**One flyer can carry more than one event (2026-07-21, C86'd street poster: two shows, two venues, two dates on one sheet).** This is the opposite of frame clutter: multiple events printed on the SAME flyer are all real. Be true to the flyer — transcribe the whole flyer once, then ask the user which event(s) to file (one question). Each chosen event becomes its own HOLD with its own confirm, verification, and links; the shared transcription rides in every one.

A corroborating signal inside the image can confirm an inferred field — e.g. a countdown timer ("1 week 6 days until the event") confirming that a year-less date is this year. Use it silently; it's a check, not content for the invite.

Show the user the full transcription before doing anything else. The one thing that goes above it is step 3's past-date question, when a date has already passed. Format:

```
Transcription:
[every line of text from the image, in roughly the order it appears]
```

**URL input: read the page, don't transcribe (2026-07-28, Test 16; browser-first since 2026-08-07).** For a URL, step 1 is one browser read of the page, captured verbatim — the page text plays the transcription's role everywhere downstream. Three rules: (1) Read it in the browser, not a fetcher. The Details block needs the venue's own sentences and a summarizer cannot promise them; asking harder is not a fix (step 5). (2) The frame rule applies to pages too: capture the event's own content, not site chrome, navigation, or other events listed on the page. (3) Skip the transcription display — the user sent the page, they can open it — and the body carries no transcription block; the Source link replaces it.

**PDF input (2026-11-02).** Read the text layer first, then render the pages for what it misses, such as a QR code or text set as an image. Several pages are several tickets to one event, unless the pages name different events. Show the transcription as for an image.

**Email input (2026-11-02).** Read the email the user names or forwards. Its text plays the transcription's role, and the run goes on as for an image. Skip the transcription display, since the user has the email.

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
  This is still being tuned — watch how real events read across types and adjust. The `📌 Hold: ` prefix is added at step 8, not here — and so is private mode's 🤫.

  **Source orthography (2026-07-21).** Quoted blocks are always character-for-character from the image. In the title, keep each name's own spelling exactly — accents, internal caps, spacing ("C86'd", "weonlyspokeinellipses", "Vol.21" with no space) — even when an online source "corrects" it; on a spelling conflict the primary source wins. Display styling is not spelling: a poster that caps EVERYTHING carries no information about how a name is written — take letter-case from a source where the name appears in running text (a ticket page's lineup, the venue's calendar).
- **Date** — convert to YYYY-MM-DD. If the year is missing (common on Instagram and event flyers — the post date is the context clue), assume the current year. Don't stop to ask. Only flag the date if it's also cropped, garbled, or self-contradictory — a bare missing year is not a low-confidence flag

  **No date anywhere: the image announces, the page schedules (2026-08-05, Test 17, Spectacle's August lineup post).** A missing *year* is the common case above. A missing *date entirely* is a different shape and it has its own path. Lineup posts, season announcements, and "here's what's playing this month" carousels name the titles, the directors, the runtimes, and nothing else — the schedule lives on the venue's site, and the poster's job was only to say *these are the things*. Don't stop, don't guess a date, and don't file an all-day banner on a guessed day (the all-day path in the next bullet is for a real date with no time — it does not cover a missing date). Instead, split the roles: **the image supplies identity, the venue's page supplies the calendar.** Take titles, credits, runtimes, and the caption from the image; take the dates and times from the schedule or series page found in step 4.

  Verification still means something on this path, and the badge is earned the normal way: the identity fields have to match across the two sources. When the image's titles, directors, years, and runtimes all line up with the page's, that is real corroboration and the hold is ✓ Verified — the page simply also happens to be the only source for the dates. Say so in the footer rather than letting the badge imply the dates were cross-checked: `✓ Verified against [URL] on [date] — the screenshot announced the lineup with no dates; the [page] supplied the schedule.` If the identity fields *don't* match, the page is about something else — keep looking or file Unverified, same as always.

  Two stopping rules. If no schedule page can be found, there is nothing to file: an announcement with no recoverable date is not an event, so say that plainly and stop rather than inventing a placeholder day. And when the page lists several showtimes per title, this is the multi-event case from step 1 — transcribe once, show the grid, and ask in one question which showtimes to hold. Each chosen showtime becomes its own HOLD with the shared transcription, exactly like two-events-on-one-flyer.
- **Start time** and **end time** — 24-hour. A "midnight" screening belongs to the calendar day printed on the flyer. File it at `23:59` on the listed date — that keeps the event on the day the flyer names and in the real late-night slot, instead of jumping to `00:00` the following morning. (For Spectacle, "FRIDAY, MAY 29 – MIDNIGHT" → start `2026-05-29 23:59`. The end time can roll past midnight; a 60-min film ends `2026-05-30 00:59`.) **A printed 12:00 AM (2026-11-03).** A ticket, a receipt or a page that prints 12:00 AM on a date means the end of the night before: Saturday 12:00 AM is late Friday night. File it at `23:59` on the day before, the same slot as a flyer's MIDNIGHT. The entry then lands on the night the user goes out, and the lookup finds a hold filed from the flyer. **Try the page before falling back.** When the image is missing a start or end time, don't jump straight to a default — step 5 reads the event page, so pull the real time from there if a verifiable page exists. Precedence for every time field: image → else verified page → else the fallbacks below. Only use a fallback when neither the image nor a page supplies the value.

**Missing end time — the hold is a convention, not a prediction (2026-07-20; revised 2026-07-21 after a 7 PM–4 AM block over-claimed a bar-venue show: the venue's close answers "when does the building shut," not "when does the show end").** When the image and the event page give a start but no end, work down this list and stop at the first hit. Every derived end time carries a labeled, dated line in the body.

1. A close time published for **this exact event** (rare). Use it as-is.
2. A **published running time for this exact event** — a film's minutes, listed lengths of the program's parts (2026-07-28, Test 16: three Film Forum screenings). End = start + the listed runtimes summed (feature + accompanying short/doc). Label: `⏱ End derived from the listed approx. [N]-min runtime — no allowance for trailers or an intro; may run later (checked [M/D])`. This stays on the right side of rung 4's no-formula ban because runtime is a per-event published fact, not world-knowledge — the source printed the number; nothing was inferred from event type. An announced live intro/Q&A with no listed length stays a caution ("may push the end later"), never a number.
3. The **venue's posted hours** for that day — but ONLY when doors sit within ~5 hours of close, i.e. the event plausibly IS the venue's whole night (an 11 PM club program running to the 4 AM close). One search — hours routinely appear in snippets. Label: `⏱ Ends at venue's [day] close ([time], checked [M/D]) — no end time listed for this event`. When doors are further from close, the close time is context, not the end — it moves into the caution line and the block does not stretch to it.
4. Otherwise: a **fixed 2-hour block. Always.** Never scale it — not by start time, not by act count, not by event type. Any formula that converts flyer content into a duration smuggles in world-knowledge (how long sets, readings, or signings run — the flyer can't say), and a placeholder that varies "intelligently" starts to look like information, which readers will trust. A uniform convention is honest because it carries no false signal: the user learns once that a 2-hour block with a ⏱ line means "end unknown." The caution line declares the convention and carries the real signals as facts, never converted into a number: `⏱ End unknown — the 2-hour block is a placeholder, not a prediction; venue open till [time] [day] (checked [M/D])` (or `; venue posts no regular hours`).

The block should under-claim; the caution line carries the uncertainty and any known upper bound. An end that's modestly wrong-short beats one dramatically wrong-long — the user can stay later than the block, but a block that colonizes the whole evening misleads planning at a glance. Never hardcode an end from event-type knowledge ("clubs run till 3") — venues vary by night and lineup, and that's model knowledge, not a source.

If the source gives **no time at all — only a date**, don't invent a start time. File the HOLD as an **all-day** event: the thin bar across the top of the day, not a block that reserves 9-to-5 or any other span. Use the connector's `allDay: true`. Add a prominent line in the body — `⏰ No starting time found — filed as all-day banner` — so the user knows why it's a banner and that the time is the thing to look up on click-through. (Timezone doesn't apply to an all-day event, so the venue-TZ logic can be skipped in this case.)
- **Timezone** — if the image prints an explicit timezone (an IANA name like "America / New_York" or an abbreviation like EST), **trust it verbatim, even when it doesn't match the venue's city** — event platforms localize displayed times to the viewer, so the printed time+zone pair is already correct as a moment in time. Don't "fix" it to venue-local; that shifts the actual hour. (Learned 2026-07-04: a Chicago event displayed as "3:00 PM – 6:00 PM · America / New_York" — the platform had done the conversion; filing it as 3 PM Chicago would have been an hour off.) Only when NO timezone is printed: for a physical event, derive it from the venue's address (Brooklyn → `America/New_York`, San Francisco → `America/Los_Angeles`). That derivation is deterministic — never mark TZ `unknown` when there's an address. The time printed on the flyer is venue-local; store it in the venue's zone and Google Calendar auto-displays it in whatever zone the user is in. If the venue address isn't resolved yet at this step, leave TZ blank and let step 5 fill it once the address is known. Virtual events and the no-address fallback are handled in step 5
- **Host / speakers** — only people actually appearing **at the event**: the host, an MC, an intro speaker, a Q&A guest, a panel. Names with titles if shown. Do NOT list people who are merely subjects *within the content* — actors in a film, interviewees in a documentary, authors of a book being discussed. Those belong in the synopsis, not as event speakers. (For a CYBERPUNK screening, William Gibson and Timothy Leary are interviewed *in* the 1990 film; they are not speaking at the theater. Some screenings do add a live intro or Q&A speaker — capture that person here if the flyer names one.) If no one is named as appearing live, leave this empty.

  **Lineups: no assumptions about order or type (2026-07-20).** The order of names on a flyer means nothing — who opens, who headlines, and who plays when is in flux at venues of every size, especially with DJs. Never infer set order or billing from layout unless the promoter publishes a roster with start times for this exact event (rare, and even then often not firm). Same for what the names *are*: "artists" is the generic label — a name on a club flyer could be a DJ, a band, or someone on a sequencer. Use a specific word (DJ, band, live PA, singer, performer) only when the image or a checked page prints it — e.g. "LIVE" next to a name.
- **Location** — physical address if given. If the image names a venue or host but no street address (common on Instagram screenshots), recover the venue's full street address during step 5 (same web search) and use it. A full address lets Google Calendar geocode the event for maps and travel time. Only use "Virtual" when the event truly has no physical venue
- **Source platform** — Instagram, X, email, web, photo (infer from screenshot UI)

If a key field looks ambiguous in the image — date is half-cropped, two times conflict, year is missing, text is garbled — flag it inline before the confirm step. Format:

```
⚠ Low-confidence field: [field name]
  In the image: "[what was visible]"
  My best guess: [guess]
  Want to fix this before I continue?
```

Wait for the user's reply before moving on.

**Past dates: ask first, and ask alone (2026-09-23).** A date in the past is not an error. Old flyers file the same as upcoming ones, and the skill never moralizes or refuses. But a past date decides whether the rest of the run is worth doing, so it is the first thing the user reads. As soon as the dates resolve and any of them falls before today, stop and ask one question. Nothing else comes first: no confirm block, no invite description, no more searching or page reading. On image input the question leads the message and the transcription follows below it. Name what is past and when:

- One date: `Heads up: [event title] was on [Mon D], before today. Still want the hold? (yes / no)`
- Every date: `Heads up: every date for [event title] was before today. The last was [Mon D]. Still want holds? (yes / no)`
- Some dates: `Heads up: [N] of the [M] dates for [event title] were before today ([Mon D], [Mon D]). Hold those too, or only the upcoming ones?`

On no, stop. Nothing is filed and no confirm block follows. On yes, the run continues as normal, and the confirm does not repeat the heads-up. This rule runs on every path, including the URL path that skips the confirm. The run that set it: a series page where all four screenings of one film had already happened. The old rule put the question at the bottom of a 50-line confirm block, and it took two more rounds before the user saw that every date was past.

**Then run the lookup (2026-11-02).** See "The lookup". When it finds the entry, skip steps 4 to 8 and report at step 9. The time check compares what the input shows.

### Step 4: Find the official registration page

**URL input: most of steps 4–6 doesn't apply (2026-07-28, Test 16).** The user's URL IS the source page — no search, no ladder, no no-page-found state. Three rules cover what's left:

1. **If the page won't load** (the browser render fails, and a fetch fallback fails too), stop and tell the user — don't file. Unlike the image flow there's no fallback data; a hold needs at least one readable source.
2. **What still runs from step 5:** read the page for everything the body needs, not just ticketing — don't assume the URL is a ticketed event with perfect information (2026-07-28, the protest-march counterexample: free, unticketed, no lineup — the organizer's own site and handles are the best links on the page). Recover the street address or meeting point and timezone; per step 8's principle, every reference the page prints becomes a live link — organizer site, handles, venue, FAQ. Label the action link by what the page actually asks (Tickets / RSVP / Register / plain "More info" — never invent a buy step for an unticketed event); when a more specific action URL exists than the one the user sent, it takes the action line and the user's URL stays as Source. Check availability whenever the page shows tickets or a guest limit (spots left, a waitlist, sold out), and quote a price only when the event is ticketed (2026-10-04: a free RSVP event can still be full). Quote both as printed.
3. **Multi-showtime pages.** A run of screenings or a series page often lists several dates/times. Exactly one showtime → file it. Several → one question: which one(s)? Each chosen showtime becomes its own HOLD (same shape as multi-event-flyer, 2026-07-21). If the user's message already named a date or time, use it — no question.

   **Linked dates count (2026-10-04).** When the page links another date of the same event on a page of its own (a second date, an added show, a date opened for the waitlist), read that page too and treat its date as one of the showtimes. Users miss these: the run that set this rule found the second date in the last line of the description, and the user did not know it existed. Ask which dates to hold even when the user sent only one of the pages. The hold for a linked date keeps the event's title and adds the page's own name for that date in parentheses, such as `(second date)`. Each hold's top line names the other dates and their status.

Everything from here to the end of step 6 is the image flow.

The image often names its own source — posters print URLs, ticket-site names, and Instagram handles. Check those before reaching for web search:

- If the transcription captured a **URL**, open it directly. If it loads and matches the event, that's the page — skip the search entirely.
- If it captured an **Instagram handle** (e.g. `@spectaclenyc`), search for that account's event page: handle + event title.

If the image gave no lead, or the printed lead is dead or unrelated, fall back to web search. Up to two attempts.

- First query: build from event title + host + date (e.g. `"AI Strategy Summit" Section School June 4 2026`)
- If the first query returns nothing useful, the second changes strategy, not just keywords (2026-07-22, AI Tinkerers test: two keyword-shuffles both surfaced only the host's homepage; the event page never appeared). Aim the second query at where event pages live: add a platform name (Luma, Eventbrite, Partiful, Resident Advisor, Dice) or the host's own event-URL pattern when the first search revealed one (a sibling event at `host.org/p/<slug>` means this event has a `/p/` page too — search for it, don't guess it). And when the host's site is already known but the event page isn't surfacing, skip the second search entirely: load the host's site in the browser (step 5's fallback) and find the event link on the page.

What counts as "useful": a result on the host's own domain, an Eventbrite/Luma/Hopin page run by the host, or a clearly official landing page. Skip aggregator pages, news articles about the event, or the host's homepage.

**Rank sources by how checkable they are.** A "verified" badge is only worth something if the source is public and machine-readable. Prefer, in order:

1. A per-event page on a structured, public, no-login platform — Eventbrite, Luma, Partiful, Resident Advisor, Dice, Songkick. These show date/time/location in a fixed shape and are the easiest to verify against.
2. The host's own per-event page.
3. The host's schedule or calendar page (including a PDF).
4. The host's homepage or social profile (Instagram, etc.).

The further down this list, the more likely the result lands at "unverified." Login-walled pages (Facebook events, most Instagram posts) never count as verification even when they're the source.

**A login wall means "can't verify," not "can't read" (2026-07-25, Brooklyn block party test).** A plain fetch of an Instagram post gets a login screen; a renderer often gets the real page. The in-app browser loaded a public post as a logged-out visitor and returned the organizer's full caption, the tagged accounts, and the organizer's own replies — which carried the price and seven artist handles the flyer never printed. So when the source is walled and the runtime can render a page, open it and read it. Everything it returns is enrichment: a walled source never earns the ✓ badge, and nothing load-bearing may rest on it — the hold has to be right without it. Logged-out rendering is inconsistent, so when the render returns a login screen, degrade and move on. Same shape as the render-first rule in step 5: the capability is optional, the hold is not.

**Venues without per-event pages.** Not every host publishes a page per event. Indie microcinemas, bookstores, and small music venues often run low-tech: a single monthly schedule, sometimes only a downloadable PDF calendar they remake each month. Bigger venues (theaters, ticketed concerts, author events) usually do have per-event pages — try for those first. When no per-event page exists, fall back to the venue's schedule or calendar page (including a PDF) and verify the date against it. Use that schedule URL as the embedded link — not a guessed per-event URL, and not the bare homepage if a real schedule page exists. If the event date is already past, the venue may have replaced that month's schedule with the current one; if so, the date can't be re-verified — note it and move on.

**The wrong-listing trap (2026-08-05, Tests 17 and 18).** The ranking above assumes a per-event page is about one event. Often it isn't, and the result is the worst output this skill can produce: right venue, right title, **wrong listing**, filed under a ✓ badge that sends the user out on the wrong night. Two shapes seen so far:

- **Stale.** A venue that replays its catalog — a repertory cinema, a theater in rep, a recurring club night — keeps one *evergreen* page per title, carrying whichever run was published to it last. Spectacle's SPLIT page still listed a February run and its SHEILA AND THE BRAINSTEM page a June one while both films were playing that August (Test 17). Six wrong dates, had they been filed.
- **Parallel.** One title can have two concurrent runs at the same venue, each with its own page and near-identical copy. The Angelika ran CAMP MIASMA on digital and on 35mm at once; the digital page carried different Q&A times and dropped the Thursday entirely, which was the only night the star appeared (Test 18). The synopsis, cast, venue, and even the "Filmmaker Q&As Opening Weekend" heading were identical on both.

**Three checks before you trust a page's dates.** Any one failing means you have a page about something else.

1. **Date window.** Do the page's dates fall in the period you're filing? Showtimes in a different month than the source image or the series listing mean the page is stale.
2. **Qualifier match.** Format and edition qualifiers are identity, not styling: 35mm, 70mm, IMAX, open captions, subtitled, dubbed, director's cut, restoration, anniversary, sing-along. When the image's title carries one and the page's doesn't, that is a different listing — not the same event written differently. This is the one exception to "titles vary" in the verification section below.
3. **Conflict shape.** One field off is a schedule change and the page wins. Several off at once, coherently, is a wrong page: Test 18 showed three Q&A times all different plus a missing date, which no real reschedule looks like.

A failed check costs you the dates, not the page. Evergreen content stays good — read the wrong page for synopsis, credits, and runtime, and take the schedule from the dated run or series page. At a repertory venue the dated run page outranks the undated per-title page even though the title page looks more specific.

**Finding the right page: enumerate the venue's index, never slugify.** Guessed slugs mostly 404 (`/the-scenic-route/` and `/surfer-teen-confronts-fear/` both did; the real one was `/surfer/`), and a guess that *does* resolve lands you on exactly the evergreen page this rule is about. Instead, load the venue's own listing page and read every event-detail link on it. Test 18's correct URL ended `-in-35mm` and sat directly beside the plain slug in the index — invisible to search, obvious in the list. A DOM query for the site's detail-URL pattern gets the whole list in one call.

If there's no per-event page and no findable schedule page, use the venue's homepage as the link. A homepage is better than no URL — it still gives the user a way back to the venue.

**Stack the rungs when the top one is missing.** Whenever the best link is NOT a per-event/tickets page, give the user two labeled links instead of one: the most specific page found (series page, schedule, organizer profile) AND the venue's main site (2026-07-04, Angelika test: series page + venue homepage). One link answers "what is this event," the other answers "how do I reach the venue." When the best link IS the event page, one link is enough. Spectacle is an unusually bare case; most venues (theaters, bookstores, live music) will have something more specific, so only fall to the homepage when the better options genuinely aren't there. When the link is just the homepage, mark the description as unverified.

Stop after two tries. Don't keep guessing.

### Step 5: Read the page and diff

If a registration URL was found, open it in the browser and read it there. Compare the page to the image transcription on these fields: title, date, start time, end time, timezone, location, speakers.

**Render first. The fetcher is the no-browser fallback, not the opening move (2026-08-07).** Versions through 0.14.1 fetched first and reached for the browser when the fetch failed. The exception list kept growing until it ate the rule. Four failure shapes, all seen in testing:

- **403 Forbidden** — the server sees a datacenter client and refuses. ra.co, AXS, Ticket Tailor, Dice, doNYC, and on 2026-08-07 an ordinary conference site with no obvious reason to block.
- **Login wall** — Instagram serves a sign-in screen to a fetcher; a renderer often gets the real post, caption and replies included (2026-07-25).
- **Site chrome only** — a JS-rendered venue site returns menu labels, a cookie notice, and a footer, with no event content (angelikafilmcenter.com, 2026-08-05). No prompt recovers text the fetcher never received.
- **Summarized or refused** — the worst one, because it returns HTTP 200. The fetcher paraphrases the venue's copy, or declines to reproduce it outright, citing copyright or a per-quote character cap (2026-07-28 and 2026-08-05; a decline twice, once capped at 125 characters).

That fourth shape is why the order flips instead of the exception list growing again. A 403 announces itself. A summary does not: it comes back fluent whether the model quoted carefully or smoothed over the one line that mattered, and nothing in the output says which. And since step 8 needs the Details block character-for-character, a browser read happens on every run that files a body. A fetch ahead of it changes nothing downstream and costs a round trip whether it succeeds or fails.

One render also does what no fetch could: it surfaces the venue's index of detail links, which only exists once the JS runs (step 4), and it returns full blurbs and complete showtime grids that three separate fetches had summarized, refused, or 404'd. It reads login-walled pages as a logged-out visitor too — step 4's login-wall rule governs what that's worth.

**No browser in the session? Then fetch, and expect the four shapes above.** Watch the content, not the status code: two tells that you were handed a summary are prose shorter and smoother than a venue would write, or a tool that talks about the text ("the description continues with…") instead of reproducing it. Never re-prompt a refusal — firmer wording sometimes fixes a paraphrase, never a decline. On a domain that has 403'd in two different runs, don't spend a second try: corroborate from the search listing itself, whose title carries event, venue, and date, use the listing URL as the link, and add a per-field caution for whatever the listing can't show, usually times.

**Without a renderer, don't fake it.** Fill Details with what you actually have verbatim — the credits block, the caption from the image, whatever short exact quote came back — and mark the gap in the body: `📄 Description shortened — the full text on the event page couldn't be copied exactly (checked [M/D]); the Source link has all of it.` A paraphrase presented as the venue's own words breaks the exact-copy rule silently, which is worse than a body that admits it's partial.

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

On any conflict, the page wins — **but only after it passes step 4's three checks** (date window, qualifier match, conflict shape). A page that fails one isn't a conflict to resolve, it's the wrong page. Otherwise use the page's value and don't ask the user to choose.

While you're here, recover the venue's full street address if the image only named a venue or host. The registration page usually lists it; if not, check the results already on screen from the step-4 search first — addresses routinely appear in listing snippets (Yelp, maps, venue directories). Only run a dedicated venue search when the address genuinely isn't already in hand (2026-07-07 speed rule). Carry the full address into the `location` field at step 8 so Google Calendar can geocode it.

**Gated addresses (2026-07-22, AI Tinkerers test).** Application-screened events publish the address only after approval — the page says so outright ("Address Info: Available after application approval"). That's a finding, not a failure: no search recovers a gated address, so don't burn queries on it. File `location` as the city (e.g. "New York, NY") and add a dated 📍 caution quoting the gate, so the user knows the address arrives with their approval.

**Always check ticket availability while reading the page** (2026-07-05, LIXIL sold-out test). Look for the signals: "sold out", "waitlist", "sales ended", "N tickets remaining". If one is present, carry it as a dated caution line — e.g. `🎟 Heads up: the page showed a "tickets have sold out" notice when checked (YYYY-MM-DD) — spots may still open up; the ticket page is the place to watch.` The date matters: availability moves, so the line records when it was true. If the page says nothing about availability, add nothing — silence isn't a finding. Skip this check on a confirmed entry with a ticket (2026-11-01): the user already has one. A Confirmed entry with no ticket keeps the check (2026-11-08).

**Sold out is a headline, not a footnote (2026-08-05, Test 18).** A sold-out event still gets a hold — it becomes an FYI rather than a plan — but the status goes where a reader hits it first, not in the caution block at the bottom. Two placements:

- The 🎟 line leads the body, its own line above Venue.
- The title carries it: `📌 Hold: SOLD OUT — [event title]`. The `📌 Hold:` prefix stays; SOLD OUT goes between it and the event name, never in place of it.

Ask once before filing: `This one is sold out. Still want the hold? (yes / no)`. A Confirmed entry with no ticket skips the question, because the user said they are going, and the top line still carries the status (2026-11-08). Waitlist-only gets the same treatment, with a fixed title word (2026-10-04): `📌 Hold: WAITLIST ONLY — [event title]`. For sales-ended, say what the page said rather than flattening every status to one word.

**When there is more than one date, the which-dates question carries the status and replaces the yes/no (2026-10-04).** One question, never two. The dates can come from one page or from linked pages (step 4, URL input, rule 3):

```
There are [N] dates, and [both / all / some] are waitlist only:
1. [Day Mon D, time] is the page you sent. [Status as the page printed it.]
2. [Day Mon D, time] is [the page's own name for it]. [Status as the page printed it.]
Do you want a hold on the original ([Mon D]), the [second date] ([Mon D]), or both?
```

Cancelled, postponed, and moved have no rule yet: surface them and ask (still an open question — "bad news found late").

If the page is unreachable or returns an error, treat this as no page found and proceed to step 6.

### Step 6: Handle no-page-found

If neither search attempt returned a usable URL, or if the page wouldn't load, continue to step 7 with no URL. The HOLD will get a "no source found" flag in the description. Don't ask whether to proceed — the locked decision is auto-skip after two tries.

### Verification status — three states (image input) or the nothing-added promise (URL input)

**URL input: a promise instead of a badge (2026-07-28, Test 16).** When the user hands over the event page itself, there's nothing to verify against — the page can't disagree with itself, and a ✓ badge would just be for show. The three states below apply to image input only. A URL-filed HOLD instead ends with a plain promise: everything in this body comes from the page, and nothing else. Footer: `<p><i>Filed from <a href="[URL]">[URL]</a> on [YYYY-MM-DD] — all facts from this page; nothing added.</i></p>` The risk on this path isn't misreading — pages are clean text — it's the model adding things: commentary, background knowledge, or the user's own life as "context" (the slip that earned this rule: a family-travel note added to a hold body as helpful context, caught by the user the same day). The promise has to actually hold: every fact comes from the page or a page it links (venue site, ticket page), quoted under the exact-copy rule. Anyone who opens the URL should be able to find every fact in the body; anything they can't find is a mistake, not a judgment call. The skill can't make additions impossible — it can make them easy to spot and against the rules. Per-field honesty still applies: when the page leaves out something the HOLD needs (usually the end time), the derived value is labeled and dated exactly as in the image flow.

**Image input — every HOLD lands in exactly one of these three states.** The body of the event records which.

- **✓ Verified** — found a public, no-login event page (see the source ranking in step 4) AND its date and time match the image. List the URL. On a conflict the page wins and it still counts as verified — against the page. Don't gate on the title matching; titles vary ("CYBERPUNK" vs "Cyberpunk (1990)"). **Except on a format or edition qualifier** — 35mm, IMAX, open captions, director's cut — which identifies the listing rather than describing it, and whose absence on the page means you have the wrong page (step 4's wrong-listing trap).
- **⚠ Unverified** — a link exists but it didn't confirm the facts: a venue homepage, a monthly schedule, or a login-walled page that can't be read. Always include the best available link — the next-highest rung on the step-4 ladder — because the link has two jobs and verification is only one of them. Even when it verifies nothing, it's the user's starting point for finding out more about the event, venue, or organizer (the Lost Arts test: the exact event page was members-only, but lostarts.xyz still gets them to the community). A HOLD with no link at all should only happen when the image and two searches produced literally nothing.
- **ℹ No verification page found** — neither search attempt returned anything usable. This is an FYI, not an error: the HOLD is still filed, it just carries the image data as-is. Word it gently — "Couldn't find a webpage to verify against — filed from screen shot as-is" — never like a failure.

Reserve "verified" for actual corroboration. A link existing is not verification — that's the whole point of the badge.

**Per-field honesty (2026-07-04).** Verification isn't all-or-nothing. When the page corroborates some fields (date, venue) but is silent on another (start time), the badge can still say Verified — but the un-corroborated field gets its own plain-language caution line in the body's caution block (after Details). Pattern: `⏰ Start/end times from [the only source] — couldn't be re-confirmed on [what was checked]. Double-check the time when you get tickets.` Silence on a field is not a conflict; it's a gap, and the body says so in words the user's future self will understand at a glance.

**One source, several holds: each earns its own state (2026-08-14, Casanara anniversary).** Verification is decided per HOLD, not per source. When one image or page yields more than one HOLD, check and badge each separately — a page that confirms one of them says nothing about the others. The run that set this: an Instagram post whose artwork advertised a block party and whose caption added an after party inside the bar the same night. The co-host's event page confirmed the block party, so that HOLD filed ✓ Verified; the after party appeared nowhere but the caption, so it filed ⚠ Unverified from the same screenshot. What this closes is the pull toward stamping one good source across every hold split from it, which is the exact claim the three states exist to prevent.

### Step 7: Single confirm before create

Show one summary block and ask one yes/no question. **The block includes the full invite body, labeled `Description:` (Google Calendar's own name for the field), rendered as it will read in the calendar** — links, caution lines, labeled blocks, verification footer. Never a header-only confirm: the user inspects the body before saying yes (2026-07-05).

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

On a private run the Title line shows the title that will actually be filed, 🤫 included: `Title:       📌 🤫 Hold: [event title]`. Same rule as every other field in the block — real values, never the template. And the closing question becomes `Save the event and delete the record of this session? (yes / no / fix)` — one yes covers the filing and the cleanup (2026-08-12; full spec in the private-mode section).

On a confirmed entry the Title line shows the Confirmed title as it will be filed, with or without 🎟, and `Show as:     Busy` follows the Calendar line (2026-11-01; full spec in "Confirmed entries"). The block names no color, because the title decides it (2026-11-08).

**URL input: skip the confirm when the ask already answered it (2026-07-28, Test 16).** All three conditions, or the confirm shows as written: (1) URL input; (2) the user's message clearly says to file it ("put a hold for this on my calendar"), not a hedged ask ("what do you think about this event?"); (3) exactly one showtime resolved, no low-confidence field, no question pending. Then file directly and report — the ask was the yes, and re-asking it is friction (Test 16 filed three holds this way; the user corrected after via the report, which worked). The guest check (step 8) still runs — it doesn't depend on a human looking. The past-date question from step 3 still asks even on this path: a past date on a series page is likelier a surprise than a choice. A filing on this path takes the same Free or Busy and the same color as any other, so a Hold sets no `colorId`.

**Past dates were settled at step 3.** By the time the confirm is built, the user has already said yes to any past date. The confirm does not raise it again.

**So was the lookup (2026-11-02).** By the time the confirm is built, no entry on Event Holds covers the event, or the user picked a new entry.

### Step 8: Create the calendar event

**Sourcing rule for everything in the invite (2026-07-05):** every fact traces to the image or a page checked during this run. Never add background knowledge — genre labels, artist facts, venue lore — no matter how confident. If it isn't in a source the user can open, it doesn't go in. (The cut that set the rule: "house/dance" as a genre gloss on a Dom Dolla show — true, but sourced from the model, not the flyer or pages.) Synthesis lines like Topic re-say the sources' own words, nothing more. The only exception: resolving a named venue to its standard street address for geocoding — that's plumbing, not content.

**The user's life is not a source — and neither is their calendar (2026-07-28).** HOLDs get forwarded to friends; the body carries nothing about the user. No family, travel, health, or schedule context, and nothing read from the calendar (nearby events, past invites, who's in town) — even when it's why the hold exists. That belongs in the chat reply. Calendar read access is for filing mechanics (destination, timezone) and the lookup. What the lookup finds goes into chat, never into a body. (Set by a real cut: a family-visit note with flight details, sourced from a nearby calendar event.) One exception: a confirmed entry's order-number, ticket-link, and Order email lines (2026-11-01, see "Confirmed entries").

**Guest check — always the last step before creating the event, even on runs that skip the confirm (2026-07-28).** Reread the finished body as if you're a friend who just received the invite, and ask two things: is everything in it on the event's own page (or image)? Is any of it about the user? The answers must be **yes** and **no**, or the failing line gets deleted — not reworded. This is the same reread the user does before forwarding a hold to a friend. A confirmed entry's order-number, ticket-link, and Order email lines pass the check (2026-11-01).

**Every piece of text appears once (2026-10-05).** The body never carries the same text twice. Before writing it, decide which source leads Details:

1. **The event page leads** when it earned the ✓ (step 6) and its event text says everything the image says, or more. Details is the page's own text, copied word for word from the browser read and labeled with the page, such as `Details (from the Spectacle page):`. Leave out site chrome such as buttons, menus, and share links.
2. **Lines only the image has** go in an `Also in the [source]:` block right after Details, copied exactly. Omit the block when there are none.
3. **The image leads** in every other case: no page, a ⚠ Unverified page, or a page that says less than the image. Details is the image's text, as before. Anything the page adds goes in a `From the [page]:` block below, holding only the lines the body doesn't already carry.

The body has no transcription block. The full transcription appears in chat at step 1 and nowhere in the hold. A summary line, enrichment block, or Appearing live block that would only repeat Details is left out.

The run that set it: an Instagram post for a film at Spectacle. The hold carried the caption twice, once in Details and once in a transcription block at the bottom, and put the Spectacle page's two extra paragraphs in a block of their own. The page said everything the caption said, and it put each showtime on its own line where the caption ran all four together.

Use the Google Calendar `create_event` tool with:

- **calendarId**: resolve by name, never by a pinned ID. Call `list_calendars` and look for a calendar named **"Event Holds"** — match case-insensitively with surrounding whitespace trimmed ("event holds" counts). If it exists, file there. If it doesn't, file to `primary` and append one line to the step-9 report: `Filed to your main calendar — create a Google calendar named "Event Holds" and future holds will file there instead, in that calendar's own color, toggleable in the sidebar.` Don't create the calendar (the connector can't) and don't ask a setup question — the calendar's existence IS the configuration. Resolve the destination before the step-7 confirm so the block shows where the hold will actually land. If the create against a found calendar fails, stop and say which calendar was tried
- **summary**: `📌 Hold: [event title]` — always this exact prefix, even when the event title contains its own colon ("📌 Hold: Twin Peaks: Fire Walk With Me…" is correct; confirmed 2026-07-04, don't restructure to avoid the double colon). **The prefix is never replaced or dropped — every hold says `📌 Hold:` (2026-08-05).** A sold-out event is still a hold; the status is inserted after the prefix, ahead of the event name: `📌 Hold: SOLD OUT — [event title]`. Waitlist-only reads `📌 Hold: WAITLIST ONLY — [event title]` (2026-10-04). Reading order is what makes this work: what it is, then the thing to know about it, then what it's called. **A private run adds one emoji and changes nothing else (2026-08-12):** 🤫 goes directly after the pushpin, and the rest of the title runs on as written — `📌 🤫 Hold: [event title]`. Space between the two emoji. This is an insertion, not a replacement: the 📌 stays, `Hold:` stays, and everything downstream of it is untouched. With both modifiers on one title the order is pushpin, 🤫, `Hold:`, status, name — `📌 🤫 Hold: SOLD OUT — [event title]`. **A Confirmed entry is the one exception to the prefix (2026-11-01, widened 2026-11-08):** it reads `📌 Confirmed: [event title]`, or `📌 🎟 Confirmed: [event title]` with a ticket, and a private one takes 🤫 after the pin: `📌 🤫 Confirmed: [event title]`, `📌 🤫 🎟 Confirmed: [event title]`. See "Confirmed entries".
- **start** / **end**: ISO datetime with `timeZone` set to the IANA TZ (e.g. `America/New_York`). **Date-only event:** set `allDay: true` and pass the date(s) instead of datetimes — this renders as the thin all-day banner, not a timed block. Omit `timeZone` for all-day events
- **location**: physical address or the literal string `Virtual`. This is the highest-value field on a HOLD — it's what gives the user the map, the directions, and the travel-time estimate. Always pass the full street address here. **Filing is a two-call operation, by design.** The connector drops `location` on `create_event` every time it's been observed, so don't treat the first call as enough: always follow `create_event` with an `update_event` that sets `location`. Don't bother branching on whether the create kept it — just always patch. If a create ever returns the location intact, fine, but never design around that. The patch sends `location` and leaves `colorId` and `availability` out, so the color and Free or Busy set on the create stay: `update_event` leaves unset fields alone.
- **colorId**: follows the finished title (2026-11-08; the table is in "The two states"). Each entry follows its own title, so several holds from one source all omit it. **A Hold, private or not: omit it.** The entry inherits its calendar's own color, which the user picks once in the Google Calendar sidebar. The author's Event Holds calendar is Birch. The skill can't set Birch on an event. Verified 2026-07-20 by rendering all candidates: the API accepts only colorId 1–11 (the classic palette; 12+ returns "invalid argument"), while the UI's current 24-name palette (Birch and the rest) is UI-only and unreachable from the API. (To clear a stray per-event override left by an older version, `update_event` with `colorId: "0"` resets the event to the calendar color.) **No Event Holds calendar:** a Hold filed to the main calendar still omits it, so it takes the main calendar's color and can look the same as a Confirmed entry there. The title and Free or Busy still tell them apart. A Confirmed entry there sets its color as usual. **A Confirmed entry: set `colorId: "9"` (Blueberry),** on filing and on Hold to Confirmed, so it reads as a regular appointment. The rule is the color of the user's regular appointments. The connector does not report a calendar's color, so the value is fixed, and this field is the only place it lives. The author's main calendar and colorId 9 both render rgb(63,81,181) (2026-11-08). A user whose main calendar has another color changes `"9"` to the nearest of: 1 Lavender, 2 Sage, 3 Grape, 4 Flamingo, 5 Banana, 6 Tangerine, 7 Peacock, 8 Graphite, 9 Blueberry, 10 Basil, 11 Tomato. **A private Confirmed entry, ticket or not: set `colorId: "11"` (Tomato, red) instead.** It renders rgb(213,0,0) (2026-11-08). Private means 🤫 in the title. Every entry has `visibility: private`, so never read that field to choose the color.
- **visibility**: `private`
- **availability**: `AVAILABILITY_FREE` (shows the time as **Free**, not Busy). A HOLD is a placeholder, not a commitment — it shouldn't block the user's availability or make them look booked. Default every HOLD to Free + Private. A confirmed entry is the exception: `AVAILABILITY_BUSY`, because the user is going, ticketed or not (2026-11-08).
- **attendees**: omit (no invitations)
- **description**: HTML, structured like this. **Formatting caution:** Google Calendar renders *both* `<br>` tags and literal newline characters as line breaks, so never put an actual newline next to a `<br>` in the description string — you'll get double-spacing. Keep each block's markup contiguous (no literal line breaks inside it); use `<br>` alone for a single line break and `<br><br>` for a blank line. Let the `<p>` tags handle spacing *between* sections. Never use `<pre>` (2026-10-05): it never wraps a line, and Calendar cuts long lines off at the right edge of the event panel.

```html
<!-- BODY ORDER (2026-07-20, remember-first): the HOLD helps the user remember and decide, not push a purchase. The event's own content leads; the action link sits below it, deliberately. Order: [availability, if unavailable] → Venue → [order number, ticket links, order email: confirmed entries only] → Details → also-in-the-image → cautions → summary → action link (+ price) → enrichment → source → footer. No transcription block (2026-10-05). -->
<!-- NOTHING TWICE (2026-10-05): see "Every piece of text appears once" above the field list. It decides whether the page or the image leads Details. -->

<p><b>🎟 SOLD OUT</b> — [what the page said], checked [YYYY-MM-DD]. [Whether it may change.]</p>
<!-- TOP LINE ONLY when the event is sold out / waitlist-only / sales ended (2026-08-05, step 5). It outranks Venue because it changes what the rest of the body is for. Everything else about availability — remaining-ticket counts, "N spots left" — stays a normal 🎟 caution line in the block below; this line is reserved for unavailable. Omit it entirely otherwise. -->
<p><b>Venue:</b> [venue name] — <a href="[venue URL]">[venue URL]</a></p>
<!-- The venue's own site or profile, when the image or a checked page surfaces one. Skip the line when there's no venue URL. -->
<p><b>[the receipt's own label, e.g. Order Number]:</b> [number]</p>
<!-- CONFIRMED ENTRIES ONLY (2026-11-01, v0.22.0): right under Venue, labeled the way the receipt labels it. Omit on a hold, and omit when neither the input nor the receipt shows a number. -->
<p><b>[the email's own link label, e.g. Add to Apple Wallet]:</b> <a href="[ticket URL]">[ticket URL]</a></p>
<p><b>Order email:</b> <a href="[receipt email link, account part removed]">[receipt email link, account part removed]</a></p>
<!-- CONFIRMED ENTRIES ONLY, after the user's yes to the email search (2026-11-01, v0.23.0): one line per ticket link the receipt gives, then the receipt email link. Omit both when the receipt isn't found. -->

<p><b>Details (from the [source]):</b><br>
<!-- Name the actual source in the label: "(from the Spectacle page)" when the page leads, or "(from the flyer)", "(from the screenshot)", "(from the email)", "(from the text)" when the image leads. "Details" is the generic header; the parenthetical keeps the provenance. -->
[the event's own description from the source that leads (the page or the image, per "Every piece of text appears once"), copied EXACTLY as written — same wording, same punctuation, same line breaks, same emphasis (lead-ins the image bolds stay <b> in the HTML; 2026-07-22). Do not summarize, paraphrase, condense, fix grammar, or re-order it. If the screenshot cut it off, reproduce what's visible and append " … [truncated in screenshot]" at the break. ONE narrow exception (2026-07-07, Synthicide "🔥 TOMORROW 🔥" test): a standalone relative-time hype line (TOMORROW, TONIGHT, LAST CALL, DON'T MISS) may be omitted and replaced with "[…]" — it reads as false by the time the hold is opened. No other edits, ever.]</p>
<!-- THE PRINCIPLE (2026-07-04): the HOLD body is the jumping-off point for deciding to attend — so ALL context from the image goes into the body, and every reference the image makes becomes a LIVE LINK, if it exists in the photo. Event page, tickets link, organizer site, venue, Instagram/X handles (resolve the handle to its real profile URL with one quick search/fetch — a dead "@name" in plain text is a miss; format as its own bare line `@handle - [profile URL]`, no "More info" label wrapping it — the label was clutter, 2026-07-21), tag/category lines, capacity ("7 spots remaining, at time of screenshot"), the flyer artwork in one line so the event is visually recognizable later. Don't cherry-pick a "clean" excerpt: the body should let the user reach the venue, the organizer, and the tickets without re-finding anything. Only skip what the image genuinely doesn't reference.
     ENRICHMENT (2026-07-04): the pages checked in steps 4–5 usually know things the image doesn't — the ticket page's own description, FAQ details (dress code, age limit, accessibility, hardship tickets), the venue's character. Bring the good ones into the body as their own labeled blocks: "From the ticket page:", "From the organizer's FAQ:". The label IS the anti-pollution rule — more context is better, but every block says where it came from, and nothing gets blended into the flyer's own words. A block holds only text the body doesn't already carry (2026-10-05): when Details comes from a page, that page has no separate block. -->

<p><b>Also in the [source]:</b><br>[only the lines from the image that the leading page doesn't carry, copied exactly]</p>
<!-- Only when the page leads Details (2026-10-05). Omit the block when the page carries every line, and always when the image leads. -->

<p>[caution lines — ⏰ time judgments, ⏱ derived end times, 🎟 availability — one line each, short, labeled, dated (e.g. "⏰ Doors filed as 11 PM — flyer doesn't say AM/PM"). Omit the paragraph when there are none.]</p>

<p>[One-line plain summary — e.g. "Three rooms, five artists on the lineup." No unsourced labels (see the lineup rule in step 3), no hedge sentences repeating what the labels already say. Omit it when it would only repeat Details (2026-10-05).]</p>

<p><b>Appearing live:</b><br>
- [Name], [Title]  ← only when it adds people or roles Details doesn't already carry (a talk's Q&A guest, an intro speaker). When Details lists the lineup, omit this block — don't repeat it. Never list film actors, documentary interviewees, or discussed authors here.</p>

<p><b>[action label]:</b> <a href="[URL]">[URL]</a> — [price as printed] (checked [YYYY-MM-DD])</p>
<!-- Label this link by what the source actually asks of the user — don't hardcode "Register". Most events (a movie, a free show) need no signup, and telling the user to "Register" for a walk-up screening is wrong. Default to the neutral "More info". Switch the label only when the image or page uses an action word:
       tickets / buy tickets  → "Tickets"
       RSVP                    → "RSVP"
       reservation required    → "Reserve"
       register / registration → "Register"
     Show the literal URL as the visible link text (e.g. https://www.spectacletheater.com/ ), not a friendly title.
     PRICE (2026-07-20): quote it exactly as the ticket page prints it ("from $22"), dated, on this line. Never a structured Price field, never a number computed from tiers; when no price is shown anywhere, say nothing.
     CONFIRMED ENTRIES WITH A TICKET (2026-11-02): omit this line. The ticket lines under Venue take its place. A Confirmed entry with no ticket keeps it (2026-11-08).
     ONE LINK, ONCE (2026-07-21): if the best action link is a URL the body already carries (usually the Venue line, on unverified holds), drop the action line entirely — a repeated URL is noise, not emphasis. -->

<p><b>Audience:</b> [audience if visible in image or on page]</p>
<hr>
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

The label is the calendar title exactly as filed, so on a private run it carries the 🤫 too: `📌 🤫 Hold: [event title] — [Mon D, time]`. On a private run this report goes out *before* the cleanup — the cleanup then erases it from the record while the user keeps it on screen — and one final line follows the script as its own message: `Cleaned, done.` Nothing else (2026-08-12); the mechanics and the only exceptions live in the private-mode section. A confirmed entry opens `Filed:` instead of `HOLD filed:` (2026-11-01).

When the lookup found the entry (2026-11-02), the report opens `Already held:` or `Already confirmed:` instead, with the same labeled link to the found entry, plus one line for anything that changed or was asked:

```
Already held: [📌 Hold: [event title] — [Mon D, time]]([calendar event URL])
```

The actions on a found entry report the same way (2026-11-02). Hold to Confirmed opens `Changed to Confirmed:`, Add to Confirmed opens `Updated:`, and both link the entry. Remove opens `Deleted:` with the title and date, and no link, since the entry is gone.

That's it. Don't summarize what was done. Don't list the description fields back. The clickable calendar link IS the deliverable — put it directly in the reply, every single time, formatted as a link the user can tap. Never make them ask for it, never make them go find the event in their calendar themselves (2026-07-04).

## Tools this skill uses

- **Native image reading** — for step 1, image input (URL input never needs it)
- **WebSearch** — for step 4, image input (URL input skips the search entirely)
- **In-app browser** (read-only page loads) — the default page reader. Step 5's opening move, step 4's shortcut when the host's site is known but the event page isn't in search results, and step 4's reader for login-walled sources. On URL input it's also step 1, since the page IS the source.
- **web_fetch** — the stand-in reader when the session has no browser. Never the opening move (2026-08-07, step 5): it fails or returns unusable text on roughly half the sources this skill gets pointed at, and a browser read has to happen anyway for the exact-copy Details block.
- **Google Calendar `create_event`** + **`update_event`** (MCP connector) — for step 8. Filing always takes both calls: `create_event` to make the HOLD, then `update_event` to set `location` (the connector reliably drops location on create). `list_calendars` is also used to resolve the destination calendar by name (step 8) and to read the user's home timezone for virtual events with no printed TZ.

- **Google Calendar `list_events`** (MCP connector): for the lookup, which reads Event Holds around the input's date (2026-11-02). `update_event` also changes a held entry's times after the user says yes, and carries out the actions on a found entry.
- **Google Calendar `delete_event`** (MCP connector): for Remove and for a delete answer about the other showtimes, only after the user's yes (2026-11-02).

- **Email search and read** (Gmail connector): for a receipt, after the user's yes or their own words about tickets (2026-11-01, widened 2026-11-02), and for an email the user names as the input (2026-11-02). It never sends.

- **`private-scrub.sh`** (shell script in this folder, private runs only) — the one-step transcript cleanup that closes a private run, pre-approved by a project permission rule so it runs without prompts (2026-08-12).

That's the full toolkit. Reading pages takes either the browser or the fetcher, and the skill needs one of the two: the browser by default, the fetcher only when there's no browser. Email is optional too: without it, receipts and email inputs can't be read. So is `list_events`: without it the skill files as before and says the lookup didn't run. So is `delete_event`: without it nothing is deleted, and the skill says so. Every other tool is required — if a required tool is unavailable, stop and say which one is missing, don't try to work around it.

### What breaks when a capability is missing

This spec is also the spec for a phone app, and the phone won't have the same tools (2026-07-25). So every capability states what happens without it. The rule: **a missing capability costs detail, never correctness.** A hold filed without any of the optional rungs is still a correct hold — right date, right place, a link back — it just carries less.

| Capability | Without it |
|---|---|
| Image reading | Image input can't run. Required for images; URL input is unaffected (2026-07-28). |
| Web search | No source page for image input, so no verification — every image hold files as ℹ no-page-found. Still a valid hold. URL input never needs search. |
| Page fetch | Nothing, when the session has a browser — the browser is the reader and the fetcher is only its stand-in (2026-08-07). With neither reader: image input loses all verification (search-listing titles become the only corroboration — date and venue usually survive, times usually don't and get a per-field caution), and URL input can't run at all, since the page is the only source, so stop and say so (step 4). |
| Page rendering (browser) | The fetcher becomes the reader, with all four of its failure shapes in play (step 5). Blocked and login-walled pages are unreadable. Enrichment is lost — price, captions, handles, FAQ detail. Verification against an unblocked, server-rendered page is unaffected. **Exact-copy Details is lost** on any page whose text the fetcher summarizes or refuses (2026-08-05): the body falls back to the credits and whatever short exact quote survived, plus the 📄 shortened-description line. **Verification itself is lost on a JS-rendered venue site** (2026-08-05, Test 18): the fetcher gets only site chrome, the venue's index of detail links never materializes, and there is no way to tell a stale or parallel listing from the right one — so the hold files as ⚠ Unverified with the venue link, never ✓. Dates and times then come from the image alone and say so. |
| Calendar write | Nothing files. Required — stop and say so. |
| Calendar read (`list_events`) | The lookup can't run, so a second filing can make a second entry. File as before, and add one line to the report: `Couldn't check Event Holds for an entry that already covers this.` (2026-11-02) |
| Calendar delete (`delete_event`) | Remove and the delete answer can't run. The entry stays, and the report says: `Couldn't delete it. Delete it in Google Calendar.` (2026-11-02) |
| Email read | Confirmed entries filed from proof carry what the image or page shows: the order number only when the input printed it, and no ticket or receipt links. Skip the email question (2026-11-01). A plain claim of tickets changes the entry with no search, a hedge or a question goes straight to the fallback question, and an email input can't be read, so ask for a screenshot of it (2026-11-02). |
| Transcript deletion (`private-scrub.sh`) | Private mode still keeps its whole promise about this project's records, which is the part that lasts. Only the cleanup is lost: the conversation stays in the runtime's own history until its retention clears it. Say that at the end of the run instead of reporting a cleanup that didn't happen (2026-08-07). |

Two rules follow from the table, and they hold in any runtime. Verification is never assumed: absent proof, the hold says so in words rather than filing a confident-looking guess — which is how the "detail, never correctness" promise survives a missing capability, by downgrading the badge rather than trying harder. And enrichment is never load-bearing: if a block of body copy would change the date, time, or place, it isn't enrichment — it belongs to verification and needs a readable source.

## Working style for this skill

- One question at a time. Never batch.
- Use real values in any preview block, never placeholders.
- Active voice. No buzzwords. No adverbs.
- Brutal honesty if the input is bad — say "this image doesn't have a date, I can't file a HOLD" instead of guessing.
- Don't recap what you just did in the final message. The calendar link is the deliverable.
