## What is Cloud Computing?

What does cloud computing mean to you?

Cloud computing has five essential characteristics.

1. **On-demand, self-service:** You request a resource, and within seconds or minutes, the resource is provisioned and available to you.
2. **Anytime, anywhere access**
3. **Resource pooling:** Cloud providers have massive infrastructure that is shared among customers to achieve cost efficiency. AWS has well over a million customers. AWS maintains and manages this infrastructure.
4. **Metered billing, pay-as-you-go:** IT infrastructure is treated as a service. You pay only for the resources you provision while they exist. Once you're done, deprovision the resource and you won't be billed for it anymore.
5. **Rapid elasticity:** You can automatically add or remove cloud resources based on need to balance performance, availability, and cost.

There are multiple public cloud service providers: Azure, AWS, Google Cloud, Alibaba, and more.

## What are the benifits of Cloud Computing?

- Reduce IT costs
  - Organisations no longer need large upfront costs to invest in their infrastructure (or renewals/replacements) but instead only pay for what they use.
- Increased agility
  - The ability to quickly provision on-demand services in the cloud can drastically reduce delivery times of software enabling business to quickly adapt and get products to market faster than ever before.
- Improved security
  - The ability to leverage the security provided by cloud providers is invaluable.
- No more end-of-life concerns
  - With cloud, the concers of out of date or broken hardware are passed to the provider. As a consumer you will have access to modern hardware without worrying about what happens when it breaks or becomes outdated.
- Consolidation of data centers
  - No need to maintain your own data centers anymore!
- Scalability
  - Instantly scale up and down so that you only use and pay for what you require.
- Environmental benefits
  - In a Microsoft study in 2020, it was found that moving to the cloud can be up to 93% more energy efficient than traditional on-premise data centres.
- Distribution
  - Cloud infrastructure can be deployed in different geographical locations to provide better service and resiliance

## Blockers

> **Group Activity**: In break-out rooms, discuss: What are the potential blockers a business might find when considering moving to the cloud.

There can be many blockers on the road to the cloud and migrations need to be carefully planned and considered. Let's have a look at a few potential blockers:

- Legacy systems
  – is anything holding you back?
- Do you have the skills required?
  - Does your team have the skills and the new mindset required?
- Regulations
  - will you experience problems with regulatory requirements, such as where your clients require their data to be stored?
- Cloud governance and change control
  - how will you find a balance of business agility and control?
- Ongoing management
  - how will you support your day-to-day operations? Internal/Outsource
- Service optimisation and monitoring
  - how will you monitor your cloud spend and optimise it?

## What is Cloud Infrastructure?

Cloud infrastructure is the name given to the components needed for cloud computing.
The main harware components of cloud infrastructure are networking equipment, servers and data storage.
Cloud infrastructure also includes a hardware abstraction layer that enables the virtualization of resources and helps to drive down costs through economies of scale.Think of cloud infrastructure as the tools needed to build a cloud. In order to host services and applications in the cloud, you need cloud infrastructure.

### Student Activity

The [AWS Cloud Products page](https://aws.amazon.com/products/?aws-products-all.sort-by=item.additionalFields.productNameLowercase&aws-products-all.sort-order=asc&awsf.re%3AInvent=*all&awsf.Free%20Tier%20Type=*all&awsf.tech-category=*all) has a full listing of all AWS products and services (over 240!)

If you want to run containers on AWS, what services might you use?

What about a SQL database?

Have you heard of any of these services? Do you currently use them?

## How Is This Possible? (15 min) - Slide 6

There are two key concepts here:

- Virtualization
- Containerization

### Virtualization

Virtualization is the division of _physical_ computing resources. It's what makes cloud computing possible.

Through software called a _hypervisor_, virtualization slices the physical resources of a server (such as the RAM, CPU, and storage) and turns them into virtual resources. It's the technology that we are using right now to split the resources of your laptops to run the Virtual Box machines for this course.

A physical server that's running a hypervisor is referred to as a virtual **host**.

Virtual **guests** run on a virtual host that provides all of the physical resources to the virtual machine to run the operating system and applications. As far as these applications and the OS are concerned, they are not aware if they are running on a VM or an actual physical server.

A **virtual machine** (VM) is a software-based instance of a physical server running on a hypervisor where a guest operating system has access to emulated virtual hardware.

### Containerization

So, how does containerization relate to virtualization?

A container is operating system-level virtualization where the OS kernel provides isolated user spaces to run specific applications.

Instead of slicing physical resources, a container engine such as Docker slices operating system resources: process namespace, the network stack, the storage stack, and file system hierarchy. Every container gets its process IDs and root file system. As a result, containers are much more lightweight than VMs.

![vm-containers](../images/vms-containers.png)
[Source](https://www.docker.com/what-container#/package_software)

We'll spend a lot more time talking about containers when we get into Docker and microservices, but they're also important in supporting cloud computing.

**_SLIDE 10_**

<details>
	<summary>Check: What is the biggest difference between virtualization and containerization?</summary>

- In a **virtualized** environment, each virtual machine has its own guest OS.
- In a **containerized** environment, the operating system lives on the physical server and the OS resources are split across each container.

</details>

---
