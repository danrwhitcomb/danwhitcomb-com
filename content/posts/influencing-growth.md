---
title: "Influencing growth with design"
date: 2023-11-11T01:42:07-04:00
draft: false
---

Building software with people means the complications of the social world are dragged into the digital one. Software engineering has no real laws, making conversations on correctness highly subjective - a field of egos and feeling landmines stretching out before you. 

An organizational leader even has minimal power to influence design. Architects may be able to define and build agreement around high-level approaches on data flow and infrastructure. Managers may be able to set requirements for their teams around quality and efficiency. Both are powerless in the face of human nature, where people do not like being told what to do.

It's unwise for those in organizational positions of power to flesh out in a Jira ticket entire class heirarchies, or dive deep into how each layer of code should look. It's a waste of time - the implementer will be able to deduce 90% of that information from a description of the goal - and most importantly it robs the implementer of their creative freedom. ICs become automatons, employed by a ticket factory: a recipe for low morale and high atttrition.

The senior IC holds an even more unfavorable position; with no title to wield, they are tasked with maintaining quality and velocity only by their influence while shipping themselves. On a team of even 3+ engineers it's impossible to review and discuss every design decision being made. When there is opportunity to review code, only so many changes can be requested before pissing off the author. 

As a software leader, you somehow need to be in many places at once, encouraging good design and preventing bad. One of the most effective ways to do this is to bake a pathway for expansion into a system from the start. A design should be like a force-ghost, whispering advice into the next engineer's ear. Encouraging good decisions and requiring effort for questionable ones can have a massive impact in how a codebase grows. 


## Quick example

Let's explore a very simple example of this. You're writing a CSV generator because every B2B app and many B2C apps do this. The minimal code to get this story done looks something like:

```java
public String generateTransactionCSV(
    UUID userId, 
    LocalDateTime startDate,
    LocalDateTime endDate,
    String transactionType
    ) {
      
      if (endDate < startDate) {
        throw new IllegalArgumentException("End date cannot be before start date");
      }

      List<Transaction> transactions = repository.getData(userId, startDate, endDate, transactionType);

      CSVWriter writer = new CSVWriter();

      transactions.forEach((tx) -> {
        writer.writeRow(tx.userId, tx.date, tx.type, tx.amount)
      });

      return writer.toString();
}
```

Pretty straightforward code to write and test. You can ship it and satisfy the customer quickly.

This 10 line function is going to grow over time. You can't guarantee the next person to change it will be you, and you can't guarantee the next person will be in the right mindset to expand on it in a sustainable way. They might be stressed that day, rushed by their PM, or feeling a little down and getting a quick win would feel great.

So how can we setup that next developer and the line of future developers for success here? Lets explore by segmenting the function by its responsibilities.

```java
public String generateTransactionCSV(
    UUID userId, 
    LocalDateTime startDate,
    LocalDateTime endDate,
    String transactionType
    ) {...}
```

The function's parameters are all filters on your data set. New filters will get added to this code.
```java
if (endDate < startDate) {
  throw new IllegalArgumentException("End date cannot be before start date");
}
```

We're doing a little validation on the inputs to help the user. As filters get added there may be more validation to do.

```java
List<Transaction> transactions = repository.getData(userId, startDate, endDate, transactionType);
```

We're reading data. How big could this dataset get? How long would it take to fetch 1000 rows? 10000 rows? We might have to page data from the source. Can we block for that long on the current thread?

```java
CSVWriter writer = new CSVWriter();

transactions.forEach((tx) -> {
  writer.writeRow(tx.userId, tx.date, tx.type, tx.amount))
});

return writer.toString();
```

There will likely be new columns we'll want to add. It's possible customers will want to choose which columns they want to export. Can the full CSV fit into memory? How many requests could we be serving simultaneously? 


The answers to those questions will be different depending on your product and traffic pattern. Assuming your existing infrastructure can already handle the dataset sizes, but there's a reasonable chance they could grow. Here's how I'd write the first version of that original block:

