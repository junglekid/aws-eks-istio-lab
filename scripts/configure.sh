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
AWS_AZ_ZONES=$(terraform output aws_az_zones)
AWS_AZ_ZONE_1=$(terraform output -raw aws_az_zone_1)
AWS_AZ_ZONE_2=$(terraform output -raw aws_az_zone_2)
AWS_AZ_ZONE_3=$(terraform output -raw aws_az_zone_3)
BASE_DOMAIN_NAME=$(terraform output -raw base_domain_name)
EKS_CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
EXTERNAL_DNS_DOMAIN_FILTER=$(terraform output -raw domain_filter)
ROUTE_53_ZONE_ID=$(terraform output -raw route53_zone_id)
SA_ALB_IAM_ROLE_ARN=$(terraform output -raw eks_sa_alb_iam_role_arn)
SA_EXTERNAL_DNS_IAM_ROLE_ARN=$(terraform output -raw eks_sa_external_dns_iam_role_arn)
SA_CLUSTER_AUTOSCALER_IAM_ROLE_ARN=$(terraform output -raw eks_sa_cluster_autoscaler_iam_role_arn)
SA_AWS_CERT_MANAGER_IAM_ROLE_ARN=$(terraform output -raw eks_sa_cert_manager_iam_role_arn)
AWS_ACM_PODINFO_ARN=$(terraform output -raw podinfo_acm_certificate_arn)
AWS_ACM_BOOKINFO_ARN=$(terraform output -raw bookinfo_acm_certificate_arn)
AWS_ACM_GRAFANA_ARN=$(terraform output -raw grafana_acm_certificate_arn)
AWS_ACM_KIALI_ARN=$(terraform output -raw kiali_acm_certificate_arn)

# BOOKINFO_GITHUB_URL="https://github.com/junglekid/aws-eks-istio-lab"

echo ""
echo "Configuring Apps managed by FluxCD..."
echo ""

cd ..

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

cp -f ./k8s/templates/infrastructure/configs/letsencrypt.yaml ./k8s/infrastructure/configs/letsencrypt.yaml
replace_in_file 's|ROUTE_53_ZONE_ID|'"$ROUTE_53_ZONE_ID"'|g' ./k8s/infrastructure/configs/letsencrypt.yaml
replace_in_file 's|AWS_REGION|'"$AWS_REGION"'|g' ./k8s/infrastructure/configs/letsencrypt.yaml

cp -f ./k8s/templates/infrastructure/configs/wildcard_cert.yaml ./k8s/infrastructure/configs/wildcard_cert.yaml
replace_in_file 's|BASE_DOMAIN_NAME|'"$BASE_DOMAIN_NAME"'|g' ./k8s/infrastructure/configs/wildcard_cert.yaml

cp -f ./k8s/templates/infrastructure/configs/ebs_sc.yaml ./k8s/infrastructure/configs/ebs_sc.yaml
replace_in_file 's|AWS_AZ_ZONE_1|'"$AWS_AZ_ZONE_1"'|g' ./k8s/infrastructure/configs/ebs_sc.yaml
replace_in_file 's|AWS_AZ_ZONE_2|'"$AWS_AZ_ZONE_2"'|g' ./k8s/infrastructure/configs/ebs_sc.yaml
replace_in_file 's|AWS_AZ_ZONE_3|'"$AWS_AZ_ZONE_3"'|g' ./k8s/infrastructure/configs/ebs_sc.yaml

cp -f ./k8s/templates/infrastructure/apps/kiali/cert_request.yaml ./k8s/infrastructure/apps/kiali/cert_request.yaml
replace_in_file 's|BASE_DOMAIN_NAME|'"$BASE_DOMAIN_NAME"'|g' ./k8s/infrastructure/apps/kiali/cert_request.yaml

cp -f ./k8s/templates/infrastructure/apps/kiali/config.yaml ./k8s/infrastructure/apps/kiali/config.yaml
replace_in_file 's|BASE_DOMAIN_NAME|'"$BASE_DOMAIN_NAME"'|g' ./k8s/infrastructure/apps/kiali/config.yaml
replace_in_file 's|AWS_ACM_KIALI_ARN|'"$AWS_ACM_KIALI_ARN"'|g' ./k8s/infrastructure/apps/kiali/config.yaml

