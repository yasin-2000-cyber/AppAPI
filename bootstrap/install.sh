#!/usr/bin/env bash
# Bootstrap script — installs ArgoCD (if needed) and registers all applications.
# Run once after the cluster is up and the repo is pushed to GitHub.
set -euo pipefail

KUBECONFIG_PATH="/home/yasin/.kube/configs/yasin-tobchi.kubeconfig"
export KUBECONFIG="$KUBECONFIG_PATH"

ARGOCD_NAMESPACE="argocd"
ARGOCD_VERSION="7.8.23"   # matches charts/infra/argocd Chart.yaml

# ─── 1. Install ArgoCD if not present ────────────────────────────────────────
if ! kubectl get namespace "$ARGOCD_NAMESPACE" &>/dev/null; then
  echo "==> Installing ArgoCD..."
  helm repo add argo https://argoproj.github.io/argo-helm
  helm repo update
  helm upgrade --install argocd argo/argo-cd \
    --version "$ARGOCD_VERSION" \
    --namespace "$ARGOCD_NAMESPACE" \
    --create-namespace \
    --values ../charts/infra/argocd/values.yaml \
    --wait
else
  echo "==> ArgoCD already installed, skipping."
fi

# ─── 2. Apply ArgoCD project and applications ─────────────────────────────────
echo "==> Applying ArgoCD project..."
kubectl apply -f ../argocd/projects/main-project.yaml

echo "==> Applying ArgoCD applications..."
kubectl apply -f ../argocd/applications/

echo ""
echo "============================================================"
echo "  Bootstrap complete!"
echo ""
echo "  ArgoCD UI   : http://argocd.10.0.19.52.nip.io:30090"
echo "  Grafana     : http://grafana.10.0.19.52.nip.io:30090"
echo "  Prometheus  : http://prometheus.10.0.19.52.nip.io:30090"
echo "  App API     : http://app-api.10.0.19.52.nip.io:30090"
echo ""
echo "  ArgoCD initial admin password:"
echo "    kubectl -n argocd get secret argocd-initial-admin-secret \\"
echo "      -o jsonpath='{.data.password}' | base64 -d"
echo "============================================================"
