#!/bin/bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" # The directory of this script

export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/\(.*\)[a-z]/\1/')

# Packer Vars
export PKR_VAR_aws_region="$AWS_DEFAULT_REGION"
if [[ -f "$SCRIPTDIR/../bastion-ami/manifest.json" ]]; then
    export PKR_VAR_bastion_ubuntu18_ami="$(jq -r '.builds[] | select(.name == "ubuntu18-ami") | .artifact_id' $SCRIPTDIR/../bastion-ami/manifest.json | tail -1 | cut -d ":" -f2)"
    echo "Found bastion_ubuntu18_ami in manifest: PKR_VAR_bastion_ubuntu18_ami=$PKR_VAR_bastion_ubuntu18_ami"
fi

export PACKER_LOG=1
export PACKER_LOG_PATH="$SCRIPTDIR/packerlog.log"

export PKR_VAR_manifest_path="$SCRIPTDIR/manifest.json"
mkdir -p $SCRIPTDIR/ansible/collections/ansible_collections
rm -f $PKR_VAR_manifest_path
packer build "$@" $SCRIPTDIR/general-host.pkr.hcl
