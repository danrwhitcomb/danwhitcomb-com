---
title: On risk and knowing things in software
date: 2021-09-09T01:42:07-04:00
draft: false
---

Most traditional engineering careers must grapple with strict truths. Laws guide standards for safety, and physics guide limits of designs.

Software "engineers" encounter known truths much less frequently.

In search of optimal solutions, new grads fresh from an education of exams with correct answers wince upon hearing "it depends" yet again from grizzled veterans.

When the senior principal architect of a multinational corporation produces a 20-page design document for a groundbreaking web-scale product, the implicit number of 'maybe's, 'should's, and 'probably's you could rightfully scatter throughout would make a civil engineer scream.

The difference is that software engineers can never know if they're making correct decisions. There are too many variables, too many unknowns, and they're trying to hit a moving target. People, process, cost, speed, support, ecosystem churn, turnover, new requirements, company strategy, that one engineer who really likes Haskell. Software engineers are limited to making decisions that are good enough for the problem at hand.

The rituals imbued in software culture are focused on maximizing the tolerance to engineers being wrong. Scrum and Agile focus on constant reprioritization in the face of new information. Modern CI/CD practices evangelize small, benign deployments, breaking down large changes into tolerable pieces. Unit/integration/smoke/ui testing practices all stem from a lack of trust in those who might want to change something in the future.

The process rituals we are familiar with lend themselves to small decisions though. KISS or SOLID help in day to day coding, but won't tell you if your team should switch to a new messaging bus. Agile isn't going to help you select a database technology.

Larger problems and bigger decisions aren't so straightforward despite the torrent of blog posts, conference talks, and podcasts published each day touting the right way to architect your python application. The [Slack blog post](https://slack.engineering/flannel-an-application-level-edge-cache-to-make-slack-scale/) you read on their hand-rolled, multi-region, edge caching application layer might be a great solution for them, but it is likely far from the right solution for your problem in your company.

Software engineers must approach these problems by reaching into their toolbox of experiences and the heuristics they've built from them. The challenge is to identify risks - those 'maybe's and 'probably's - and find ways to mitigate them.

The engineers who excel are the best at identifying the risks most likely to tank a project. They make the most accurate decisions on whether those risks are worth acting upon early, late, or maybe never. These engineers will have a track record of delivering large and complex projects on time.

One simple example: A junior engineer might identify an increase of 2K requests per hour as a risk to their design, but a senior engineer has seen the server handle 4x the current load and knows that while increased load is theoretically a risk, it is not worth the time to mitigate prior to moving forward. The senior engineer is more concerned about the DB schema change proposed in the design as they are unsure how it might affect the performance of another query already in production.

Constant exposure to problems and the solutions people have found to them is a great way to build the risk evaluation muscle. Reflect on experiences, keep tabs on engineering blogs, share articles with coworkers, explore new technologies, but really do whatever works for you.
