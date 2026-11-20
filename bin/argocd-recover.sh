#!/usr/bin/env bash
# Re-apply Argo CD from the local argocd-apps checkout, bypassing Argo CD itself.
#
# Use this when Argo CD manages itself (argocd-apps: helm-argocd) and an update broke it, so that it
# can no longer sync its own fix:
#   1. revert the faulty change in argocd-apps (git revert + push), then pull the checkout
#   2. run this script; it renders the argo-cd chart with the version, plugin tag and values from the
#      checkout and applies it server-side with Argo CD's field manager
#   3. Argo CD takes over again on its next sync
#
# The argocd-apps checkout must be decrypted with transcrypt (charts/argocd/values-private.yaml).

set -euo pipefail

cd "$(dirname "$0")/.."

repo="${ARGOCD_APPS_REPO:-../argocd-apps}"
namespace="argocd"

version=$(yq '.argocd.version' "$repo/apps/values.yaml")
plugin_tag=$(yq '.argocd.transcryptPlugin.version' "$repo/apps/values.yaml")

if head -c 10 "$repo/charts/argocd/values-private.yaml" | grep -q '^U2FsdGVkX1'; then
  echo "ERROR: $repo/charts/argocd/values-private.yaml is still encrypted, configure transcrypt in $repo first" >&2
  exit 1
fi

echo "argocd-apps checkout: $(git -C "$repo" rev-parse --abbrev-ref HEAD) @ $(git -C "$repo" rev-parse --short HEAD)"
echo "argo-cd chart:        $version"
echo "repo-server image:    ghcr.io/steled/argocd-transcrypt-plugin:$plugin_tag"

manifests=$(mktemp)
trap 'rm -f "$manifests"' EXIT

helm template argocd argo-cd --no-hooks \
  --repo https://argoproj.github.io/argo-helm \
  --version "$version" \
  --namespace "$namespace" \
  -f "$repo/charts/argocd/values.yaml" \
  -f "$repo/charts/argocd/values-private.yaml" \
  --set "repoServer.image.tag=$plugin_tag" \
  > "$manifests"

echo
echo "Changes compared to the cluster:"
kubectl diff --server-side --force-conflicts --field-manager=argocd-controller -n "$namespace" -f "$manifests" \
  | grep -E '^[-+][^-+]' | grep -vE '^[-+]\s+(generation|resourceVersion|uid|creationTimestamp):' || true

echo
read -r -p "Apply these manifests? [y/N] " answer
[ "$answer" = "y" ] || { echo "Aborted"; exit 1; }

kubectl apply --server-side --force-conflicts --field-manager=argocd-controller -n "$namespace" -f "$manifests"
