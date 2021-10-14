# Automation Demo

## Requirements
- [Terraform (v1.0.x)](https://releases.hashicorp.com/terraform/1.0.2/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Docker](https://docs.docker.com/install/)
- [Azure Subscription w/ AAD Tenant](https://azure.microsoft.com/en-us/free)
- [SSH Key Pair](https://git-scm.com/book/en/v2/Git-on-the-Server-Generating-Your-SSH-Public-Key)


## Usage

### Prerequisites

1. Retrieve an Access Token with both Read and Write scopes for your DigitalOcean account, ([docs](https://docs.digitalocean.com/reference/api/create-personal-access-token/)).
2. In your terminal, run (assuming OSx or Linux):
```bash
$ export TF_VAR_digitalocean_access_token={{ENTER_ACCESS_TOKEN_HERE}}
```
3. In your terminal, export an environment variable set to the absolute path to the SSH public key on your machine:
```bash
# Example value: /Users/foo/.ssh/id_rsa.pub
$ export TF_VAR_ssh_pub_key_path={{ABSOLUTE_PUB_KEY_PATH}}
```
4. Sign in to your Azure account via the Azure CLI:
```bash
$ az login
```
5. Using either Azure CLI or Azure Portal, retrieve your Azure Subscription ID and then run the following:
```bash
$ export ARM_SUBSCRIPTION_ID={{AZURE_SUBSCRIPTION_ID}}
```
6. In your terminal, export an environment variable set to your AAD tenant domain name:
```bash
# Example value: foo.onmicrosoft.com
$ export TF_VAR_aad_domain_name={{AAD_DOMAIN}}
```

### Deploy Script
After ensuring you have completed all prereqs, you can both provision and configure infrastructure with a single script by running:
```bash
$ bash deploy.sh
```
_NOTE - this will default to use `$(whoami)` as your infrastructure namespace!_

### Destroy Script
After ensuring you have completed all prereqs, you can de-provision all resources created with `deploy.sh` by running:
```bash
$ bash destroy.sh
```
_NOTE - this will default to use `$(whoami)` as your infrastructure namespace!_

### Provisioning Infrastructure

1. Initialize the Terraform config:
```bash
$ terraform -chdir=terraform init
```
2. View the infrastructure provisioning plan output by Terraform:
```bash
# Note that we use evaluation of $(whoami) here as the namespace. This can be any arbitrary string value, i.e. "foo".
$ terraform -chdir=terraform plan -var="namespace=$(whoami)"
```
3. Provision our infrastructure with Terraform:
```bash
# Note that we use evaluation of $(whoami) here as the namespace. This can be any arbitrary string value, i.e. "foo".
$ terraform -chdir=terraform apply -var="namespace=$(whoami)"
```

### Configuring the Ubuntu VM

#### Setup Ansible
We'll use Docker to run Ansible. For this demo, your local machine will act as the Control Node. In general, it's best practice for an automation system such as Github Actions or Jenkins to act as the Control Node which applies configuration changes via GitOps.

1. Build the docker image we'll use to run Ansible:
```bash
$ docker build -t ansible-ubuntu-20-04:latest -f Dockerfile.ansible .
```
2. Create aliases for `ansible`, `ansible-playbook`, and `ansible-galaxy` that delegates to a `docker run...` command:
```bash
$ alias ansible='docker run -v "${PWD}":/work:ro --rm ansible-ubuntu-20-04:latest ansible'

$ alias ansible-playbook='docker run -v "${PWD}":/work:ro -v ~/.ansible/roles:/root/.ansible/roles -v ~/.ssh:/root/.ssh:ro --rm ansible-ubuntu-20-04:latest ansible-playbook'

$ alias ansible-galaxy='docker run -v "${PWD}":/work:ro -v ~/.ansible/roles:/root/.ansible/roles -v ~/.ssh:/root/.ssh:ro --rm ansible-ubuntu-20-04:latest ansible-galaxy'
```
3. Install required Ansible Galaxy roles:
```bash
$ ansible-galaxy install -r ansible/requirements.yml
```

#### Run Ansible Playbook
1. Invoke our Ansible playbook to configure the Ubuntu VM by providing the playbook definition and our auto-generated Hosts inventory:
```bash
$ ansible-playbook --inventory-file=ansible/inventory/hosts.cfg ansible/playbooks/playbook.yml
```
