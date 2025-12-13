## Installation

Follow the steps below on a **fresh** installation of **Ubuntu 22.04**.

### 1. Install the `saas` command

You need to [install the BlackOps's `saas` commnad](https://github.com/leandrosardi/blackops?tab=readme-ov-file#install-the-saas-command) in your local environment.

### 2. Download the `BlackOpsFile`

This is a basic configuration for installing a local environment.

If you want to know more about `BlackOpsFile`, refer to [this tutorial](https://github.com/leandrosardi/blackops?tab=readme-ov-file#3-configuration-files).

```
cd ~ && \
wget https://raw.githubusercontent.com/leandrosardi/my.saas/refs/heads/main/BlackOpsFile
```

### 3. Download Required Operation Scripts

Some `.op` files are required to install **My.SaaS** using [BlackOps](https://github.com/leandrosardi/blackops).

```
cd ~ && \
wget https://raw.githubusercontent.com/leandrosardi/blackops/refs/heads/main/ops/hostname.op && \
wget https://raw.githubusercontent.com/leandrosardi/blackops/refs/heads/main/ops/mysaas.install.ubuntu_22_04.base.op && \
wget https://raw.githubusercontent.com/leandrosardi/blackops/refs/heads/main/ops/mysaas.install.ubuntu_22_04.postgresql.op
wget https://raw.githubusercontent.com/leandrosardi/blackops/refs/heads/main/ops/mysaas.deploy.op
```

### 4. Setup the Enrivonmnet Variable `MYSAAS_ROOT_PASSWORD`

```
export MYSAAS_ROOT_PASSWORD=<root password of your local computer>
```

### 5. Install the Environment

The line below will install 2 nodes, **web server** (`web`) and **database server** (`db`) in your local computer.

In a production environment, `web` and `db` are hosted in different servers because of a security reasons.

```
saas install --config=./BlackOpsFile --node=* --root
```

### 6. Deploy the Software

```
saas deploy --config=./BlackOpsFile --node=web
```

### 7. Starting My.SaaS Service

_pending_

### 8. Stopping My.SaaS Service

_pending_
