#!/usr/bin/env bash

function replace_in_file() {
    if [ "$(uname)" == "Darwin" ]; then
        # Do something under Mac OS X platform
        sed -i '' -e "$1" "$2"
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        sed -i -e "$1" "$2"
    fi
}

echo "Gathering AWS Resources and Names necessary to run the Kubernetes Applications and Services deployed by Flux from Terraform Output..."
echo "Hang on..."
echo "This can take between 30 to 90 seconds..."

cd ../terraform
AWS_REGION=$(terraform output -raw aws_region)
# BASE_DOMAIN_NAME=$(terraform output -raw base_domain_name)
EKS_CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
EXTERNAL_DNS_DOMAIN_FILTER=$(terraform output -raw domain_filter)
SA_ALB_IAM_ROLE_ARN=$(terraform output -raw eks_sa_alb_iam_role_arn)
SA_EXTERNAL_DNS_IAM_ROLE_ARN=$(terraform output -raw eks_sa_external_dns_iam_role_arn)
SA_CLUSTER_AUTOSCALER_IAM_ROLE_ARN=$(terraform output -raw eks_sa_cluster_autoscaler_iam_role_arn)
SA_AWS_CERT_MANAGER_IAM_ROLE_ARN=$(terraform output -raw eks_sa_cert_manager_iam_role_arn)
# AWS_KIALI_DOMAIN_NAME=$(terraform output -raw kiali_domain_name)
# AWS_PODINFO_DOMAIN_NAME=$(terraform output -raw podinfo_domain_name)
# AWS_GRAFANA_DOMAIN_NAME=$(terraform output -raw grafana_domain_name)
# AWS_BOOK_INFO_DOMAIN_NAME=$(terraform output -raw bookinfo_domain_name)
# BOOKINFO_GITHUB_URL="https://github.com/junglekid/aws-eks-istio-lab"

echo ""
echo "Configuring Apps managed by FluxCD..."
echo ""

cd ..
# cp -f ./k8s/templates/apps/base/podinfo.yaml ./k8s/apps/base/podinfo.yaml
# replace_in_file 's|AWS_PODINFO_DOMAIN_NAME|'"$AWS_PODINFO_DOMAIN_NAME"'|g' ./k8s/apps/base/podinfo.yaml
# replace_in_file 's|AWS_ACM_PODINFO_ARN|'"$AWS_ACM_PODINFO_ARN"'|g' ./k8s/apps/base/podinfo.yaml

# cp -f ./k8s/templates/apps/sources/bookinfo.yaml ./k8s/apps/sources/bookinfo.yaml
# replace_in_file 's|REACT_APP_GITHUB_URL|'"$BOOKINFO_GITHUB_URL"'|g' ./k8s/apps/sources/bookinfo.yaml

cp -f ./k8s/templates/infrastructure/controllers/aws-load-balancer-controller/release.yaml ./k8s/infrastructure/controllers/aws-load-balancer-controller/release.yaml
replace_in_file 's|SA_ALB_IAM_ROLE_ARN|'"$SA_ALB_IAM_ROLE_ARN"'|g' ./k8s/infrastructure/controllers/aws-load-balancer-controller/release.yaml
replace_in_file 's|AWS_REGION|'"$AWS_REGION"'|g' ./k8s/infrastructure/controllers/aws-load-balancer-controller/release.yaml
replace_in_file 's|EKS_CLUSTER_NAME|'"$EKS_CLUSTER_NAME"'|g' ./k8s/infrastructure/controllers/aws-load-balancer-controller/release.yaml

cp -f ./k8s/templates/infrastructure/controllers/external-dns/release.yaml ./k8s/infrastructure/controllers/external-dns/release.yaml
replace_in_file 's|EXTERNAL_DNS_DOMAIN_FILTER|'"$EXTERNAL_DNS_DOMAIN_FILTER"'|g' ./k8s/infrastructure/controllers/external-dns/release.yaml
replace_in_file 's|SA_EXTERNAL_DNS_IAM_ROLE_ARN|'"$SA_EXTERNAL_DNS_IAM_ROLE_ARN"'|g' ./k8s/infrastructure/controllers/external-dns/release.yaml
replace_in_file 's|AWS_REGION|'"$AWS_REGION"'|g' ./k8s/infrastructure/controllers/external-dns/release.yaml
replace_in_file 's|EKS_CLUSTER_NAME|'"$EKS_CLUSTER_NAME"'|g' ./k8s/infrastructure/controllers/external-dns/release.yaml

cp -f ./k8s/templates/infrastructure/controllers/cluster-autoscaler/release.yaml ./k8s/infrastructure/controllers/cluster-autoscaler/release.yaml
replace_in_file 's|SA_CLUSTER_AUTOSCALER_IAM_ROLE_ARN|'"$SA_CLUSTER_AUTOSCALER_IAM_ROLE_ARN"'|g' ./k8s/infrastructure/controllers/cluster-autoscaler/release.yaml
replace_in_file 's|AWS_REGION|'"$AWS_REGION"'|g' ./k8s/infrastructure/controllers/cluster-autoscaler/release.yaml
replace_in_file 's|EKS_CLUSTER_NAME|'"$EKS_CLUSTER_NAME"'|g' ./k8s/infrastructure/controllers/cluster-autoscaler/release.yaml

cp -f ./k8s/templates/infrastructure/controllers/cert-manager/release.yaml ./k8s/infrastructure/controllers/cert-manager/release.yaml
replace_in_file 's|SA_AWS_CERT_MANAGER_IAM_ROLE_ARN|'"$SA_AWS_CERT_MANAGER_IAM_ROLE_ARN"'|g' ./k8s/infrastructure/controllers/cert-manager/release.yaml

echo ""
echo "Pushing changes to Git repository..."
echo ""

# git add ./k8s/apps/base/podinfo.yaml
# git add ./k8s/apps/base/bookinfo.yaml
# git add ./k8s/apps/sources/bookinfo.yaml
git add ./k8s/infrastructure/controllers/aws-load-balancer-controller/release.yaml
git add ./k8s/infrastructure/controllers/external-dns/release.yaml
git add ./k8s/infrastructure/controllers/cluster-autoscaler/release.yaml
git add ./k8s/infrastructure/controllers/cert-manager/release.yaml
# git add ./k8s/monitoring/configs/dashboards/istio/istio-extension-dashboard.json
# git add ./k8s/monitoring/configs/dashboards/istio/istio-mesh-dashboard.json
# git add ./k8s/monitoring/configs/dashboards/istio/istio-performance-dashboard.json
# git add ./k8s/monitoring/configs/dashboards/istio/istio-service-dashboard.json
# git add ./k8s/monitoring/configs/dashboards/istio/istio-workload-dashboard.json
# git add ./k8s/monitoring/configs/dashboards/istio/pilot-dashboard.json
# git commit -m "Updating Apps"
# git push &> /dev/null

# echo ""
# echo "Finished configuring Apps managed by FluxCD..."