cp -f ./k8s/templates/infrastructure/apps/kiali/release.yaml ./k8s/infrastructure/apps/kiali/release.yaml
replace_in_file 's|BASE_DOMAIN_NAME|'"$BASE_DOMAIN_NAME"'|g' ./k8s/infrastructure/apps/kiali/release.yaml

cp -f ./k8s/templates/monitoring/controllers/kube-prometheus-stack/release.yaml ./k8s/monitoring/controllers/kube-prometheus-stack/release.yaml
replace_in_file 's|BASE_DOMAIN_NAME|'"$BASE_DOMAIN_NAME"'|g' ./k8s/monitoring/controllers/kube-prometheus-stack/release.yaml
replace_in_file 's|AWS_ACM_GRAFANA_ARN|'"$AWS_ACM_GRAFANA_ARN"'|g' ./k8s/monitoring/controllers/kube-prometheus-stack/release.yaml

cp -f ./k8s/templates/apps/base/bookinfo/cert_request.yaml ./k8s/apps/base/bookinfo/cert_request.yaml
replace_in_file 's|BASE_DOMAIN_NAME|'"$BASE_DOMAIN_NAME"'|g' ./k8s/apps/base/bookinfo/cert_request.yaml

cp -f ./k8s/templates/apps/base/bookinfo/config.yaml ./k8s/apps/base/bookinfo/config.yaml
replace_in_file 's|BASE_DOMAIN_NAME|'"$BASE_DOMAIN_NAME"'|g' ./k8s/apps/base/bookinfo/config.yaml
replace_in_file 's|AWS_ACM_BOOKINFO_ARN|'"$AWS_ACM_BOOKINFO_ARN"'|g' ./k8s/apps/base/bookinfo/config.yaml

cp -f ./k8s/templates/apps/base/podinfo/cert_request.yaml ./k8s/apps/base/podinfo/cert_request.yaml
replace_in_file 's|BASE_DOMAIN_NAME|'"$BASE_DOMAIN_NAME"'|g' ./k8s/apps/base/podinfo/cert_request.yaml

cp -f ./k8s/templates/apps/base/podinfo/config.yaml ./k8s/apps/base/podinfo/config.yaml
replace_in_file 's|BASE_DOMAIN_NAME|'"$BASE_DOMAIN_NAME"'|g' ./k8s/apps/base/podinfo/config.yaml
replace_in_file 's|AWS_ACM_PODINFO_ARN|'"$AWS_ACM_PODINFO_ARN"'|g' ./k8s/apps/base/podinfo/config.yaml

echo ""
echo "Pushing changes to Git repository..."
echo ""

git add ./k8s/infrastructure/controllers/aws-load-balancer-controller/release.yaml
git add ./k8s/infrastructure/controllers/external-dns/release.yaml
git add ./k8s/infrastructure/controllers/cluster-autoscaler/release.yaml
git add ./k8s/infrastructure/controllers/cert-manager/release.yaml
git add ./k8s/infrastructure/configs/letsencrypt.yaml
git add ./k8s/infrastructure/configs/wildcard_cert.yaml
git add ./k8s/infrastructure/configs/ebs_sc.yaml

git add ./k8s/infrastructure/apps/kiali/cert_request.yaml
git add ./k8s/infrastructure/apps/kiali/config.yaml
git add ./k8s/infrastructure/apps/kiali/release.yaml
# git add ./k8s/infrastructure/apps/monitoring/cert_request.yaml

git add ./k8s/monitoring/controllers/kube-prometheus-stack/release.yaml

git add ./k8s/apps/base/bookinfo/cert_request.yaml
git add ./k8s/apps/base/bookinfo/config.yaml
git add ./k8s/apps/base/podinfo/cert_request.yaml
git add ./k8s/apps/base/podinfo/config.yaml

# git add ./k8s/apps/base/podinfo.yaml
# git add ./k8s/apps/base/bookinfo.yaml
# git add ./k8s/apps/sources/bookinfo.yaml


# git add ./k8s/apps/base/podinfo/cert_request.yaml
# git add ./k8s/apps/base/bookinfo/cert_request.yaml

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
