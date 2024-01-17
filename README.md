![GitHub issues](https://img.shields.io/github/issues/leandrosardi/my.saas) ![GitHub](https://img.shields.io/github/license/leandrosardi/my.saas) ![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/leandrosardi/my.saas) ![GitHub last commit](https://img.shields.io/github/last-commit/leandrosardi/my.saas)

**THIS PROJECT IS UNDER CONSTRUCTION**

![logo](./public/core/images/logo.png)

# MySaaS - Open Source SaaS Platform - Extensible and Scalable.  

**MySaaS** is an open-source, extensible and scalable platform for develop your own SaaS, e-Commerce, Education Platform, Social Network, Forum or any kind of memberships based product.

![Example of What Can You Create with My.SaaS](./docu/thumbnails/dashboard.png)

## Features

Here is a full list of the MySaaS features:

**Fast Front-End Coding**

- :heavy_check_mark: Vast pool of JavaScript components for an imporved UX.
- :heavy_check_mark: Vast pool of CSS entities for a nice UI.
- :heavy_check_mark: Funnel configuration with JSON descriptors.

**Deployment Automation:**

- :heavy_check_mark: Automated installation CLI command.
- :heavy_check_mark: Automated deployment CLI command.
- :heavy_check_mark: Automated backing up and restoring of secret files that you can't store in repositories  ([DropBox](https://www.dropbox.com)).

**Scalability**

- :heavy_check_mark: Infrasctructure as a Code (IaaC) capabilities for running a mesh of offline processes.
- :heavy_check_mark: Scalable architecture: 
	- [AWS EC2](https://aws.amazon.com/ec2/) for scaleble webservers;
	- [Dropbox API](https://aws.amazon.com/ebs/) for elastic storage; and 
	- [CockroachDB](https://www.cockroachlabs.com/) for scalable and serverless database.

**End-Users Management**

- :heavy_check_mark: Transactional emails ([Postmark](https://postmarkapp.com/)).
- :heavy_check_mark: PayPal integration for Invoicing & Payments Processing ([I2P](https://github.com/leandrosardi/i2p)).

**Extensibility**

- :heavy_check_mark: Easy modules development.
- :heavy_check_mark: Advanced JavaScript components:
	- [Filters.js](https://github.com/leandrosardi/filtersjs);
	- [Templates.js](https://github.com/leandrosardi/templatesjs); 
	- [Editables.js](https://github.com/leandrosardi/editablesjs); 
	- [Timelines.js](https://github.com/leandrosardi/templatesjs); 
	- [Progress.js](https://github.com/leandrosardi/progressjs);
	- [Lists.js](https://github.com/leandrosardi/listsjs); and
	- [Datas.js](https://github.com/leandrosardi/datasjs).

## Documentation

Many chapters are still pending of writing.

I will be adding one new chapter week by week, so follow this project and get notified when new documentation is released.

### Basic

01. [Installation](./docu/01.Installation.md)
02. [Configurations](./docu/02.configurations.md)
03. [Secret Files Management](./docu/03.secret-files-management.md)
04. [Deployment](./docu/04.deployment.md) 
05. [Transactional Emails](./docu/05.transactional-emails.md) 
06. Screens Development
07. Invoicing and Payments Processing
08. System Owner
09. Accounts Management
10. [Security](./docu/11.security.md)

### Advanced

09. User Storage
10. Access Points Publishing
11. Single-Thread Backend Processing
12. Multi-Thread Backend Processing
13. Extensibility
14. Available Extensions
15. Available UI Components

## Further Work

01. Complete documentation for all features as of version 1.5.6.
02. affiliates tracking, for managing resellers and pay commission;
03. domain aliasing, for licencing your site to other companies;
04. abuse preventing, by tracking user's network and browser fingertings;
05. shadow profiling [[1](https://en.wikipedia.org/wiki/Shadow_profile)], for sales optimizations and client retention;
06. Affiliates Tracking Extension
07. White-Labeling Features
08. Custom Alerts
09. Screens As a Code
10. Improve Funnel Configuration
	- add descriptor about the email marketing automation
	- add descriptor about which transactional emails activate for this funnel
	- add A/B testing of screens (landing, offer, plans, etc)
