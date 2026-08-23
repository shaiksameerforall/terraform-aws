# Terraform Complete Study Guide (Beginner → Advanced)

A structured, easy-to-follow path to learning Terraform from scratch to job-ready level.

---

## How to Use This Guide

Follow the modules in order. Each module has:
- **Concept** — what it is and why it matters
- **Example** — real code you can run
- **Practice Task** — something to try yourself

Spend 1-2 days per module if you're new to DevOps/Cloud. If you already know cloud basics (AWS/Azure/GCP), you can move faster — 3-5 days total is realistic.

---

## Module 1: Foundations

### 1.1 What is Infrastructure as Code (IaC)?
Instead of manually clicking around in AWS/Azure consoles to create servers, networks, and databases, you write **code** that describes what you want, and a tool builds it for you.

Benefits:
- Version-controlled infrastructure (Git)
- Repeatable, consistent environments
- Easy to review changes before applying them
- Enables automation (CI/CD pipelines)

### 1.2 What is Terraform?
Terraform (by HashiCorp) is an **open-source IaC tool** that lets you define infrastructure using a declarative language called **HCL** (HashiCorp Configuration Language). It works across almost every cloud provider (AWS, Azure, GCP, Kubernetes, and 100+ others).

**Declarative** means: you describe the *end state* you want, not the steps to get there. Terraform figures out the steps.

### 1.3 Terraform vs Other Tools
| Tool | Type | Notes |
|---|---|---|
| Terraform | Declarative, multi-cloud | Most popular, huge ecosystem |
| CloudFormation | Declarative, AWS-only | Native AWS tool |
| Ansible | Procedural, config mgmt | Good for app config, not just infra |
| Pulumi | Declarative, uses real code (Python/TS) | Newer alternative to Terraform |

### 1.4 Installation
```bash
# macOS
brew install terraform

# Windows (via Chocolatey)
choco install terraform

# Linux (via apt, HashiCorp repo)
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Verify
terraform -version
```

**Practice Task:** Install Terraform and run `terraform -version`.

---

## Module 1.5: Windows + VS Code Setup (Step-by-Step)

This section is specifically for running Terraform on **Windows** using **VS Code**.

### 1.5.1 Install Terraform on Windows

**Option A — Using Chocolatey (recommended, easiest to keep updated)**
```powershell
# Open PowerShell as Administrator, then install Chocolatey if you don't have it:
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Then install Terraform:
choco install terraform -y
```

**Option B — Manual install**
1. Go to `developer.hashicorp.com/terraform/downloads`
2. Download the **Windows AMD64 zip**
3. Extract it to a folder, e.g. `C:\terraform`
4. Add that folder to your **System PATH**:
   - Search "Environment Variables" in Windows Start menu
   - Under "System variables" find `Path` → Edit → New → add `C:\terraform`
   - Click OK on all dialogs
5. Close and reopen any terminal, then verify:
```powershell
terraform -version
```

### 1.5.2 Install VS Code
Download from `code.visualstudio.com` and run the installer (default options are fine).

### 1.5.3 Install the Essential VS Code Extensions
Open VS Code → Extensions panel (`Ctrl+Shift+X`) → search and install:

| Extension | Publisher | Why |
|---|---|---|
| **HashiCorp Terraform** | HashiCorp | Official — syntax highlighting, autocomplete, validation, formatting |
| **HashiCorp HCL** | HashiCorp | Sometimes bundled with the above; ensures `.tf` files are recognized |
| **AWS Toolkit** (optional) | Amazon | Handy if you're deploying to AWS |
| **DotENV** (optional) | mikestead | Nice for managing `.env` files if used alongside Terraform |
| **GitLens** (optional) | GitKraken | Useful since your `.tf` files should live in Git |

Quick install via command line (Command Palette → paste each):
```
ext install hashicorp.terraform
```

### 1.5.4 Configure VS Code for Terraform
Open Settings (`Ctrl+,`) → search "format on save" → enable it. Then add this to your `settings.json` (`Ctrl+Shift+P` → "Preferences: Open User Settings (JSON)"):

```json
{
  "[terraform]": {
    "editor.defaultFormatter": "hashicorp.terraform",
    "editor.formatOnSave": true
  },
  "[terraform-vars]": {
    "editor.defaultFormatter": "hashicorp.terraform",
    "editor.formatOnSave": true
  }
}
```
This makes VS Code auto-run `terraform fmt` style formatting every time you save a `.tf` file.

