Set env vars

```bash
RESOURCE_GROUP_NAME=
LOCATION=
SP_NAME=
```

Initialize

```bash
terraform -chdir=setup init
terraform -chdir=cluster init
```

Setup

```bash
OPENSHIFT_RP_OBJECT_ID=$(az ad sp list --display-name "Azure Red Hat OpenShift RP" --query '[0].id' -o tsv)
terraform -chdir=setup plan -out setup.plan -var aro_resource_provider_id=$OPENSHIFT_RP_OBJECT_ID -var resource_group_name=$RESOURCE_GROUP_NAME -var location=$LOCATION
```

Yank subnets

```bash
CONTROL_SUBNET_ID=$(terraform output -raw control-subnet)
COMPUTE_SUBNET_ID=$(terraform output -raw compute-subnet)
```

Create SP with Contributor Role

```bash
AZR_SUB_ID=$(az account show --query id -o tsv)
AZR_SP=$(az ad sp create-for-rbac -n $SP_NAME --role contributor --output json \
  --scopes /subscriptions/${AZR_SUB_ID}/resourceGroups/${RESOURCE_GROUP_NAME)
AZR_SP_APP_ID=$(echo $AZR_SP | jq -r '.appId')
AZR_SP_PASSWORD=$(echo $AZR_SP | jq -r '.password')       
```

Create cluster

```bash
terraform -chdir=cluster plan -out cluster.plan -var location=$LOCATION -var resource_group_name=$RESOURCE_GROUP_NAME -var master_subnet_id=$CONTROL_SUBNET_ID -var worker_subnet_id=$COMPUTE_SUBNET_ID -var client_id=$AZR_SP_APP_ID -var client_secret=$AZR_SP_PASSWORD
```
