# eSchool Azure Deployment

A full infrastructure-as-code deployment of the [eSchool](https://github.com/yurkovskiy/eSchool) Java web application on Azure, using Terraform for infrastructure provisioning and Bash for automation.

---

## Architecture

```
Internet
    │
    ▼
VM1 (eschool-vm1) ── port 22   SSH
    │             ── port 8080  eSchool app (Tomcat)
    │
    ▼ port 3306 (internal only)
VM2 (eschool-vm2)
    └── MySQL database
```

Both VMs share:
- Resource Group: `eschool-rg`
- Virtual Network: `eschool-vnet` (`10.0.0.0/16`)
- Subnet: `eschool-subnet` (`10.0.1.0/24`)
- NSG: `eschool-network-sg`

---

## Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- SSH key at `~/.ssh/id_rsa.pub` — generate with:
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
```

---

## NSG Rules

| Rule | Port | Source | Purpose |
|---|---|---|---|
| allow-ssh | 22 | `*` | SSH into both VMs |
| allow-tomcat | 8080 | `*` | Access eSchool app from browser |
| allow-mysql | 3306 | `10.0.1.0/24` | VM1 connects to MySQL on VM2 |