```java
record ReportFilters(
  UUID userId, 
  LocalDateTime startDate = now()
  LocalDateTime endDate = now().plusDays(30),
  String transactionType = "credit"
) {}

record CSVColumn<T>(
  String key,
  Function<T, String> write
){}

CSVColumn<Transaction> USER_ID = CSVColumn<Transaction>(
  "user_id",
  (tx) -> tx.userId
);

CSVColumn<Transaction> DATE = CSVColumn<Transaction>(
  "date",
  (tx) -> tx.date
);

CSVColumn<Transaction> TYPE = CSVColumn<Transaction>(
  "type",
  (tx) -> tx.type
);

CSVColumn<Transaction> AMOUNT = CSVColumn<Transaction>(
  "amount",
  (tx) -> tx.amount
);

List<CSVColumn<Transaction>> COLUMNS = listOf(USER_ID, DATE, TYPE, AMOUNT);

public OutputBuffer generateTransactionCSV(ReportFilters filters) {
    validateFilters(filters)
    Stream<Transaction> txStream = repository.streamData(filters);

    CSVWriter writer = new CSVWriter(new BufferedOutputStream());
    txStream.forEach(tx -> {
      CSVRow row = writer.newRow()
      COLUMNS.forEach(column -> row.writeColumn(column.write(tx))
    });

    return writer.outputBuffer();
}

private void validateFilters(ReportFilters filter) {...}
```

With this setup I'm accounting for the code to expand in a few ways:

#### More filters will be added
Making a data structure to contain filters encourages the next person to add a filter in the record class rather than to a growing list of function parameters. You'd propagate that filter set to your data layer as well as parameters in your API so having it in a single structure limits spots to change in the future.
  
#### There will be more validation to do
Validation can get complicated depending on the use case. In this case, designating a specific validation function tells the next engineer "Put your validation _here_!". It'll make it easier to split that into a separate file or class in the future if necessary. We don't need to account for all eventualities right now, only introduce a gentle nudge.

#### The dataset will likely grow
Streaming datasets in reporting situations can quickly increase your runway for growth and be very easy to implement. Both ends of the system typically support this with little hassle, you can stream rows from a DB using your ORM and progressively write lines to a file or an http response. Introducing streaming datastructures into your business logic is typically a quick google away to find the syntax.

#### More columns will be added / different reports will get run
Rendering columns can be more complicated than accessing a field (`tx.userId`). You may need to do a calculation or convert a timestamp to the user's timezone. Defining this outside of the core flow for generating the CSV means it's clear to an engineer where they can slot in a new column and they can do so without altering the generation code. It also makes it reusable for new CSV formats that are introduced.

An engineer tasked with a small improvement to the code written with the original approach will laugh in your face if you ask them to rework it in the later style. They have other work to do, the customer is waiting, etc. Unfortunately, as more features are added, it becomes increasingly harder and riskier to redesign making it more important to establish a sustainable pattern early. 

## Over engineering
We love shutting down suggestions we don't want to do with phrases like 'over-engineered' and 'prematurely optimized'. These concerns are increasingly more valid as a problem domain becomes hazier, but for well known problems making the right optimizations early can save a lot of time down the line. Not sure if your social network for dogs is gonna take off? Don't use a distributed graph database. You're a B2B company and your customers want to export data? It's pretty easy to know what that feature will look like in 6-18 months.

As your domain increases in haziness, it's perfectly acceptable to turn down the dial on the optimizations. It's more important to focus on designs with two-way doors to be able to back yourself out of an suboptimal design.

Many 'premature optimizations' take nearly as many key strokes as their unoptimized counterparts - eg using Java's buffering APIs is the same number of lines as loading everything into memory. 

The second block took 10 minutes more to write than the first, while saving many hours of eng-time in the future. I've done enough CSV generation in my career that I can have high confidence these optimizations are valuable and inevitable.

Other sub-systems that you'll be able to predict the growth of:
- Auth
- Reporting / data processing
- Job execution
- Async processing
- CI/CD
- Deployments
- Email sending / receiving
- Chat
- Observability (logging, metrics, tracing)

You may notice something about this list: there are companies that have already largely solved these domains, are better at running them than you, and will sell you their solutions. 

### Set your code up for success
When onboarding new employees we talk about 'setting them up for success', getting them the right people, documents, and access to be able to grow into their job as effectively as possible. The systems we build are the same way; they start small and need to grow and flourish. 

Alignment, style guides, linting, and reviews can help immensely. Those don't work at the level we need them to or require loads of communication and time. Incorporating a growth mindset into your system design helps your intentions be present when you aren't. 



