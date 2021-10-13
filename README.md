# Automation Demo

## Requirements
- [Terraform (v1.0.x)](https://releases.hashicorp.com/terraform/1.0.2/)
- [Docker](https://docs.docker.com/install/)
- [DigitalOcean Account](https://cloud.digitalocean.com/)
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

1. View the infrastructure provisioning plan output by Terraform:
```bash
# Note that we use evaluation of $(whoami) here as the namespace. This can be any arbitrary string value, i.e. "foo".
$ terraform -chdir=terraform plan -var="namespace=$(whoami)"
```
2. Provision our infrastructure with Terraform:
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
