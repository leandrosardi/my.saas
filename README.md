
## IMPORTANT: THIS FRAMEWORK IS STILL UNDER CONSTRUCTION

---


![GitHub issues](https://img.shields.io/github/issues/leandrosardi/my.saas) ![GitHub](https://img.shields.io/github/license/leandrosardi/my.saas) ![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/leandrosardi/my.saas) ![GitHub last commit](https://img.shields.io/github/last-commit/leandrosardi/my.saas)

![logo](./public/core/images/logo.png)

# MySaaS - Open Source SaaS Platform - Extensible and Scalable.  

**MySaaS** is an open-source, extensible and scalable platform for develop your own Software as a Service (SaaS), e-Commerce, Education Platform, Social Network, Forum or any kind of memberships based product.

![Example of What Can You Create with My.SaaS](./docu/thumbnails/dashboard.png)

## Getting Started

1. On Ubuntu 20.04, download the script for installing our **standard environment**:

```
wget https://raw.githubusercontent.com/leandrosardi/environment/main/sh/install.ubuntu.20_04.sh
```

2. Install **my.saas**:

Switch to `root` and run this command:

```
bash install.ubuntu.20_04.sh <hostname> <password>
```

- A new user `blackstack` will be added to your operative system, with the password provided in the command line.

- The `hostname` of your computer will be changed too.

3. Switch user to `blackstack`.

4. Install and run your first SaaS:

```
saas deploy ssh=blackstack@<password>@localhost:22
```

The following (and very simple architecture) has been installed in your computer:

_(image)_

5. Visit your SaaS at [http://127.0.0.1:3000](http://127.0.0.1:3000).


Recommended readings:

- [References Architectures](/docu/00.reference-architectures.md).

- [Command Line Interface](/docu/00.command-line-interface.md).

---

## IMPORTANT: THIS FRAMEWORK IS STILL UNDER CONSTRUCTION

