# Style guide for the open-development essay

This is the working style guide for every contributor (human or agent) editing the essay in `designs/research/drafts/`. Read it once before touching a section; follow it on every line.

## Purpose of the document

The essay argues that open development is the path most likely to give a new indie a fair shot at being seen, and that the same principle — visible work, credited contribution, broad participation — is the durable answer to the wider questions of how creative work survives in an age of consolidation, AI displacement, and platform gatekeeping. The framing is game development. The implications are larger.

The essay is for everyone: developers, players, journalists, open-source maintainers, accessibility advocates, the curious passer-by. Write so that any of them can pick it up cold.

## Voice

- **Calm, measured, factual.** No hype, no breathless claims, no "this changes everything". Authority comes from evidence and from being unafraid of the counter-argument.
- **Warm and humble.** Lead with what a thing *is* and *does*, not what it isn't. Praise people by name. Stand on the shoulders of giants and say so.
- **Confident, not strident.** The argument wins because it is right, not because it is loud. Never suggest the essay itself is important; let the reader decide.
- **Universal, not tribal.** There is no us-against-them. We are all human. Adversaries are mistaken, not enemies. Kill them with kindness.
- **Persuasive, not manipulative in the ugly sense.** Use simile, metaphor, rhythm, and emotive language to make the reader feel the stakes. Earn every emotional beat with a fact.

## Sentences

- Short over long. Concrete over abstract. Active over passive. A sentence that needs a comma to breathe is fine; one that needs three is two sentences pretending.
- Vary length. A long sentence that establishes context, then a short one that lands the point.
- Read every paragraph aloud in your head. If it stumbles, cut.

## Forbidden tics

- **No em dashes.** Use a colon, a semicolon, a comma, or a full stop.
- **No exclamation marks.** Ever.
- **No buzzwords**: "leverage", "synergy", "disrupt", "10x", "ecosystem" (unless literal), "game-changer", "paradigm shift". If a sentence reads like a LinkedIn post, rewrite it.
- **No filler**: "it is important to note that", "needless to say", "in today's world", "at the end of the day".
- **No second-person command voice** ("you should", "you must"). Show; don't instruct.
- **No first-person plural unless earned.** "We" is the reader and the writer together, not the author and an imaginary team.
- **No hedging stack.** "It might possibly perhaps be the case that" is one word: "is", or cut.
- **No "small game", "small project", "tiny indie"** when describing Volley! or Shuck. The work is the work.

## Citations

- Every empirical claim has a citation in `[src:slug]` form, matching slugs already in use (e.g. `[src:fff-1]`, `[src:hk-wiki]`, `[src:octoverse-24-geo]`). New citations get a new slug and a corresponding entry the cohesive pass will collect.
- Cite primary sources where they exist. Cite the strongest secondary source where they don't.
- Do not paraphrase a quote into a "fact". If it's a quote, quote it.
- Numbers: include the units, the date, and the source. "$57M paid to Workshop creators by January 2015 [src:engadget-workshop]" not "Valve has paid creators a lot".

## Structure of a section

- Open with a concrete particular: a person, a date, a number, a moment. Not a thesis statement.
- Build the argument through cases. Two or three is usually enough; four if the cases are genuinely different.
- Close on the structural point the cases support. Land it and stop. Do not summarise the section in the final paragraph; the section is the summary.

## Naming and credit

- Real names, full first time, surname only after: "Maddy Thorson … Thorson". Pronouns when known and used by the person. If unsure, look it up.
- Studio names italicised? No. Game titles italicised: *Celeste*, *Hollow Knight*, *Factorio*. Songs, books, films: italics. Albums: italics.
- Currency with the symbol and unit: "AU$57,138", "US$1B", not "57k AUD".
- Dates spelled long-form on first use in a section: "27 September 2013".
- Credit communities by name where the contribution came from a community, not a company.

## Counter-arguments

- Every section that makes a load-bearing claim must survive the obvious counter-argument. Either pre-empt it inside the section, or know that section 13 (fears) handles it.
- Honest caveats strengthen the argument. Name them. The Asparouhova caveat in the inclusivity section is the model.

## Tone on AI, on industry, on self

