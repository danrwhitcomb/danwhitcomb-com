---
title: PR comments that waste our time
date: 2022-09-25T01:42:07-04:00
draft: false
---

The PRs I post have one of two goals:

1. I had an idea that easier to communicate in code so here's an incomplete, untested, likely dubious proof-of-concept. It should always be a draft.

2. After anywhere between a conversation with a teammate and weeks of bureaucratic pain to align 8 teams across 3 business units, we have a path forward. This change is ready to go to production so we can ship some goddamn product.

If it's a #1 PR, there should be no comments - when is the GitHub feature to disable comments shipping? - It's a discussion starter and threads attempting to align minds on context and intent are a waste of everyone's time. Get on a call and talk to your people.

There is plenty of valuable discussion to be had on a #2 PR. The following are comments which are prevalent in engineering yet worthless. They ultimately slow down shipping and bring great shame upon the commenter's household.

<div align="center"><i>*As with all things software engineering, nothing is true and everything is permitted.</i></div>

<div align="center"><i>Including this post.</i></div>

### Formatting

> @jonbonjava commented:
>
> NIT: need a space here

Contributors to a codebase should never have to care about their formatting. Code formatters and pre-commit hooks have been around for 20 years, use them or don't nitpick my formatting.

### Style

> @freddymercurial commented:
>
> Can we split this bit into a new function?

Coding is like handwriting, everyone's is different and the vast majority gets the job done. Good citizenship is attempting to match the code's existing style and nothing more.

Expecting the writer to match _your_ style is a frivolous endeavor. Code is easy to change, APIs, schemas, and infrastructure are much harder. Focus on those bits and don't get bogged down in debates on cyclomatic complexity.

Similarly to formatters, linters exist for every language. Use them instead of making GitHub store your comment forever.

### Refactoring

> @fleetwood-macintosh commented:
>
> While you're in here lets clean up QueryConnectorFactoryBuilder

Refactoring _is_ a critical piece of maintaining a codebase. When critical, then it should be an explicit task accounted for in an implementation plan. All other refactoring is out of the goodness of an engineer's heart.

That's not to say all refactoring comments are equally terrible.

Acceptable ones:

1. Are optional. The file a function is in won't make you money, shipping will. The writer is best equipped to decide if there is time to put in extra work.
2. Include a code sample. The writer does not want to guess what's going on in your mind.

### Architecture

> @bruce-spring-boot commented:
>
> Hmmmm, I think it would actually be better if we put this into the query-backed queuing sub-system. Maybe we should get @random-person-from-another-team involved?

If an approach has been hashed out and code is being written, the architecture discussion is over.

Unless you've discovered a fundamental flaw that leads to a missed deadline or significant customer harm, additional architecture opinions slow everyone down. We've had too many meetings and spent too long getting to where we are.

If you made it through those discussions without understanding what was really going to happen and are just now realizing, bummer. Progress won't be stopped by a person's failure to pay attention.

<div>
<img src="https://i0.wp.com/dsruptr.com/wp-content/uploads/2020/07/img-swoop-and-poop-agile.jpg" alt="drawing" style="width:200px; float: right;"/>
<div>
<h3> Swooping & pooping</h3>

This is the only one where a lack of comments will get you in trouble.

Unless you intend to fully engage with a PR - most importantly continuing the discussion beyond a single comment - then just continue on with your day.

All feedback is not equal. In most cases only a handful of engineers have the context necessary to produce useful feedback.

Engineers that swoop in and spread comments that are ultimately wasteful cause distraction and confusion for the writer.

</div>
</div>

#### Postscript

If a junior engineer makes comments like this, they're likely copying it from someone more senior. Be nice to them
