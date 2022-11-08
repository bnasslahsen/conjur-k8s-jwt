#!/bin/bash

set -a
source "./../../../.env"
set +a

$KUBE_CLI config set-context --current --namespace="$APP_NAMESPACE"

# SUMMON CONFIGMAP
$KUBE_CLI delete configmap summon-config-sidecar --ignore-not-found=true
envsubst < secrets.template.yml > secrets.yml
$KUBE_CLI create configmap summon-config-sidecar --from-file=secrets.yml
rm secrets.yml

# DEPLOYMENT
envsubst < deployment.yml | $KUBE_CLI replace --force -f -
if ! $KUBE_CLI wait deployment "$APP_SUMMON_SIDECAR" --for condition=Available=True --timeout=90s
  then exit 1
fi

$KUBE_CLI get services "$APP_SUMMON_SIDECAR"
$KUBE_CLI get pods