- AI is a force multiplier. Used well, it amplifies human creativity. Used as a substitute for it, it produces a thinner culture. Say this without contempt for AI or for the people building it.
- The closed-development industry is not the villain. It is the system most people inherited. The essay invites readers out of it, not against the people inside it.
- The author is a software engineer four years into a career, building a first game. That is the speaker. No false modesty, no false authority.

## What "fully fleshed out" means

A section is fully fleshed out when:
1. Every claim has a citation or is plainly an opinion clearly marked.
2. The strongest counter-argument to the section has been answered or honestly conceded.
3. A reader who has never heard of the case studies could follow them from the section alone.
4. The prose has been read aloud and trimmed.
5. There is at least one moment in the section the reader will remember an hour later: a quote, an image, a number that lands.

## Length

There is no minimum or maximum. Long enough to be airtight, short enough to be read. If a paragraph isn't pulling weight, it isn't there.

## What this essay must not become

- A manifesto.
- A sales pitch for Volley!.
- A complaint about the industry.
- A celebration of the author.

It is a quiet, careful, generous piece of writing that happens to make a strong argument. Hold the line.

## Craft (the techniques the prose actually uses)

The essay should not feel like a chore. It should feel like a person walking the reader through a real thought, with rhythm and weight. The techniques below are the ones the prose leans on. Use them deliberately. The companion piece `designs/research/visual-positioning.md` is the in-house model: read it as an example of every technique on this list working together.

### Throughline and circle-back

The essay has one central image and one central claim. Both should land in the first section and return, in altered form, in the last. This is the inclusio: the close echoes the opening so the reader feels the structure even when they cannot name it. Mary Douglas (*Thinking in Circles: An Essay on Ring Composition*) names the minimum criterion: the ending must join up with the beginning, ideally through conspicuous key words from the exposition.

The model: visual-positioning opens on Rusty's Retirement, "a small farm at the bottom of the screen", and closes on Despelote's "kick against a wall, a radio carrying through the heat". Different cases; the same shape; the reader's body remembers the opening when the close lands.

For this essay, the central image is the developer alone with an empty repository who commits anyway. State it (or its emotional equivalent) early. Return to it (or its inverse: the audience that came) at the end. Do not announce the return; let the rhyme do the work.

### Hook

The first sentence makes a promise the reader wants kept. It is not the thesis. It is a particular: a number, a person, a moment, a contradiction. The hook earns the next sentence; the next sentence earns the next.

Bad: "Open development is the most reliable practice for indie discoverability in 2026."
Good: "In 2024 Steam shipped roughly fifty-one new games a day, and four-fifths of them went unplayed."

Long-form editorial guidance (drawn from how *The New Yorker* and similar publications open features) lands the same way: the lead is an anecdote, a vivid scene, or a single precise figure that creates tension the reader wants resolved. Keep the hook to one or two sentences before the next earns its place.

### Concrete particulars open every section

The first sentence of every section is a fact, not an abstraction. A name, a date, a sum, a quoted line. Definitions and structural claims earn their place by arriving after the case has been set up, never before.

### Show, don't tell

The fact lands harder than the claim about the fact. If the reader cannot picture it, rewrite. "Maddy Thorson rewrote the line" beats "the studio engaged with feedback". Cite specifics, name people, give the room and the year. Roy Peter Clark's *Writing Tools* frames the same instruction as climbing the ladder of abstraction: ground the reader in the concrete first; reach for higher meaning only after the case is set.

### Sentence rhythm

Long sets up; short lands. A paragraph that runs three medium sentences is forgettable. A paragraph that runs two long sentences and one short one is read twice. The short sentence at the end is the loaded one.

Gary Provost's canonical passage (*100 Ways to Improve Your Writing*, 1985) is the test: "This sentence has five words. Here are five more words. Five-word sentences are fine. But several together become monotonous." Vary length and the writing makes music; hold one length and the ear gives up.

Read every paragraph aloud. Where the breath stumbles, cut.

### Paragraphs end on the loaded sentence

The last sentence of a paragraph is the one the reader will remember. Engineer it. Do not waste it on a transition; transitions go in the first sentence of the next paragraph.

### Anaphora and the rule of three

Three short sentences starting with the same word make a paragraph land. Use sparingly: the technique tires fast. Three is the magic number for lists, examples, and rhythmic builds. Four feels long; two feels incomplete.

### Trust the reader