### 1.5.5 Set Up Your Terminal in VS Code
Use the **built-in terminal** (`` Ctrl+` ``) instead of switching windows. Recommended: set it to PowerShell (default on Windows) or install **Windows Terminal** from the Microsoft Store for a nicer experience.

Verify everything works inside VS Code's terminal:
```powershell
terraform -version
```

### 1.5.6 Set Up Cloud Credentials (AWS example) on Windows
Install AWS CLI:
```powershell
choco install awscli -y
```
Then configure it:
```powershell
aws configure
# Enter: Access Key ID, Secret Access Key, region (e.g. us-east-1), output format (json)
```
This stores credentials in `C:\Users\<YourUsername>\.aws\credentials` — Terraform's AWS provider will automatically pick these up. **Never hardcode AWS keys inside your `.tf` files.**

### 1.5.7 Recommended Folder Structure in VS Code
```
C:\Users\<you>\terraform-projects\
  └── first-project\
       ├── main.tf
       ├── variables.tf
       ├── outputs.tf
       └── terraform.tfvars
```
Open the **folder** (not just a file) in VS Code: `File → Open Folder` → select `first-project`. This gives you the file explorer sidebar, integrated terminal in the right working directory, and Git integration all in one place.

### 1.5.8 Your First Run — Full Windows Workflow
```powershell
# In VS Code terminal, inside your project folder:
terraform init
terraform fmt          # auto-formats your code (also runs on save if configured)
terraform validate     # checks for syntax errors
terraform plan
terraform apply
```
Type `yes` when prompted to confirm.

### 1.5.9 Common Windows-Specific Gotchas
- **"terraform is not recognized as a command"** → PATH wasn't set correctly; re-check step 1.5.1, and restart VS Code fully (not just the terminal) after changing PATH.
- **Line ending warnings in Git (`LF will be replaced by CRLF`)** → harmless, but you can fix with:
  ```powershell
  git config --global core.autocrlf true
  ```
- **File paths in `file()` or `templatefile()` functions** → always use forward slashes even on Windows, e.g. `file("./scripts/init.sh")`, not backslashes.
- **PowerShell execution policy errors** when running scripts → run PowerShell as Administrator and use `Set-ExecutionPolicy RemoteSigned`.
- **Antivirus/Windows Defender** sometimes flags the Terraform binary on first run — this is a false positive; allow it if prompted.

### 1.5.10 Optional: Use WSL2 Instead
Many professional Terraform users on Windows actually run everything inside **WSL2 (Windows Subsystem for Linux)** for a smoother Linux-like experience, while still using VS Code as the editor (via the "WSL" extension, which lets VS Code edit files that live inside your Linux environment seamlessly).
```powershell
wsl --install
```
Then inside the Ubuntu shell that opens, install Terraform using the Linux `apt` instructions from section 1.4. In VS Code, install the **WSL extension**, then `File → Open Folder` and select a folder inside `\\wsl$\Ubuntu\home\<you>\...`. This is optional — the native Windows setup above works perfectly fine for learning.

**Practice Task:** Set up your VS Code environment fully using the steps above, then create and run the Module 2 "first project" example directly from VS Code's integrated terminal.

---

## Module 2: Core Concepts & First Project

### 2.1 The Building Blocks

- **Provider** – plugin that lets Terraform talk to a platform (AWS, Azure, GCP, etc.)
- **Resource** – a piece of infrastructure you want to create (an EC2 instance, an S3 bucket)
- **Data Source** – reads existing infrastructure info (doesn't create anything)
- **State** – Terraform's record of what it has created (`terraform.tfstate`)
- **Variables** – inputs to make your config reusable
- **Outputs** – values exposed after apply (e.g., an IP address)

### 2.2 Your First Configuration

```hcl
# main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web_server" {
  ami           = "ami-0c101f26f147fa7fd" # Amazon Linux 2
  instance_type = "t2.micro"

  tags = {
    Name = "MyFirstTerraformServer"
  }
}
```

### 2.3 The Core Workflow

```bash
terraform init      # Downloads providers, sets up backend
terraform plan       # Shows what WILL change (dry run)
terraform apply       # Actually creates/changes infrastructure
terraform destroy      # Deletes everything Terraform created
```

**Mental model:**
`init` → `plan` → `apply` is the loop you repeat forever. `destroy` is used to tear down when done (great for saving cloud costs in learning).

**Practice Task:** Get free-tier AWS credentials, run the above config, then `terraform destroy` when done to avoid charges.

---

## Module 3: HCL Syntax Deep Dive

### 3.1 Basic Syntax Rules
```hcl
resource "<PROVIDER_TYPE>" "<LOCAL_NAME>" {
  argument1 = "value"
  argument2 = 123
  argument3 = true

  nested_block {
    key = "value"
  }
}
```

- `PROVIDER_TYPE` = e.g. `aws_instance`, `azurerm_virtual_machine`
- `LOCAL_NAME` = your reference name within Terraform (not the cloud resource name)

### 3.2 Data Types
```hcl
# String
variable "region" {
  type    = string
  default = "us-east-1"
}

