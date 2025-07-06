**⚠️ Under Construction** 
This project is still in active development. Features, APIs, and documentation may be incomplete or change at any time without notice. Use at your own risk and feel free to submit issues or pull requests!

---

# My.SaaS

![GitHub issues](https://img.shields.io/github/issues/leandrosardi/my.saas) ![GitHub](https://img.shields.io/github/license/leandrosardi/my.saas) ![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/leandrosardi/my.saas) ![GitHub last commit](https://img.shields.io/github/last-commit/leandrosardi/my.saas)

![logo](./public/core/images/logo.png)

## Getting Started

### Install the `saas` command

You need to [install the BlackOps's `saas` commnad](https://github.com/leandrosardi/blackops?tab=readme-ov-file#install-the-saas-command) in your local environment.

### Download BlackOps operations

```
cd ~ && \
wget https://raw.githubusercontent.com/leandrosardi/blackops/refs/heads/main/ops/hostname.op && \
wget https://raw.githubusercontent.com/leandrosardi/blackops/refs/heads/main/ops/mysaas.install.ubuntu_22_04.base.op && \
wget https://raw.githubusercontent.com/leandrosardi/blackops/refs/heads/main/ops/mysaas.install.ubuntu_22_04.postgresql.op
```

### Download the `BlackOpsFile`

```
cd ~ && \
wget https://raw.githubusercontent.com/leandrosardi/my.saas/refs/heads/main/BlackOpsFile
```

### Run the `saas` command

```
saas install --root --local \
 --config=./BlackOpsFile \
 --name=mysaas \
 --ssh_username=mysaas \
 --ssh_password=<password for mysaas user> \
 --ssh_root_password=<current root password> \
 --install_ops=hostname.op,mysaas.install.ubuntu_22_04.base.op,mysaas.install.ubuntu_22_04.postgresql.op
```

## Further Work

- Installation
- Visitors tracking - Download/update `GeoLite2-City.mmdb` (https://github.com/P3TERX/GeoLite.mmdb)
- Extensibility
- UI Components - tags, lists, etc.
- API Calls, API Calls Tracking and API Calls Quota
- Monitoring Extensions: Super-User, monitoring, accessing other people accounts
- Invoicing and Payments Processing
- Content Management System
- Transactional emails
- Asyncronius processing
- Domain aliasing & `account.id_user_owner` field.
- Affiliates tracking & `account.id_user_referral` field.
