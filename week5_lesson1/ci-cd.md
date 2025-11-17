# ![](https://ga-dash.s3.amazonaws.com/production/assets/logo-9f88ae6c9c3871690e33280fcf557f33.png) Continuous Integration and Delivery

## Learning Objectives

_After this lesson, students will be able to:_

- Explain what CI/CD are and the benefits of using these practices and tools.
- Understand what a CI/CD pipeline is and what it does.
- Use some common tools, plugins, and approaches to build, test, and deploy full-stack applications with a CI/CD pipeline.

## Lesson Guide

| TIMING | TYPE       | TOPIC                                                              |
| :----: | ---------- | ------------------------------------------------------------------ |
| 5 min  | Opening    | Discuss Lesson Objectives                                          |
| 20 min | Lecture    | Continuous Integration                                             |
| 20 min | Lecture    | Deploy an Application into a local kubernetes cluster with harness |
| 15 min | Lecture    | Integration Testing                                                |
| 20 min | Lecture    | Continuous Delivery                                                |
| 5 min  | Conclusion | Review/Recap                                                       |

## Opening (5 min)

Who doesn't want to save time and money? You can use continuous integration (CI) and continuous delivery (CD) to build, test, and deploy software quickly and safely, ultimately delivering value to your users more quickly.

Generally, companies begin with **continuous integration** (CI). **Continuous delivery** goes a step further than CI by automating the deployment of releases, including infrastructure and configuration changes. **Continuous deployment** goes a step further than continuous delivery by deploying every change to production automatically.

---

## Continuous Integration (20 min)

