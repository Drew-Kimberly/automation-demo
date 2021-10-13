#! /bin/bash

ansible-playbook() {
    docker run \
            -v "${PWD}":/work:ro \
            -v ~/.ansible/roles:/root/.ansible/roles \
            -v ~/.ssh:/root/.ssh:ro \
            --rm ansible-ubuntu-20-04:latest \
            ansible-playbook $1
}

ansible-galaxy() {
    docker run \
            -v "${PWD}":/work:ro \
            -v ~/.ansible/roles:/root/.ansible/roles \
            -v ~/.ssh:/root/.ssh:ro \
            --rm ansible-ubuntu-20-04:latest \
            ansible-galaxy $1
}

deploy() {
    terraform -chdir=terraform apply -var="namespace=$(whoami)"
    docker build -t ansible-ubuntu-20-04:latest -f Dockerfile.ansible .
    ansible-galaxy "install -r ansible/requirements.yml"
    ansible-playbook "--inventory-file=ansible/inventory/hosts.cfg ansible/playbooks/playbook.yml"
}

deploy