# Number
variable "instance_count" {
  type    = number
  default = 2
}

# Bool
variable "enable_monitoring" {
  type    = bool
  default = true
}

# List
variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

# Map
variable "instance_tags" {
  type = map(string)
  default = {
    Environment = "dev"
    Team        = "platform"
  }
}

# Object (structured)
variable "server_config" {
  type = object({
    instance_type = string
    disk_size     = number
  })
  default = {
    instance_type = "t2.micro"
    disk_size     = 20
  }
}
```

### 3.3 Referencing Values
```hcl
resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = var.server_config.instance_type
}

# Reference another resource's attribute
resource "aws_eip" "ip" {
  instance = aws_instance.web.id
}
```

**Practice Task:** Rewrite Module 2's config using variables for `ami`, `instance_type`, and `region`.

---

## Module 4: Variables, Outputs & Locals

### 4.1 Variables (Inputs)
```hcl
# variables.tf
variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t2.micro"
}
```

Ways to set variable values (priority order, highest wins):
1. `-var` flag: `terraform apply -var="instance_type=t2.small"`
2. `-var-file`: `terraform apply -var-file="prod.tfvars"`
3. `terraform.tfvars` file (auto-loaded)
4. Environment variables: `TF_VAR_instance_type=t2.small`
5. Default value in the variable block

```hcl
# terraform.tfvars
instance_type = "t2.small"
region        = "ap-south-1"
```

### 4.2 Outputs
```hcl
# outputs.tf
output "instance_public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}
```
```bash
terraform output                  # show all outputs
terraform output instance_public_ip  # show one
```

### 4.3 Locals (computed/reusable values)
```hcl
locals {
  project_name = "myapp"
  common_tags = {
    Project     = local.project_name
    ManagedBy   = "Terraform"
    Environment = var.environment
  }
}

resource "aws_instance" "web" {
  # ...
  tags = local.common_tags
}
```

**Practice Task:** Add a `terraform.tfvars` file, and create an output showing the instance ID and public IP.

---

## Module 5: State Management (Critical Topic!)

### 5.1 What is State?
Terraform keeps a JSON file (`terraform.tfstate`) mapping your config to real-world resources. This is how it knows what to update/destroy on the next `apply`.

⚠️ **Never manually edit `.tfstate` files.** Use Terraform commands instead.

### 5.2 Common State Commands
```bash
terraform state list                     # list all resources in state
terraform state show aws_instance.web    # show details of one resource
terraform state mv <old> <new>           # rename a resource in state
terraform state rm <resource>            # remove from state (without destroying)
terraform import aws_instance.web i-123  # bring existing infra under Terraform mgmt
```

### 5.3 Remote State (Team Collaboration)
Local state doesn't work for teams — everyone needs the *same* up-to-date state. Store it remotely instead:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"   # prevents concurrent edits
    encrypt        = true
  }
}
```

Other backend options: Azure Storage, GCS, Terraform Cloud, Consul.

### 5.4 State Locking
When using remote backends with locking (like S3+DynamoDB), Terraform prevents two people from running `apply` at the same time — avoiding corruption.

**Practice Task:** Set up an S3 bucket + DynamoDB table and migrate your local state to a remote backend.

---

## Module 6: Meta-Arguments — Loops & Conditionals

### 6.1 `count`
```hcl
resource "aws_instance" "web" {
  count         = 3
  ami           = "ami-123456"
  instance_type = "t2.micro"

  tags = {
    Name = "web-${count.index}"
  }
}
```

### 6.2 `for_each` (preferred over count for named resources)
```hcl
variable "servers" {
  type = map(string)
  default = {
    web = "t2.micro"
    api = "t2.small"
  }
}

resource "aws_instance" "server" {
  for_each      = var.servers
  ami           = "ami-123456"
  instance_type = each.value

  tags = {
    Name = each.key
  }
}
```

**count vs for_each:**
- `count`: good for identical resources, indexed by number (`0,1,2`). Risky if you remove an item from the middle — causes re-creation of others.
- `for_each`: good for named/unique resources, indexed by string key. Safer for lists that change over time.

### 6.3 Conditional Expressions
```hcl
resource "aws_instance" "web" {
  instance_type = var.environment == "prod" ? "t2.large" : "t2.micro"
}
```

