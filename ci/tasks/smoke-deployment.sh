#!/usr/bin/env bash

set -e

state_path() { bosh-cli int director-state/director.yml --path="$1" ; }

function get_bosh_environment {
  if [[ -z $(state_path /instance_groups/name=bosh/networks/name=public/static_ips/0 2>/dev/null) ]]; then
    state_path /instance_groups/name=bosh/networks/name=default/static_ips/0 2>/dev/null
  else
    state_path /instance_groups/name=bosh/networks/name=public/static_ips/0 2>/dev/null
  fi
}

mv bosh-cli/alpha-bosh-cli-* /usr/local/bin/bosh-cli
chmod +x /usr/local/bin/bosh-cli

export BOSH_ENVIRONMENT=$(get_bosh_environment)
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=$(bosh-cli int director-state/director-creds.yml --path /admin_password)
export BOSH_CA_CERT=$(bosh-cli int director-state/director-creds.yml --path /director_ssl/ca)

bosh-cli upload-stemcell stemcell/*.tgz -n
bosh-cli -d zookeeper --recreate deploy zookeeper-release/manifests/zookeeper.yml -n
