#!/usr/bin/env bash
# Export all Sealed Secrets controller keys from the cluster into bootstrap/sealed-secrets-keys.yaml.
#
# The file is encrypted by transcrypt (see .gitattributes) and is used by bootstrap.tf to restore
# the keys before the sealed-secrets controller starts (bootstrap / disaster recovery).
# All keys are exported, because older SealedSecrets may have been sealed with an older key.
#
# Run this again whenever a new key was created (key renewal is disabled via keyrenewperiod: 0
# in argocd-apps/charts/sealed-secrets/values.yaml, so this should rarely be necessary).

set -euo pipefail

cd "$(dirname "$0")/.."

out="bootstrap/sealed-secrets-keys.yaml"

if [ "$(git check-attr filter -- "$out" | awk -F': ' '{print $3}')" != "crypt" ]; then
  echo "ERROR: $out is not covered by a transcrypt rule in .gitattributes, refusing to export keys" >&2
  exit 1
fi

kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o json \
  | jq '{apiVersion: "v1", kind: "List", items: [.items[] | {
      apiVersion: "v1",
      kind: "Secret",
      type: .type,
      metadata: {
        name: .metadata.name,
        namespace: .metadata.namespace,
        labels: .metadata.labels
      },
      data: .data
    }] | sort_by(.metadata.name)}' \
  | yq -P '.' > "$out"

echo "Exported $(yq '.items | length' "$out") key(s) to $out"