### 6.4 `for` Expressions (transform lists/maps)
```hcl
locals {
  upper_names = [for name in var.names : upper(name)]
  name_lengths = { for name in var.names : name => length(name) }
}
```

**Practice Task:** Use `for_each` to create 3 S3 buckets with different names from a variable map.

---

## Module 7: Modules (Reusable Infrastructure)

### 7.1 Why Modules?
Modules let you package infrastructure into reusable, shareable components — like functions in programming.

### 7.2 Folder Structure
```
modules/
  ec2-instance/
    main.tf
    variables.tf
    outputs.tf
main.tf
variables.tf
outputs.tf
```

### 7.3 Creating a Module
```hcl
# modules/ec2-instance/main.tf
resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type
  tags          = { Name = var.name }
}

# modules/ec2-instance/variables.tf
variable "ami" { type = string }
variable "instance_type" { type = string }
variable "name" { type = string }

# modules/ec2-instance/outputs.tf
output "id" { value = aws_instance.this.id }
output "public_ip" { value = aws_instance.this.public_ip }
```

### 7.4 Using the Module
```hcl
# root main.tf
module "web_server" {
  source        = "./modules/ec2-instance"
  ami           = "ami-123456"
  instance_type = "t2.micro"
  name          = "web"
}

output "web_ip" {
  value = module.web_server.public_ip
}
```

### 7.5 Public Registry Modules
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"
}
```
Browse: registry.terraform.io

**Practice Task:** Turn your EC2 config into a module, then call it twice with different names to create 2 servers.

---

## Module 8: Data Sources

Data sources let you **read** existing infrastructure without managing it.

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
}
```

**Practice Task:** Use a data source to fetch the latest Ubuntu AMI instead of hardcoding one.

---

## Module 9: Provisioners (Use Sparingly)

Provisioners run scripts on resources during creation — but Terraform docs recommend **avoiding them** when possible (use cloud-init / user_data / config management tools instead).

```hcl
resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = "t2.micro"

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y nginx"
    ]
  }
}
```

Better alternative — `user_data`:
```hcl
resource "aws_instance" "web" {
  ami           = "ami-123456"
  instance_type = "t2.micro"
  user_data     = file("install_nginx.sh")
}
```

---

## Module 10: Workspaces (Environment Management)

Workspaces let you manage multiple environments (dev/staging/prod) using the same config with separate state files.

```bash
terraform workspace new dev
terraform workspace new prod
terraform workspace select dev
terraform workspace list
```

```hcl
resource "aws_instance" "web" {
  instance_type = terraform.workspace == "prod" ? "t2.large" : "t2.micro"
}
```

⚠️ Note: Many teams prefer **separate directories/state files per environment** over workspaces for production use, since workspaces share the same backend config and can be error-prone at scale.

---

## Module 11: Functions (Built-in)

Terraform has 100+ built-in functions. Common ones:

```hcl
# String functions
upper("hello")               # "HELLO"
lower("HELLO")                # "hello"
join(",", ["a", "b", "c"])    # "a,b,c"
split(",", "a,b,c")           # ["a", "b", "c"]
substr("hello world", 0, 5)   # "hello"
trim("  hi  ", " ")           # "hi"
replace("hello", "l", "L")    # "heLLo"

# Numeric
max(1, 5, 3)     # 5
min(1, 5, 3)     # 1

# Collection
length(["a","b","c"])       # 3
concat([1,2], [3,4])        # [1,2,3,4]
merge({a=1}, {b=2})         # {a=1, b=2}
lookup({a="x"}, "a", "def") # "x"

# Encoding
jsonencode({key = "value"})
base64encode("hello")

# File
file("script.sh")
templatefile("config.tftpl", { var1 = "value" })
```

Try functions interactively:
```bash
terraform console
> upper("hello")
"HELLO"
```

**Practice Task:** Use `terraform console` to experiment with 5 different functions.

---

## Module 12: Terraform Cloud / Enterprise Basics (Optional but Common in Jobs)

- **Terraform Cloud**: HashiCorp's managed service for remote state, remote runs, and team collaboration.
- Provides: remote state storage, plan/apply in the cloud, policy-as-code (Sentinel/OPA), private module registry.
- Free tier available for small teams.

```hcl
terraform {
  cloud {
    organization = "my-org"
    workspaces {
      name = "my-app-prod"
    }
  }
}
```

---

## Module 13: Best Practices Checklist

