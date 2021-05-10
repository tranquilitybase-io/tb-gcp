
  
#!/usr/bin/env bash
 
## This script create necessary firewall rule based on validating and mutating webhooks for private GKE clusters.
## Usage : ./add-gcp-fw-for-istio-webhook.sh [YOUR_GKE_CLUSTER_NAME]

export HTTPS_PROXY="localhost:3128"

set -e
 #Retrieve project ID.. these will change when we have all our tb folders.
PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)
TB_DISCRIMINATOR="${PROJECT_ID: -8}"
CLUSTER="tb-mgmt-gke"
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

source_ranges=$(gcloud container clusters describe --region=europe-west1 "$CLUSTER" --format="value(privateClusterConfig.masterIpv4CidrBlock)" --project="$PROJECT_ID")
source_tags=$(gcloud compute instances list --filter="tags.items~^gke-$CLUSTER" --limit=1 --format="value(tags.items[0])" --project="$PROJECT_ID")
tb=$(gcloud container clusters describe --region=europe-west1 "$CLUSTER" --format="value(network)" --project="$PROJECT_ID")
gcloud compute firewall-rules  create "${CLUSTER}"-webhooks \
    --action ALLOW --direction INGRESS \
    --source-ranges "$source_ranges" \
    --target-tags "$source_tags" \
    --network "$tb" \
    --rules "$rules" \
    --project "$PROJECT_ID"
 
