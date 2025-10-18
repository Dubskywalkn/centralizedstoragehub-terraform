# LedgerLock – Private Finance Doc Hub on Azure (Terraform)

Centralizes finance documents in **Azure Blob (GZRS)** behind **Private Endpoints** with **Managed Identity + RBAC**, a single **ingestion VM** (+ cold standby), and **VM backups**. Sized for a small team (15–20 ppl; ~5 finance users).  
**Focus:** simple, secure, cost-effective. No public endpoints. No keys in code.

---

## 🧭 Problem → Solution

**Problem:** Finance docs were scattered across QuickBooks/Stripe/email/Drive and laptops → no single source of truth, risky sharing, weak recovery.  
**Solution:** A private-by-default ingestion backbone: **VM1** ingests on schedule and writes to **Blob** via **Private Endpoint** using **Managed Identity**. **VM2** is **cold standby**. Storage uses **GZRS + Versioning + Soft Delete + Lifecycle**. **VM backups** via Recovery Services Vault. All infra via **Terraform**.

---

## 🏗️ Architecture

```mermaid
graph LR
  subgraph Azure
    subgraph VNet[VNet 10.10.0.0/16]
      subgraph App[app-subnet 10.10.1.0/24]
        VM1[VM1 Active<br/>System-assigned MI<br/>Cron ingest]
        VM2[VM2 Cold Standby (deallocated)]
      end
      subgraph PE[pe-subnet 10.10.2.0/24]
        PEP[(Private Endpoint<br/>blob subresource)]
      end
      PDNS[(Private DNS Zone<br/>privatelink.blob.core.windows.net)]
    end
    SA[(Storage Account<br/>GZRS | Versioning | Soft Delete | Lifecycle)]
    RSV[(Recovery Services Vault<br/>Daily VM backups)]
  end

  Ext[QuickBooks/Stripe/Email/Drive<br/>(Exports/Inputs)] --> VM1
  VM1 -->|MI over PE| PEP --> SA
  VM2 -. standby .-> PEP
  PDNS --- PEP
  VM1 -. backup .-> RSV










Design choices

Private data plane (PE + PDNS); public access disabled on Storage

Managed Identity + RBAC (least privilege; no keys)

VM1 active; VM2 cold standby in an Availability Set

Storage GZRS, Versioning, Soft Delete, Lifecycle (Cool/Archive)

Recovery Services Vault backs up VMs






✨ Features

Security: private endpoints, no public blob access, least privilege via MI + RBAC

Reliability: Availability Set; fast manual failover to cold standby

Governance: GZRS, versioning/soft delete, lifecycle policies

IaC: modular Terraform (Network, Storage, PE, Compute, RBAC, Backup)

Observability: simple KQL for heartbeat/ingest errors (Log Analytics)



📂 Repo layout
/Modules
  /Network         # vnet, subnets, NSG
  /Storage         # GZRS, versioning, soft delete, lifecycle
  /PrivateEndpoint # blob PE + Private DNS
  /Compute         # VM1 active, VM2 cold standby, Availability Set, MI
  /RBAC            # MI -> Blob Data Contributor
  /Backup          # Recovery Services Vault + policy
main.tf
variables.tf
outputs.tf
terraform.tfvars.example   # placeholders only (safe to commit)


🔧 Pre-requisites

Terraform ≥ 1.5, AzureRM provider ≥ 3.100

Azure subscription (az login)

RSA public SSH key for the admin user

(Optional) Log Analytics workspace if you wire monitoring




🚀 Quick start
# 1) clone & cd


git clone https://github.com/Dubskywalkn/centralizedstoragehub-terraform.git
cd centralizedstoragehub-terraform

# 2) copy example vars (edit with your values; DO NOT commit real tfvars)
cp terraform.tfvars.example terraform.tfvars

# 3) init & deploy
terraform init
terraform apply


One-time portal step: create containers (keeps bootstrap secure):

qbo, stripe, drive, email, published


Then (if using per-container scoping) re-apply RBAC:

terraform apply -target=module.RBAC_vm1 -target=module.RBAC_vm2

⚙️ terraform.tfvars.example (edit your copy)
# region/resource group
resource_group_name       = "rg-ledgerlock"
location                  = "eastus"

# networking
vnet_name                 = "vnet-ledgerlock"
vnet_cidr                 = "10.10.0.0/16"
app_subnet                = "app-subnet"
app_subnet_cidr           = "10.10.1.0/24"
pe_subnet                 = "pe-subnet"
pe_subnet_cidr            = "10.10.2.0/24"

# compute
admin_username            = "azureuser"
admin_ssh_public_key      = "ssh-rsa AAAA...example..."
vm_size                   = "Standard_B2s"
enable_standby_vm         = true

# storage
storage_account_name      = "stledgerlock"
enable_versioning         = true
enable_soft_delete        = true

# security
ssh_source_address_prefix = "203.0.113.10/32"   # example only (replace locally)


Security hygiene: don’t commit your real /32. Keep it in your local terraform.tfvars.

✅ Verify (smoke tests)

From VM1:

nslookup <storage-account-name>.blob.core.windows.net   # -> 10.x (PE)
az login --identity
az storage container list --account-name <storage-account-name> --auth-mode login -o table


Optionally upload a file using MI (Python/CLI) and confirm it lands in a container.
From your laptop (after removing your IP from allowlist), Storage Explorer should fail → expected.

🔒 Security notes

Storage: Public network access = Disabled

NSG: inbound 22/tcp from your /32 only; outbound 443 only

Managed Identity + Storage Blob Data Contributor (account or per-container scope)

Consider RSV private endpoints and set RSV public access = Deny later

🧯 DR & Failover (quick playbook)

Same-region failover (minutes):

Start VM2 (cold standby)

Flip internal Private DNS A record (e.g., ingest.internal) to VM2

Verify MI + blob upload

Regional incident (hours, rare):

Storage account failover (GZRS)

Deploy VNet + PE + PDNS in paired region (Terraform)

Restore VM from Recovery Services Vault

💵 Cost snapshot

VM1 small + disks: tens $/mo; VM2 deallocated ≈ $0 compute

Storage (GZRS): main driver; lifecycle → Cool/Archive cuts cost

PE/DNS/Backup/Logs: small, predictable
Annual ballpark: ~$1k–$4k depending on TB stored.

🧪 Monitoring (KQL examples)

VM heartbeat (last 15m)

Heartbeat
| where TimeGenerated > ago(15m)
| summarize last_seen = max(TimeGenerated) by Computer, Category


Simple ingest error markers

Syslog
| where ProcessName in ("CRON","python")
| where SyslogMessage has_any ("ingest_failed","Traceback")

🛣️ Roadmap (nice-to-haves)

Serverless ingestion (Functions/Container Apps Jobs with VNet) if volume spikes

Second LRS account + object replication + immutability (auditor-driven)

RSV private endpoints + public access deny

One-click failover (Automation runbook/webhook)