If a metaphor lands, do not explain it. If a joke lands, do not gild it. If a citation makes the point, do not paraphrase the citation in the next sentence. Every paragraph that explains the previous paragraph is one paragraph too many.

### No signposting

Avoid "first", "second", "third", "in conclusion", "to summarise", "as we discussed earlier", "as the next section will show". The structure should be felt, not announced. The exception: a section can refer back to a named earlier section by topic, not by number. ("As the inclusivity section showed" is fine; "as section 09 showed" is not.)

### Strong nouns and verbs

Adjectives are accomplices, not principals. "The studio shipped" beats "the small independent studio successfully released". Cut adverbs aggressively; King is right that they are a road to hell. Adjectives stay only when they carry information no noun could ("hand-drawn animation" yes; "beautiful animation" no).

### Active voice

Passive voice obscures who did what. Most of the time the actor matters. "Wube reversed the redesign" beats "the redesign was reversed". Passive is allowed when the actor genuinely does not matter or when the receiver of the action is the point ("the file was leaked").

### Cut filler ruthlessly

Words to find and remove (or justify): something, actually, really, very, quite, just, basically, essentially, somewhat, rather, in some sense, to a degree, in a way, the fact that, the thing is, it is worth noting that, needless to say, in today's world. William Zinsser (*On Writing Well*) puts the diagnosis plainly: "Clutter is the disease of American writing." His remedy is the same one this guide takes: strip every sentence to its cleanest components, and ask of every word whether it is doing new work. Most second drafts are 30% shorter than first drafts and lose nothing. The craft is in the cut.

### One idea per paragraph

A paragraph is a unit of thought. If two ideas live inside it, the reader splits attention and the paragraph blunts both. Break it.

### Quote what is quoted, summarise what is summarised

Direct quotes go in quotation marks with citations. Summaries do not. Never paraphrase a sentence so that it sounds like a quote without being one; the reader will catch the seam and trust drops.

### Comedy is a precision instrument