![](https://ga-instruction.s3.amazonaws.com/assets/continuous-integration/CImeme.png)

You can avoid disasters with continuous integration, which means that individual developers integrate their work into a main repository frequently - usually whenever a feature has been built. That way, you can catch integration bugs early and collaborate more quickly. _Integrating work from multiple developers_ involves, at a minimum, building and testing the application whenever a change is made by a developer (i.e., continuously). It's important to scope your development tasks properly so that frequent integration can continue and a ticket doesn't force a developer to merge a massive amount of code in one go. So Commit Small Changes Often.

### Commit Small Changes Often

This is one of the cardinal rules of CI. Developers should be committing to the mainline branch often. Changes should be as small as possible so that, when a change _breaks the build_, anyone can quickly pinpoint the specific issue.

With many changes happening all the time, a fast build process is critical so that developers get feedback about broken builds right away.

### How Will Continuous Integration Save Us Time and Money?

Like your mom always said, the early bird catches the worm. Finding bugs earlier in the **software development life cycle** (SDLC) is **much** less costly than finding bugs later.

![](https://www.isixsigma.com/wp-content/uploads/images/stories/migrated/graphics/604a.gif)

_Relative Costs to Fix Software Defects (Source: IBM Systems Sciences Institute)_

This concept is fundamental to why we do CI/CD, so let's discuss a real-world example: Ever heard of the Samsung Note 7 fiasco? Note 7 phones had a faulty battery management system that caused them to catch on fire! How much do you think Samsung would have saved if it had caught the bug in an early stage of development?

> **Answer**: This bug cost Samsung nearly $17 billion! If it had caught it earlier, it also could've saved its reputation and many headaches.

### Build and Test Your Application Automatically With a Build Pipeline

So, how do we find bugs early? By testing early and often. You really don't want to have to think too much about _when_ and _how_ to run tests. Most modern software development teams would rather run tests automatically when there's any kind of change to the code, specifically in the mainline branch where all developers integrate their code for the next release.

![](https://ga-instruction.s3.amazonaws.com/assets/continuous-integration/automate-all-the-things-small.jpeg)

A **build pipeline** is the automated process that watches for changes. When a change is detected, the build pipeline builds the application, tests it, and possibly does other stuff, too. Pipelines can have stages, and each stage can have steps. Steps in your pipeline can execute tools for various jobs like Maven, Gradle, shell scripts, and more.

> **Let's discuss**: What do you think are the three characteristics of an ideal build pipeline?

1. **Fast**: You want your build pipeline to give you near-instant feedback on whether your tests pass or fail. This is so that you can fix problems right away while you are actively thinking and working on the feature.
1. **Repeatable**: You always want to run the same process to build and test your application, and you always want to run that process in the same build environment. That will reduce the number of things that change from one build to the next so that, when bugs come up and you need to troubleshoot, there's less to worry about.
1. **Reliable**: You want to set up your build pipeline and tests so that, if there's a failure, it's because of the application being built and tested rather than a problem in your test environment or the build pipeline itself. Common issues that lead to "false positives" include bad data in your database that weren't cleaned up from the last test run, or some other kind of contention for a shared resource (such as files on a shared file system).

---

## Deploy an Application into a local kubernetes cluster with harness (40 min)

# Harness CI/ CD Platform

Harness CI/CD is a modern software delivery platform that helps development teams automate the process of getting code from development to production. Think of it as a smart conveyor belt system for your code - it takes care of testing, building, and deploying your applications automatically and safely.

The "CI" part (Continuous Integration) automatically checks code changes when developers submit their work. It runs tests to make sure nothing breaks and builds the application into a ready-to-deploy package. This is like having a very thorough quality control inspector checking every piece of work.

The "CD" part (Continuous Delivery/Deployment) handles getting that tested and packaged code into your live systems. It's like having an expert delivery service that knows exactly how to transport and install your application, whether it's going to cloud platforms like AWS or Kubernetes clusters.

What makes Harness special is its intelligent automation. Unlike older CI/CD tools that need lots of manual configuration and scripting, Harness uses AI/ML to make smart decisions. For example, it can automatically detect if a deployment is causing problems and roll it back without human intervention - like having a safety net that catches issues before they affect your users.

Harness also includes modern features like:

- Built-in security scanning to catch vulnerabilities
- GitOps support for managing infrastructure as code
- Visual pipelines that make it easy to see and configure your delivery process
- Multi-cloud support so you can deploy anywhere
- Automated rollbacks if something goes wrong

For teams learning modern software practices, Harness represents the next generation of deployment tools - making it easier and safer to get your code from development to production while following DevOps best practices.

## Integration Testing (15 min)

> **Knowledge Check**: What's the difference between unit tests and integration tests?

**Unit tests** with mocked dependencies usually run very quickly.

On the other hand, **integration tests** usually take longer to run in a pipeline. That's because it takes time for the pipeline to initialize all dependencies for integration tests. That's why you'll have **staged pipelines**, where unit tests run first to give you quick feedback. Integration tests run next, possibly in a completely different testing/QA environment.

### Finding Bugs That Unit Tests Won't Find

Sometimes, the whole is less than the sum of its parts. Writing unit tests to test your components is great, but other kinds of bugs can pop up when changes from several developers working on a codebase are merged, or when components are integrated in the broader application. Even if all of the unit tests pass, when you bring the units together, they may not work together as intended.

> **Knowledge Check**: What might be some common sources of integration bugs?

1. **Merge conflicts**: When merging code from several developers into a single branch, there are sometimes conflicts that can't be merged automatically. A human will need to step in and merge manually. This manual step can lead to bugs if not done perfectly. The larger the change, the more likely you are to encounter merge conflicts, so try to keep commits and PRs small.
1. **Using real components as dependencies** : Integration tests will usually aim to use _real components as dependencies_ instead of mocking the dependencies like we do in unit tests. By using real components, such as databases, application servers, containers, etc., integration tests are likely to surface problems that unit tests (with mocked components) simply wouldn't be capable of exposing.
1. **Incompatible interfaces or component behaviors** : This is the broadest category of integration bugs. Unit tests may pass for individual components, but integration tests (operating across multiple components) may fail if the components simply weren't designed to play well with each other. For example, one component (a REST endpoint) may accept dashes/hyphens in a user's last name, while another (a database table) might only accept alphanumeric characters. Passing a user's last name with hyphens to the REST endpoint and then to the database would fail an integration test.

### Integration Testing Frameworks and Tools

Thankfully, there are frameworks and tools to automate integration testing and, in particular, deal with the initialization of dependencies such as databases, application servers, containers, infrastructure, etc. Typical integration tests will rely on a number of these tools and frameworks to initialize a database with test data, initialize infrastructure and/or container(s) for your application, initialize your application (or sometimes just a subset of the components to test), and then run tests. After running the test suite, the dependencies should be shut down gracefully and/or cleaned up.

Common integration testing tools include [DbUnit](http://dbunit.sourceforge.net/), [TestNG](https://testng.org/doc/), [Selenium](https://www.seleniumhq.org/), [Arquillian](http://arquillian.org/), and [Spring Testing](https://docs.spring.io/spring/docs/5.2.0.M1/spring-framework-reference/testing.html#integration-testing), among others.

We won't cover all of these in this course, but we wanted to make you're aware that they exist and provide you with links for further reading on your own time.

---

## Continuous Delivery (20 min)

![](https://ga-instruction.s3.amazonaws.com/assets/continuous-integration/deliver-continuouslysmall.png)

Continuous delivery (CD) is an approach that builds on continuous integration. CD ensures that our code is always in a deployable state, even with thousands of developers making changes regularly. Teams produce software in short cycles so they can release the software whenever necessary. CD helps teams save time and money and makes delivering changes less risky.

### Development, Staging, and Production Environments

In most enterprises, there are several different environments where a new version of the application (a release candidate) needs to be built, tested, and/or reviewed before deployment to the production environment.

1. **Build**: Oftentimes, you'll see a build environment where the code is compiled and application artifacts are constructed (e.g., an rpm, war file, or image). Sometimes, unit tests will run here, too. Once built, the artifact is pushed to a repository and should never change.
1. **Test**: The artifact would then be pulled from the repository and installed in a test environment for integration testing, performance testing, and other testing purposes.
1. **Stage**: A staging environment is the last environment before promoting the artifact to production. That's where more tests can be run (automated or not) and/or human users may perform some kind of acceptance testing.

In CI/CD, this whole process — including deployments from build to test to stage and (optionally) to prod — should be automated by your build pipeline. Here's an example of what that pipeline might look like in the popular CI/CD tool, Jenkins:

![](https://raw.githubusercontent.com/marcingrzejszczak/jenkins-pipeline/master/docs/jenkins/pipeline_finished.png)

_[Full Pipeline View](https://github.com/marcingrzejszczak/jenkins-pipeline/blob/master/README.adoc)_

### The Other CD

In some companies, there will need to be a final approval or review by a human before software can actually be deployed to production. If that isn't the case, you can also fully automate that final deployment step (a practice known as **continuous deployment**).

_Continuous delivery_ ensures that code can be rapidly and safely deployed to production and that applications function as expected through rigorous automated testing.

_Continuous deployment_ is the next step of continuous delivery: Every change that passes the automated tests is deployed to production automatically.

> **Knowledge Check**: When is continuous deployment helpful? When might you _not_ want to use continuous deployment?

---

## Conclusion (5 min)

Phew! Doesn't all of this information about DevOps make you grateful for all the operations that keep your favorite software (and memes) running smoothly?

With a partner, discuss the following prompts:

- Explain how continuous delivery and continuous integration help teams save time and money.
- Define:
  - The build pipeline
  - Build, test, and stage environments

## Resources

- [Continuous Delivery](https://continuousdelivery.com/)</a>
- [An Introduction to Continuous Integration, Delivery, and Deployment](https://www.digitalocean.com/community/tutorials/an-introduction-to-continuous-integration-delivery-and-deployment)</a>
- [Defect Prevention: Reducing Costs and Enhancing Quality](https://www.isixsigma.com/industries/software-it/defect-prevention-reducing-costs-and-enhancing-quality/)</a>
- [Continuous Integration](https://www.martinfowler.com/articles/continuousIntegration.html)
- [Dev Leaders Compare Continuous Delivery vs. Continuous Deployment vs. Continuous Integration](https://stackify.com/continuous-delivery-vs-continuous-deployment-vs-continuous-integration/)
