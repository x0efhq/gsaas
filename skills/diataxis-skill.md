---
name: diataxis
description: >-
  Choose and write documentation using Diátaxis (diataxis.fr). Use when
  planning, writing, splitting, or reviewing docs, and whenever a page mixes
  teaching, tasks, facts, and background.
---

# Diátaxis

Source: [Diátaxis](https://diataxis.fr/) by Daniele Procida. This skill decides **what kind of page** to write and **what that page is allowed to contain**. Sentence-level editing (voice, length, grammar) belongs to `proper-documentation.md`.

Diátaxis is a guide, not a plan. Do not create four empty sections and fill them later. Improve the page in front of you. Structure appears after the pages are the right kind.

## The compass

Ask two questions about the reader right now, or about the paragraph in front of you.

1. **Action or cognition?** Action is doing. Cognition is knowing.
2. **Acquisition or application?** Acquisition is study. Application is work.

| Content | Reader | Kind |
|---|---|---|
| Action | Acquisition (study) | Tutorial |
| Action | Application (work) | How-to guide |
| Cognition | Application (work) | Reference |
| Cognition | Acquisition (study) | Explanation |

Apply the compass to a whole page and to a single sentence. If a sentence answers a different pair of questions than the page, move it.

## When to use each kind

**Tutorial.** The reader is new to this and must succeed at a first, guided encounter. They do not yet know what to ask for. You are responsible for their safety and success. They have one job: follow. Example need: "I have never run this API. Show me a path that works."

**How-to guide.** The reader already has a real goal or problem and enough skill to follow directions. They are at work. Example need: "Add a tenant-scoped endpoint" or "Rotate an API key." A how-to is not "tour every feature." "Build a web application" is too open to be one how-to.

**Reference.** The reader is working and needs a fact they can trust: a field, a status code, a permission, a default, a signature. They consult it. They do not read it through. Example need: "What does `starting_after` mean, and what are the bounds?"

**Explanation.** The reader has stepped back and wants to know why the system is shaped this way: constraints, alternatives, history, how the parts fit. Example need: "Why is `app/` the only composition root?" Explanation is the only kind that makes sense away from the keyboard.

If you cannot name the reader-situation in one sentence, you do not yet know which kind to write.

## One page, one kind

A page has one kind. Mixing is the main failure mode.

- A tutorial that stops to explain design becomes a bad tutorial and a trapped explanation.
- A how-to that defines every term becomes a tutorial for someone who is not studying.
- Reference that says why, or what the reader should do next, stops being consultable.
- Explanation that lists every parameter becomes a bad reference.

When the other kind is needed, **link to it**. Do not paste it in.

The most common mix-up is tutorial versus how-to. Both are steps. They are not the same obligation.

| | Tutorial | How-to |
|---|---|---|
| Reader | At study | At work |
| Your job | A lesson they can finish | Directions to their goal |
| You promise | Success on your path | A way through their problem |
| You assume | Nothing beyond the stated start | Competence in the domain |
| Completeness | End to end, including setup you chose | From a sensible start to a sensible end; they join it to their own work |
| Choices | None. You choose for them | Enough flexibility for real cases |
| Explanation | Almost none | None. Link out |
| Title | Name the lesson and the concrete result | `How to …` the goal, not the tool |

Reference versus explanation is the other mix-up. Both are knowledge, not steps.

| | Reference | Explanation |
|---|---|---|
| Reader | At work, needs a fact | At study, needs a picture |
| Voice | Austere, neutral, complete | Discursive; may take a position |
| Shape | Mirrors the product | Circles a topic; bounded by a real "why" |
| Test | Boring lists and tables people look up | You could read it away from the product |
| Examples | Short, to show the fact | Used to connect causes, alternatives, history |

## How to write a tutorial

A tutorial is a lesson. The reader learns by doing. What they do is the path; what they learn is the familiarity that path produces. You cannot learn for them by explaining.

The teacher carries the responsibility. The reader is only required to pay attention and follow. There is no requirement that they already understand.

The lesson must be:

- **Meaningful.** They finish with something they recognise as an achievement.
- **Successful.** A careful follower completes it. If a step can fail in a known way, say the sign and the fix.
- **Logical.** The path makes sense in order.
- **Usefully complete.** They meet every action, name, and tool the lesson exists to make familiar.

Rules:

- Show the destination first: "In this tutorial you create a project and call it." Do not write "In this tutorial you will learn…". That promises an internal change you cannot guarantee.
- One concrete path. No alternatives, no "you could also".
- Every step produces a result they can see. Say what they should notice: "The response body contains `"object": "project"`."
- Keep a narrative of the expected: what appears, how long it takes, what a wrong turn looks like.
- Repeat a small success when the step can be repeated. Repetition is how the action starts to feel ordinary.
- Cut explanation. A clause of context is enough. A section of theory is a different page.
- Prefer the specific command, value, and name over the general case.
- Do not abstract. "A resource" teaches less than this resource, created with these values.
- Keep the story maintainable. A change in step 2 often rewrites the rest. After a product change, run the tutorial.

Anti-patterns: teaching by telling, offering choices, dumping information "while we're here", hiding the result until the end, a path that only works if the reader already knows the product.

## How to write a how-to guide

A how-to is directions for a goal or a problem. It serves someone who already knows what they want.

Write from the user's project, not from the tool's operations. "Turn the tap clockwise" is not a guide. "Shut off the water to this fixture before you open the valve" might be, if that is the actual job. In software, "call this endpoint" is not a how-to unless it is the means to a goal a person has.

Rules:

- Title the goal: "How to accept an invite". "Invites" might be reference. "Whether to use invites" might be explanation.
- Action only. No teaching, no tour, no completeness for its own sake.
- Assume a competent reader. Omit what anyone in this domain already knows. Link to the tutorial if they are not competent yet.
- Start and end at meaningful boundaries. They bring their own context.
- Order the steps by the reader's work and attention, not only by what the machine allows. Do not make them hold a question open across three context switches if one order closes it.
- Address real variation. A guide that works only for the exact case you imagined is a script, not a guide. State the condition, then the action. Do not enumerate every option.
- Steps include judgement when the work includes judgement ("If the member already belongs to an org, …").
- Troubleshooting is a how-to when it moves a competent user from a symptom to a fix.
- A list of how-tos is a map of what the product can do. Name real jobs.

Anti-patterns: a guide defined by a subsystem ("Using the billing module"), a procedure that restates the user interface, a how-to that pauses to explain the architecture.

## How to write reference

Reference describes the machinery so someone at work can act correctly. It is a map. The reader consults it. Authority comes from being complete, accurate, and unsurprising.

Rules:

- Describe. Do not instruct, motivate, or discuss.
- Mirror the structure of the thing: a field lives under its object, a method under its type, a route under its resource. The reader should be able to move between product and page in parallel.
- Use the same pattern for every entry of the same kind. Inventiveness in reference is a defect. Put each fact where the pattern says it goes.
- Be neutral. No "simply", no "note that this is powerful", no recommendation unless the recommendation is itself a fact about the interface ("The server rejects an empty name").
- Include what is needed to use the thing correctly: type, constraints, defaults, units, required versus optional, status codes, error conditions, side effects. Missing facts force the reader back to the code.
- Examples illustrate the description. Keep them short. An example that grows a story, a "why", or a "what if" has become explanation. Move it.
- Generated reference is valid when it stays faithful to the code. Generated reference is not the whole documentation set.
- Link to the how-to for tasks and to explanation for reasons.

The language of reference states facts:

- "Returns the org id."
- "`limit` is an integer from 1 to 100. Default: 20."

Not:

- "You might want to pass limit if you need paging, because…"

Anti-patterns: prose essays inside an API entry, synonyms for the same field, a reference organised by when you would read it instead of by the product.

## How to write explanation

Explanation is reflection. It answers "why is it this way?" and "how do these pieces fit?" It is less urgent than the other three and just as necessary. Without it, the reader's knowledge stays a pile of steps and facts.

You may discuss history, constraints, rejected alternatives, and consequences. You may take a position, as long as the reader can tell it is a position.

Scope is a topic, not a function and not a task. Bound it with a real question. "Why org isolation is enforced in application code" is a topic. "Auth" is not, until you draw a boundary.

Rules:

- Make connections, including to things outside this page, when the connection is what makes the subject hold together.
- Give context: decisions, constraints, what was not chosen.
- Talk about the subject. Do not walk the reader through operating it.
- Do not pretend to be the spec. Facts that must stay exact live in reference; link to them.
- Stop when the question is answered. Explanation has no natural end, so the question is the end.

Call the section whatever fits the site: Discussion, Background, Concepts. The test is the compass, not the heading.

Anti-patterns: explanation sprinkled as asides through reference, a concept page that is only a glossary, a history with no consequence for the reader.

## Titles and navigation

The title should tell the reader the kind before they commit.

- Tutorial: the concrete thing they will have done.
- How-to: `How to <goal>`.
- Reference: the name of the thing, in the product's words.
- Explanation: the question or the topic of understanding.

Do not use one heading, such as "Billing", for all four. A reader in a hurry cannot tell study from work from lookup.

## Workflow

1. Pick a real page or a real gap. Do not survey the whole set first.
2. Run the compass. Name the kind in the first line of the draft, even if you delete that line later.
3. Delete or move sentences that fail the compass.
4. Write only what that kind allows.
5. Add links at the points where another need appears.
6. Publish the small improvement. Do not wait for a complete four-part tree.

When a page is already a mess, do not rewrite the information architecture first. Make this page one kind. The surrounding structure will ask to change after several pages agree.

## Before you finish

- State which kind the page is, in your own check, and which reader-situation it serves.
- Confirm there are no steps in reference or explanation, no theory sections in a tutorial, and no lesson in a how-to.
- Confirm each outbound link is a real other kind, not a duplicate of this page.
- If you were unsure, re-ask: action or cognition, acquisition or application.