A joke must come from a real observation, not wordplay. Never more than one per section. Never in places where the register must stay clean (heavy emotional material, the close, sections about real people's hardships). The test: does the smile move in the same direction as the argument? If not, cut. Default is no joke.

### Footnotes and references

Inline citations use Markdown footnote syntax `[^slug]`. The slug points to a definition in the bibliography section. Hyperlinks within the essay text are reserved for cross-references and external resources the reader should click.

### Editing checklist (run before declaring a section done)

1. The opening sentence is a particular, not a thesis.
2. The closing sentence of the section is the one the reader will remember.
3. Every paragraph passes the read-aloud test.
4. Every claim has a citation, a quote, or is plainly an opinion clearly marked.
5. Every adverb has been examined; most are gone.
6. Every "really", "actually", "something", "very" has been cut or justified.
7. No paragraph summarises the previous paragraph.
8. No transition word does work the structure should do silently.
9. The throughline is visible: someone reading this section without context can still feel the central image and claim of the essay.
10. The section earns its place. If it could be cut without weakening the whole, cut it.

## Narrative momentum: making the essay a page-turner

A long essay survives or fails on whether the reader wants the next paragraph. Argument alone does not pull; momentum does. The techniques below are how a working essayist engineers it. Use them on every section.

### The but/therefore rule

Trey Parker and Matt Stone, talking to NYU film students in 2011 (clip widely circulated; see Scott Myers, "Writing Advice from Matt Stone and Trey Parker", *Go Into The Story*, 2014), name the test plainly: between any two beats, the connector must be "but" or "therefore", never "and then". "And then" is summary; "but" is reversal; "therefore" is consequence. Read every paragraph break with that test. If three paragraphs in a row connect on "and then", restructure until each one earns the next.

### Curiosity gaps

Each paragraph poses a small question the next answers. The reader is pulled forward by the gap, not by the argument. Robert Boynton (*The New New Journalism*, Vintage, 2005) collects the longform reporters who do this best; the through-line in their interviews is that a paragraph closes by raising a question the next paragraph cannot duck. Engineer the gaps deliberately. A paragraph that resolves itself is a paragraph the reader can stop on.

### Scene, then reflect

Ira Glass, in his 2009 storytelling videos for the *Current TV* / *PRI* series (transcribed widely; see Daniel Webster's transcript on Medium, 2014), names the two building blocks of narrative: the anecdote (a sequence of actions with momentum) and the moment of reflection (the line that says why the reader is being asked to listen). Good pieces flip between the two. A section that is all anecdote is gossip; a section that is all reflection is a lecture. Pace the toggle.

### Name the dog

Roy Peter Clark, *Writing Tools* (Little, Brown, 2006), tool 14: get the name of the dog. Specificity that no general writer would notice is what breaks through. A date, a sum, a phrase from a primary source, the colour of the build account password ("blank") — the detail nobody else included is the detail the reader remembers.

### Engineer the kicker

The closing sentence of every section is the one the reader carries away. Cut everything after the line that lands. If a section ends on a synthesis ("the pattern is clear"), find the loaded sentence already in the section and end on it instead. Ben Yagoda (*The Sound on the Page*, HarperCollins, 2004) is the canonical reference; the rule is older than him.

### The reversal

At least once per part, set up the obvious answer and then overturn it. Malcolm Gladwell's MasterClass lesson "Structuring Narrative: The Imperfect Puzzle" (2017) frames the same move: articulate the assumption the reader is bringing, show where it fails, replace it. A reversal hidden mid-paragraph is wasted; stage it.

### Stakes that escalate

Robert McKee, *Story* (ReganBooks, 1997), on the obligation of rising stakes: each act must matter more than the last, or the reader checks out. Part I's stakes are one developer's first commit. Part III's stakes are what creative work is for. The middle is the climb.

## Structure: the essay as a mini-book

The essay runs to roughly ten thousand words. That is a mini-book, not a blog post and not a position paper. Treat the structure accordingly. Sections are chapters; chapters cluster into parts; parts move the argument from invitation to evidence to consequence. Ring the close back to the open.

### Three parts

Borrow the three-act spine that nonfiction workshops adapt from drama (see Rachael Hanel's "3-Act Structure for Nonfiction", 2017). Name them in running text rather than numbering them.

- **Part one — The mark.** Sets the problem and the promise. Establishes that discoverability is a relationship, not a campaign. Houses sections 01 and 02.
- **Part two — The practice.** Walks the cases that prove open development is the durable mechanism. Houses sections 03 through 10. This is the long middle; pace it with the lightest case first and the largest (Valve) last.
- **Part three — The stakes.** Widens from craft to consequence: AI, humanity, fears, close. Houses sections 11 through 14.

### The nut graf

Long-form features in *The New Yorker*, *The Atlantic*, and the *Wall Street Journal* place a "nutshell paragraph" after the lead and before the body. It tells the reader, in plain language, what the piece is about and why now (see Chip Scanlan, "The Nut Graf, Part I", Poynter, 2003). For a ten-thousand-word essay the nut graf can be a short paragraph or two. It belongs at the hinge between the opening case (section 01) and the structural reframe (section 02) — the closing paragraph of section 02 is the natural seat. State the claim once, plainly, then return to the cases.

### Toulmin's six elements

Stephen Toulmin's *The Uses of Argument* (Cambridge University Press, 1958) breaks an argument into claim, grounds, warrant, backing, qualifier, and rebuttal. The essay already carries each, distributed: the claim sits in section 02; the grounds are the case studies in sections 03 through 10; the warrant — that visible work compounds into recognition — runs through the devlog and transparency sections; backing arrives via Valve in section 10; the qualifier is the Asparouhova caveat in section 09 and the structural-not-guaranteed line in section 12; the rebuttal is section 13 (fears). When editing, name which element the section is carrying. If two sections carry the same element and add nothing new, one of them is redundant.

### The hourglass

Scientific abstracts open broad, narrow to method, narrow again to findings, then widen to implications (Sollaci and Pereira, "The IMRAD structure: a fifty-year survey", *Journal of the Medical Library Association*, 2004). The essay should follow the same shape at book scale: open on the indie-discoverability problem, narrow to the cases, narrow further to specific exchanges (Thorson and Halfcoordinated; Wube reversing a redesign), widen to AI and humanity, close on the broadest claim the cases have earned.

### Book conventions to adopt

- An epigraph on the title page is optional but recommended; one short quotation, attributed, no commentary.
- A brief preface or author's note (one or two paragraphs) at the very front, naming what the piece is and what it is not. The essay does not currently have one.
- Running part titles between sections, set as their own page break.
- No chapter numbering inside running text. Sections may be referred to by topic ("the inclusivity section"), never by number.
