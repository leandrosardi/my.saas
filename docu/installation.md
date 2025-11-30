## Installation

MySaaS is currently supporting **Ubuntu 20.04** and **Ubuntu 22.04**.

### 1. Install the `saas` command

You need to [install the BlackOps's `saas` commnad](https://github.com/leandrosardi/blackops?tab=readme-ov-file#install-the-saas-command) in your local environment.

### 2. Download BlackOps operations

Some `.op` files are required to install **My.SaaS** using [BlackOps](https://github.com/leandrosardi/blackops).

```
cd ~ && \

wget https://raw.githubusercontent.com/leandrosardi/blackops/refs/heads/main/ops/hostname.op && \

wget https://raw.githubusercontent.com/leandrosardi/blackops/refs/heads/main/ops/mysaas.install.ubuntu_22_04.base.op && \

wget https://raw.githubusercontent.com/leandrosardi/blackops/refs/heads/main/ops/mysaas.install.ubuntu_22_04.postgresql.op
```

### 3. Install the Environment

```
saas install --ssh=root:2404@127.0.0.1:22 \
 --config=./BlackOpsFile \
 --name=mysaas \
 --postgres_database=mysaas \
 --postgres_username=mysaas \
 --postgres_password=mysaas \
 --install_ops=hostname.op,mysaas.install.ubuntu_22_04.base.op,mysaas.install.ubuntu_22_04.postgresql.op
```


### 4. Deploy the Software

```
saas deploy --ssh=root:2404@127.0.0.1:22 \
 --config=./BlackOpsFile \
 --name=mysaas \

 --postgres_username=mysaas \
 --postgres_password=mysaas \

 --install_ops=mysaas.deploy.ubuntu_22_04.base.op,mysaas.install.ubuntu_22_04.postgresql.op
```

### Run Migrations

```
saas migrate --local \
 --config=./BlackOpsFile \
 --name=mysaas \

 --ssh_username=mysaas \
 --ssh_password=<password for mysaas user> \
 --ssh_root_password=<current root password> \

 --postgres_username=mysaas \
 --postgres_password=<password for mysaas user> \
```