- ✅ Use remote state with locking for any team/production work
- ✅ Never commit `.tfstate` or `.tfvars` with secrets to Git
- ✅ Use `terraform fmt` to auto-format code
- ✅ Use `terraform validate` before applying
- ✅ Pin provider versions (`~> 5.0`) to avoid surprise breaking changes
- ✅ Use modules for anything repeated more than once
- ✅ Use `for_each` over `count` for named resources
- ✅ Separate environments (dev/stage/prod) via workspaces or separate state
- ✅ Use a `.gitignore` for `.terraform/`, `*.tfstate`, `*.tfvars` (if sensitive)
- ✅ Tag all resources consistently (Environment, Owner, Project)
- ✅ Review `terraform plan` output carefully before every `apply`
- ✅ Use CI/CD pipelines (GitHub Actions, GitLab CI, Atlantis) to automate plan/apply with approval gates

Sample `.gitignore`:
```
.terraform/
*.tfstate
*.tfstate.backup
*.tfvars
.terraform.lock.hcl
```
(Note: many teams DO commit `.terraform.lock.hcl` for reproducibility — check your team's convention.)

---

## Module 14: Real-World Mini Project

Build a complete 3-tier setup: VPC → EC2 → Security Group → S3 bucket, using modules and variables.

```
project/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── modules/
    ├── vpc/
    ├── ec2/
    └── s3/
```

```hcl
# main.tf
module "vpc" {
  source = "./modules/vpc"
  cidr_block = var.vpc_cidr
}

module "web_server" {
  source     = "./modules/ec2"
  vpc_id     = module.vpc.vpc_id
  subnet_id  = module.vpc.public_subnet_id
  ami        = var.ami_id
}

module "storage" {
  source      = "./modules/s3"
  bucket_name = "${var.project_name}-assets"
}
```

**Practice Task (capstone):** Build this yourself end-to-end. Destroy resources when done to avoid AWS charges.

---

## Module 15: Common Interview Questions

1. What's the difference between Terraform and CloudFormation?
2. What is the purpose of the state file? Why shouldn't it be edited manually?
3. Explain `count` vs `for_each` — when would you use each?
4. What happens if two people run `apply` at the same time without state locking?
5. How do you manage secrets in Terraform? (Answer: avoid hardcoding; use `sensitive = true`, environment variables, or a secrets manager like Vault/AWS Secrets Manager + data sources)
6. What's the difference between a `variable` and a `local`?
7. How do you import existing infrastructure into Terraform?
8. What is a provisioner, and why is it discouraged?
9. Explain the difference between `terraform plan` and `terraform apply`.
10. How do modules help with code reuse?
11. What's the difference between workspaces and separate state files for environments?
12. How does Terraform determine the order to create/destroy resources? (Answer: builds a dependency graph — see `terraform graph`)

---

## Module 16: Certification Path (Optional)

**HashiCorp Certified: Terraform Associate (003)**
- Tests: IaC concepts, Terraform CLI, state, modules, workflow
- Free official study guide: HashiCorp's Terraform Associate certification page
- Good for resumes / job applications
- Format: multiple choice, ~1 hour, remote-proctored

Study approach:
1. Complete this guide + hands-on practice (most important step)
2. Read HashiCorp's official Associate exam objectives
3. Take a practice exam
4. Review weak areas, then schedule the real exam

---

## Quick Reference: Command Cheat Sheet

```bash
terraform init              # initialize working directory
terraform validate           # check syntax
terraform fmt                # auto-format code
terraform plan                # preview changes
terraform apply                # apply changes
terraform apply -auto-approve   # apply without confirmation prompt
terraform destroy                # tear down everything
terraform show                    # show current state in human-readable form
terraform graph                    # visualize dependency graph
terraform output                    # show output values
terraform state list                 # list resources in state
terraform workspace list              # list workspaces
terraform console                      # interactive expression evaluator
terraform taint <resource>              # mark resource for recreation (deprecated, use -replace)
terraform apply -replace=<resource>      # force recreate a specific resource
```

---

## Suggested Learning Timeline

| Days | Focus |
|---|---|
| 1-2 | Modules 1-2: Setup, first project |
| 3-4 | Modules 3-5: Syntax, variables, state |
| 5-6 | Modules 6-8: Loops, modules, data sources |
| 7 | Modules 9-11: Provisioners, workspaces, functions |
| 8 | Module 14: Capstone project |
| 9-10 | Module 15-16: Interview prep + certification study |

---

## Free Resources to Go Deeper
- Official docs: developer.hashicorp.com/terraform
- Terraform Registry (modules & providers): registry.terraform.io
- HashiCorp Learn tutorials (interactive, hands-on labs)
- GitHub: search "terraform examples" for real-world repos

---

*Good luck with your Terraform journey! Practice by actually building and destroying real infrastructure — that's the fastest way to learn.*
