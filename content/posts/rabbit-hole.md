---
title: Coming up for air
date: 2024-06-26T12:42:07-04:00
draft: false
---

{{< figure src="https://washburnalice2018.pbworks.com/f/1544715637/event_image-18.jpg" alt="Falling down the rabbit hole" class="left" width="250px" >}}

The rabbit hole: a deep line of thought with no clear end. It's hard to know when to run with an idea or to come up for air and search for an alternative approach. Running with the idea may lead you to a solution, or you may reach the bottom with nothing to show for it. Knowing when to come out of the wrong holes as quickly as possible makes you a more effective decision maker and thus able to deliver value faster.

Chess players perform a depth-first search in their heads, running down hundreds of rabbit holes on every move. How do they know when a possible line of moves isn't worth checking?

They're looking for a single reason the line won't work. The reason may be obvious - they'll lose their queen - or more subtle - they'll lose control of the center of the board. Finding that single reason lets you rule out all possible sub-trees in your search and go back to the start.

When designing software you should be applying the same heuristic. Be on the lookout for total constraints. Continuous constraints might make an approach slightly better or slightly worse. Total constraints are binary: completely validating or invalidating an approach.

 If you're able to identify a constraint that invalidates your current path, there is no value to investigating the path further letting you hop out of the rabbit hole with haste. 

Total constraints often take the form of: If _X_ is true, then the current idea is invalid.

Some examples:

- If the database isn't ACID compliant, then we can't use it for our banking application
- If we don't want to version the API, then we can't change the response body schema
- If we have to meet 99.99% uptime, then we can't take downtime for the data migration

These are likely obvious examples of constraints. You'll run into much more nuanced situations in your own work. 

Establishing the base constraints of the problem is where to start. What are the product requirements? What are the cost requirements? What are the technology requirements? You can start there and derive more detailed constraints that will guide your path, like slowly identifying singular cells in a sudoku puzzle.

Constraints also help you flip the problem on its head. You can look to the end and say: If _X_ was true, how do we get there? Unraveling the problem in the opposite direction helps to shift your thinking to an angle you may not have taken yet. 

Sometimes constraints are more fluid than you think. In reality, product requirements can be negotiated, especially if there is a valuable tradeoff involved: "We'd be able to deliver this 4-weeks faster if the system could be eventually consistent." Don't be afraid to discuss these with your product manager if there's potential value to be found.

Exploring problems with a constraint-based approach forces you down paths that will likely yield a viable design at maximum velocity. It's an incredibly powerful tool for dealing with design problems in the software world where there are nearly limitless possibilities to solve a problem.




