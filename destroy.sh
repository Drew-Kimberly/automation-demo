#! /bin/bash

destroy() {
    terraform -chdir=terraform destroy -var="namespace=$(whoami)"
}

destroy
