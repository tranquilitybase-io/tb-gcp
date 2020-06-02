#!/usr/bin/env bash
 
## This script create necessary firewall rule based on validating and mutating webhooks for private GKE clusters.
## Usage : ./add-gcp-fw-for-istio-webhook.sh [YOUR_GKE_CLUSTER_NAME]

export HTTPS_PROXY="localhost:3128"

set -e
 #Retrieve project ID
PROJECT_ID=$(curl -s "http://metadata.google.internal/computeMetadata/v1/project/project-id" -H "Metadata-Flavor: Google")
TB_DISCRIMINATOR="${PROJECT_ID: -8}"
SHARED_EC_PROJECT=shared-ec-${TB_DISCRIMINATOR}
SHARED_NETWORKING_PROJECT=shared-networking-${TB_DISCRIMINATOR}
CLUSTER="gke-ec"
validationg_svcs=$(kubectl get validatingwebhookconfigurations -ojson | \
    jq -c '.items[].webhooks[].clientConfig.service | del(.path) | select(. != null)')
mutating_svcs=$(kubectl get mutatingwebhookconfigurations -ojson | \
    jq -c '.items[].webhooks[].clientConfig.service | del(.path) | select(. != null)')
webhook_svcs="${validationg_svcs}
${mutating_svcs}"
rule_arr=()
while IFS= read -r line
do
    svc_ns=$(echo "${line}" | jq -r '.namespace')
    svc_name=$(echo "${line}" | jq -r '.name')
    target=$(kubectl get svc -n "${svc_ns}" "${svc_name}" -ojson | \
     jq ".spec.ports[] | select( .port == 443) | .targetPort")
    if [[ $target -eq 10250 ]] || [[ $target -eq 443 ]] || [ -z "$target" ]; then
        continue
    fi
    rule_arr+=("tcp:${target}")
done < <(printf '%s\n' "$webhook_svcs")
 
rules=$(printf ",%s" "${rule_arr[@]}")
rules=${rules:1}

# Unset so we can make gcloud commands
unset HTTPS_PROXY

source_ranges=$(gcloud container clusters describe --region=europe-west2 "$CLUSTER" --format="value(privateClusterConfig.masterIpv4CidrBlock)" --project="$SHARED_EC_PROJECT")
source_tags=$(gcloud compute instances list --filter="tags.items~^gke-"$CLUSTER"" --limit=1 --format="value(tags.items[0])" --project="$SHARED_EC_PROJECT")
gke_network=$(gcloud container clusters describe --region=europe-west2 "$CLUSTER" --format="value(network)" --project="$SHARED_EC_PROJECT")
gcloud compute firewall-rules  create "${CLUSTER}"-webhooks \
    --action ALLOW --direction INGRESS \
    --source-ranges "$source_ranges" \
    --target-tags "$source_tags" \
    --network "$gke_network" \
    --rules "$rules" \
    --project "$SHARED_NETWORKING_PROJECT"
 
