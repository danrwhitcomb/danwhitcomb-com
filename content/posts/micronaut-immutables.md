---
title: "Immutables, Micronaut, and Maven"
date: 2021-08-07T01:42:07-04:00
draft: false
---

What Java lacks in features, ergonomics, and general modernity, it makes up in ecosystem. C# devs have had [generated getter/setter methods](https://docs.microsoft.com/en-us/dotnet/csharp/programming-guide/classes-and-structs/auto-implemented-properties) for the last 14 years, but Orcale likes their languages like their business strategy: behind the times.

Since Java runs on 3 billion devices, engineers have been forced to make up for Orcale's lack of Java interest for years. This is less true since Java 9, but I always take an opportunity to bash Oracle - and their database icon office buildings.

{{< figure src="https://media.bizj.us/view/img/9271162/oraclecampus041216tj-20*1200xx6901-3894-0-263.jpg" title="Talk about working in databases" >}}

## A brief Immutables overview

[Immutables](https://github.com/immutables/immutables) is a 'this should have been a language feature and now we're here' library.

The best Java data containers have three characteristics, immutability, comparability, and serializability. There are plenty of resources online that will discuss why these are useful, I won't go into details here.

With vanilla Java and conforming to style standards, to write a data container with these features you'll need a solid twenty minutes.

Oh and you'll fuck it up 10% of the time:

```java

public class Car {

    private String make;
    private String model;
    private String year;
    private String vin;

    Car(String make, String model, String year, String vin) {
        this.make = make;
        // ... More assignments
    }

    @JsonProperty("make")
    String getMake() {
        return this.getMake;
    };

    // ... More getters

    public static class Builder {

        private String make;
        // Attributes...

        Builder setMake(@NotNull String make) {
            this.make = make;
            return this;
        }

        // ... More setters

        public Car build() {
            return new Car(make, model, year, vin);
        }
    }

    @Override
    public String toString() {
        return "Car{make=%s, model=%s, year=%, vin=%}".formatted(make, model, year, vin);
    }

    @Override
    public int hashCode() {
        // ... hash code crap
    }

    @Override
    public boolean equals(Object other) {
        if (other == null || !(other instanceof Car)) {
            return false;
        }

        return this.hashCode() == other.hashCode();
    }
}

```

Immutables gives us the data containers that we've always wanted: Immutable, comparable, null-free, serializable, and **concise**.

We can generate data container classes at compile time that handle all the minutea found in the block above, and they take seconds to write:

```java
@Style
@Value.Immutable
public interface CarIF {
    String getMake();

    String getModel();

    String getYear();

    String getVin();
}
```

This block gives us each characteristic that I want in a data container. Immutables runs at compile time, scans the classpath for `*IF` (or whichever prefix/postfix you configure) and in this case generates a `Car` class that has all the functionality you want.

Using immutable data containers lets you not think about - or forget to handle - a number of edge cases. Immutables makes them easy to use in Java. 10/10 library in my book.

## Interop with Micronaut

Many forces have been pushing the Java ecosystem away from runtime reflection - serverless, containerization, continuous deployment, and mobile are the big ones. The popularization of these runtimes means that your application is primarily ephemeral. At any time a new instance might need to be started.

Ephermality necessitates fast application startup time. Deploys are faster, rollbacks are faster, scaling is faster, user experience is better.

The Java web framework ecosystem was built on runtime analysis of packaged code to perform dependency injection, identify application components, and manage serialization of data models. the next generation of Java frameworks have recognized that its necessary to perform these operations at compile time to elimate long startup and burn-in times.

Micronaut is one of these frameworks - Quarkus and OpenLiberty are two other major players. Micronaut hooks into the build process and generates wrapper class that hook together the IoC container, other server resources, and introspection-compatible data container classes.

When Immutables and Micronaut are being used simultaneously, both packages are generating class files at compile-time and I found it hard to make them play nice.

### What didn't work

I started with the most basic maven configuration for both the Immutables and Micronaut processors

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <version>3.8.1</version>
    <configuration>
        <annotationProcessorPaths>
            <annotationProcessorPath>
                <groupId>org.immutables</groupId>
                <artifactId>value</artifactId>
                <version>${immutables.version}</version>
            </annotationProcessorPath>
            <annotationProcessorPath>
                <groupId>io.micronaut</groupId>
                <artifactId>micronaut-inject-java</artifactId>
                <version>${micronaut.version}</version>
            </annotationProcessorPath>
            <annotationProcessorPath>
                <groupId>io.micronaut</groupId>
                <artifactId>micronaut-validation</artifactId>
                <version>${micronaut.version}</version>
            </annotationProcessorPath>
        </annotationProcessorPaths>
        <source>16</source>
        <target>16</target>
    </configuration>
</plugin>
```

Running this compiler plugin configuration with `mvn clean package` gives an extremely cryptic error from within the JVM

```
An exception has occurred in the compiler (16). Please file a bug against the Java compiler via the Java bug reporting page (http://bugreport.java.com) after checking the Bug Database (http://bugs.java.com) for duplicates. Include your program, the following diagnostic, and the parameters passed to the Java compiler in your report. Thank you.
java.lang.AssertionError: typeSig ERROR
	at jdk.compiler/com.sun.tools.javac.code.Types$SignatureGenerator.assembleSig(Types.java:5168)
	at jdk.compiler/com.sun.tools.javac.jvm.PoolWriter$SharedSignatureGenerator.assembleSig(PoolWriter.java:298)
	at jdk.compiler/com.sun.tools.javac.jvm.PoolWriter.typeSig(PoolWriter.java:492)
```

Whenever you get the `Please file a bug against the Java compiler` error, you're in some deep shit.

Okay, what can we find for `java.lang.AssertionError: typeSig ERROR` on the internet? There's [this closed JDK bug](https://bugs.java.com/bugdatabase/view_bug.do?bug_id=JDK-8193302) that relates to annotation processing and generated classes. In the right realm, but seems like a dead end.

Other search results include a few other similar bug reports in the JDK and Lombok (also a compile-time generator tool). The error is too general. What other threads can we pull on?

Upon digging through the classes that were generated during the failed build, I find something interesting. Lets play spot the bug:

```java
package com.example.api;

import com.example.api..Address.IntrospectionRef;
import com.example.api.Address.Json;
import io.micronaut.core.annotation.AnnotationMetadata;
import io.micronaut.core.annotation.Generated;
import io.micronaut.core.beans.AbstractBeanIntrospection;
import io.micronaut.core.reflect.exception.InstantiationException;
import io.micronaut.core.type.Argument;
```

The first import statement has **2** dots after the root package name 🤦. This is a decompiled class file, but nonetheless that seems like a promiximate cause.

The Micronaut bible has a section on [how to integrate Lombok](https://docs.micronaut.io/latest/guide/index.html#lombok) into a project. The advice is that the Lombok annotation processor must come before the Micronaut ones.

```xml
<annotationProcessorPaths combine.self="override">
  <path>
    <!-- must precede micronaut-inject-java -->
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <version>1.18.12</version>
  </path>
  <path>
    <groupId>io.micronaut</groupId>
    <artifactId>micronaut-inject-java</artifactId>
    <version>${micronaut.version}</version>
  </path>
    <path>
    <groupId>io.micronaut</groupId>
    <artifactId>micronaut-validation</artifactId>
    <version>${micronaut.version}</version>
  </path>
</annotationProcessorPaths>
```

I was already doing this, so clearly the strategy doesn't transfer to Immutables. The maven-compiler-plugin documenation and/or stackoverflow says that the plugin _should_ do multiple passes of processing when new classes get generated and that everything should work great, but it clearly wasn't.

I just wanted this to work and didn't care much about why it wasn't, so what if I could run the two processors completely separately?

### What finally worked

While it might seem brief in this post, I did spend a few days working through many iterations of configurations.

The final approach was to separate the Immutables class generation step completely from the Micronaut generation step. Immutables can generate its classes without knowing that Micronaut exists, and Micronaut can do its processing with the data containers it needs already in hand.

Much of the reason this was decently easy in the end is because Maven is great. Lots of people think its verbose. I think it has a small learning curve but its model is ultimately powerful for whatever you need.

The `maven-compiler-plugin` has a `proc` configuration field that controls when annotation processors get run. The `only` value means that during the execution of the plugin, only annotation processing will occur and no compilation will occur, letting us run annotation processing independently of compilation.

```xml
<executions>
    <execution>
        <!-- Run immutables processing prior to micronaut processing in order to prevent incompatibilities -->
        <id>process-annotations</id>
        <goals>
            <goal>compile</goal>
        </goals>
        <phase>generate-sources</phase>
        <configuration>
            <proc>only</proc>
            <showWarnings>true</showWarnings>
            <annotationProcessorPaths>
                <annotationProcessorPath>
                    <groupId>org.immutables</groupId>
                    <artifactId>value</artifactId>
                    <version>${immutables.version}</version>
                </annotationProcessorPath>
            </annotationProcessorPaths>
            <annotationProcessors>
                <annotationProcessor>org.immutables.processor.ProxyProcessor</annotationProcessor>
            </annotationProcessors>
        </configuration>
    </execution>
</executions>
```

Adding the execution above to the `maven-compiler-plugin` definition did the trick.

A quick translation of the above XML:

1. During the `generate-sources` build phase, execute the maven-compiler-plugin. Crtically this build phase is prior to the compile phase in which Micronaut is doing its own work.
2. Only perform annotation processing via the `<proc>only</proc>` setting
3. Run an Immutables annotation processor, specifically the `ProxyProcessor` which is the default.

Upon another `mvn clean package` I get two executions of the compiler plugin. The first `process-annotations` is the additional execution we configured for Immutables. The second fully compiles the application and includes the Micronaut processor.

```
dan@main-computer:~/example/api$ mvn clean package
[INFO] Scanning for projects...
[INFO]
[INFO] ------------------------< com.example.api:api >-------------------------
[INFO] Building api 0.1
[INFO] --------------------------------[ jar ]---------------------------------
[INFO]
[INFO] --- maven-clean-plugin:2.5:clean (default-clean) @ api ---
[INFO] Deleting /home/dan/example/api/target
[INFO]
[INFO] --- maven-compiler-plugin:3.8.1:compile (process-annotations) @ api ---
[INFO] Changes detected - recompiling the module!
[INFO] Compiling 229 source files to /home/dan/example/api/target/classes
[INFO]
[INFO] --- maven-resources-plugin:3.1.0:resources (default-resources) @ api ---
[INFO] Using 'UTF-8' encoding to copy filtered resources.
[INFO] Copying 13 resources
[INFO]
[INFO] --- maven-compiler-plugin:3.8.1:compile (default-compile) @ api ---
[INFO] Changes detected - recompiling the module!
[INFO] Compiling 229 source files to /home/dan/example/api/target/classes
[INFO]
```

## In short conclusion

I wrote this because I love both of these packages but found no documentation on the internet for how to integrate them. Maybe someone will find it useful.

There may be a more maven-appropriate to get to the same outcome. As someone who only wanted this to work, I think this was a fine outcome. It's straightforward and got me what I wanted.
