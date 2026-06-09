#!/bin/bash

SP_NAME="eschool-sp"
ENV_FILE=".env"

az login

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Subscription ID: ${SUBSCRIPTION_ID}"


echo "Checking if Service Principal exists"
if ! az ad sp list --display-name "${SP_NAME}" --query "[0].id" -o tsv | grep -q .; then
    echo "Creating Service Principal: ${SP_NAME}"
    SP_CREDENTIALS=$(az ad sp create-for-rbac \
    --name "${SP_NAME}" \
    --role Contributor \
    --scopes "/subscriptions/${SUBSCRIPTION_ID}"
    )

    ARM_CLIENT_ID=$(echo ${SP_CREDENTIALS} | jq -r '.appId')
    ARM_CLIENT_SECRET=$(echo ${SP_CREDENTIALS} | jq -r '.password')
    ARM_TENANT_ID=$(echo ${SP_CREDENTIALS} | jq -r '.tenant')

    cat > "${ENV_FILE}" <<EOF
ARM_CLIENT_ID=${ARM_CLIENT_ID}
ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET}
ARM_TENANT_ID=${ARM_TENANT_ID}
EOF
    echo "Credentials saved to ${ENV_FILE}"

else
    echo "Service Principal already exists, skipping"
fi