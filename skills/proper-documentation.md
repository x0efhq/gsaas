---
name: proper-documentation
description: >-
  Edit documentation for clarity using Google's Technical Writing courses.
  Use when drafting or revising sentences, lists, procedures, openings,
  figures, and sample code. Use diataxis-skill.md first to choose the page kind.
---

# Proper documentation

Source: [Technical Writing One](https://developers.google.com/tech-writing/one) and [Technical Writing Two](https://developers.google.com/tech-writing/two) from Google for Developers. Diátaxis decides the kind of page. This skill decides whether the sentences, lists, and examples on that page are clear.

Apply it after the page has one job. A clear sentence in the wrong kind of page is still the wrong page.

## Audience

Name the reader before writing: role, what they already know, what they are trying to do.

- Define a term the reader does not know the first time it appears. Use the same term for the same thing afterwards. Do not rotate synonyms (`server`, `instance`, `box`) to sound varied.
- Skip explanations of what this reader already knows. That text is noise, and it hides the part they came for.
- The curse of knowledge is assuming a step is obvious because it is obvious to you. If a newcomer would have to guess a command, a path, a default, or a name, write it.

State prerequisites where the reader needs them: at the start of a tutorial or how-to, and next to a reference entry only when a fact is false without that condition.

## What a document says at the top

The opening states what this page covers. The reader should know whether to stay.

- Say the scope in the first short paragraph.
- Say what the reader will have done, or which facts the page documents. Match the Diátaxis kind.
- List prerequisites only if the page fails without them.
- Do not open with history, a dictionary definition, or a motivational paragraph.
- Do not announce "this section discusses". Discuss it.

A large document gets an outline before prose: who it is for, what it includes, what it leaves out, and the order of sections. One topic per section. Put the common case before the rare case. Move long tables and edge cases to reference instead of burying the task.

## Words

- Prefer the short, ordinary word when it means the same thing: `use` not `utilise`, `show` not `indicate`, `after` not `subsequently`.
- Introduce an abbreviation once: "role-based access control (RBAC)". After that, use the short form. Do not abbreviate a term you use once.
- Replace an ambiguous pronoun. `This`, `that`, `it`, `they`, and `which` must have one obvious noun. If the previous sentence has two candidates, repeat the noun. Bad: "The worker validates the sale and invites the user. This fails when the field is empty." (`This` can be the sale, the invite, or the whole step.) Write: "The invite fails when the field is empty."
- Do not write `the former` / `the latter` across a long sentence. Repeat the names.

## Active voice

Active voice names the actor, then the verb, then the thing acted on.

- Active: "The server rejects an empty name."
- Passive: "An empty name is rejected."

Prefer active voice. The actor is visible, the sentence is shorter, and the reader knows who does the work.

Use passive voice only when the actor is unknown, irrelevant, or already obvious, and the object is the point: "The token is stored as a hash." If the reader must act, name them: "Store the token as a hash" or "The client stores the token as a hash."

Three costs of needless passive voice: the actor disappears, the sentence grows, and a procedure becomes unclear about who acts.

In steps, use imperative active voice, which addresses the reader: "Set `limit` to 20." Not " `limit` should be set to 20."

## Strong verbs

Pick a verb that states the action. Cut verbs that only announce an action.

| Weak | Strong |
|---|---|
| is responsible for sending | sends |
| provides the ability to create | creates |
| perform a deletion of | delete |
| make a decision about | decide |
| occurs | happens only if you must; otherwise name the event: "The job starts" |

Reduce `there is` and `there are`. "There is a token that expires" becomes "The token expires."

`to be` is fine when the sentence is a classification or a state: "`limit` is an integer." Do not use it to avoid a real verb.

## Short sentences

One idea per sentence. If you used `and` or `but` to join two ideas, try two sentences.

- Aim for sentences a reader can say in one breath. Split anything that stacks clauses, exceptions, and examples in one line.
- Turn a sentence with three or more parallel parts into a list.
- Cut words that do no work: `just`, `simply`, `basically`, `really`, `very`, `actually`, `in order to` (`to`), `the fact that`, `it is important to note that`.
- Put the main action early. Do not make the reader hold a condition for a whole line before the verb. If the condition is long, make it its own sentence first.

Long is allowed when a short version would drop a necessary condition. Length is not the defect. Two ideas in one sentence is the defect.

## Lists and tables

Use a list when items are peers. Use prose when you are connecting ideas.

- Number the list when order matters (a procedure, a ranking). Bullet it when order does not.
- Keep items parallel. If the first item is an imperative, all of them are. If the first is a noun phrase, all of them are.
- Start a numbered step with an imperative verb.
- One action per step. A step that says "install the tool and configure the token and run the check" is three steps.
- Introduce the list with a complete sentence. The items complete that sentence or stand as a series under it. Do not leave a heading with no lead-in when the list's purpose is unclear.
- Punctuate the list consistently. Full sentences end with periods. Fragments do not. Do not mix them in one list.
- Use a table when the reader compares the same attributes across items (field, type, required, meaning). Do not use a table as a paragraph with borders.

## Paragraphs

- The first sentence states the point of the paragraph. The rest supports only that point.
- One topic per paragraph. When the topic changes, start a new paragraph.
- Three to five sentences is a usual length. A single sentence is fine when the point is a warning or a rule. A paragraph that runs past half a screen is more than one paragraph.
- Put the result or the rule before the background, unless the reader cannot understand the rule without one sentence of condition.

## Procedures

- Say what must already be true.
- Number the steps.
- Tell the reader what to expect after a step when silence would look like failure.
- Put notes and warnings before the step they affect, not after the reader has already acted.
- Do not hide a required action in a note.

## Punctuation

Use punctuation to remove ambiguity, not to show range.

- Put a comma between independent clauses joined by `and`, `but`, or `or` when each clause has its own subject.
- Use the serial comma in technical lists: "id, name, and slug." It keeps the last two items from fusing.
- A colon introduces a list, a table, or a concrete restatement. What follows the colon belongs to the sentence before it.
- Prefer a new sentence to a semicolon.
- Hyphenate a compound modifier before a noun: "read-only access", "tenant-scoped route". Do not hyphenate after the noun: "access is read only" is also acceptable as "read-only".
- Put the period inside a complete quotation only when it is part of the quoted sentence. Keep exact values, error strings, and identifiers in code formatting so punctuation stays outside the value.
- Use a dash for a real break, not as a substitute for organising the sentence. If you need a dash, try splitting the sentence first.
- Parentheses are for a short aside the reader can skip. If the aside is required, it is not a parenthesis.

## Figures

A figure earns its place when it shows a relationship the prose would take a paragraph to establish.

- Place it immediately after the sentence that needs it.
- Write a caption that says what to notice, not "A diagram of the system."
- Refer to it from the prose by what it shows. "The request passes `Tenant` before the handler" is better than "See the figure below."
- One idea per figure. Label the parts a reader must name later, in the same words as the text.
- Do not put a required step only inside an image. Repeat it in text.

## Sample code

- The sample must be correct for the version you are documenting. A short sample that runs is better than a long sample that is almost right.
- Show only the lines that serve this page. Cut boilerplate the reader already has, and say what you cut.
- Match names, fields, and defaults to the reference. Do not invent a friendlier field name in an example.
- Comment a line only when the code cannot say the thing. Do not narrate "create the client".
- Show the result that matters: a response body, a status, or a row. Trim logs that do not teach.
- Tell the reader where the sample runs (shell, request, test) in the sentence before the block.

## Self-editing

Edit in passes. Do not try to fix kind, structure, and commas at once.

1. Kind and audience. One Diátaxis kind. The opening matches it. Prerequisites are real.
2. Structure. First sentence of each paragraph carries the point. Steps are ordered. Reference entries follow one pattern.
3. Sentences. One idea. Actor named. Strong verb. Pronouns point at one noun.
4. Words. Same term throughout. Unneeded words gone. Abbreviations defined once.
5. Lists, tables, code, figures. Parallel, introduced, true.
6. Read it aloud, or read each sentence on its own from the bottom up, so habit does not supply the missing word.

A draft from a model is a first draft. Run the same passes. Do not treat fluent output as finished.

## Before you finish

- A newcomer in the stated audience can act or look something up without guessing a name.
- No sentence needs to be reread to find the actor or the point.
- List items match grammatically.
- Examples agree with the reference.
- Nothing remains that only says the writing is about to begin.
