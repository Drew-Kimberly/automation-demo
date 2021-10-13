#! /bin/bash

set -e

destroy() {
    terraform -chdir=terraform destroy -var="namespace=$(whoami)"
}

destroy
