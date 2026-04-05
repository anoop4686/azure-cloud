#!/bin/bash

# Variables - replace these with your details
RESOURCE_GROUP="storage-account"
STORAGE_ACCOUNT="mydatastore96"
CONTAINER_NAME="data-container"


# Get storage account key
STORAGE_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT --query "[0].value" -o tsv)

# List all blobs with their access tier
echo "Fetching blob list with access tiers..."

blobs=$(az storage blob list \
  --account-name "$STORAGE_ACCOUNT" \
  --account-key "$STORAGE_KEY" \
  --container-name "$CONTAINER_NAME" \
  --query "[].{name:name, tier:properties.accessTier}" \
  -o json)

# Loop through each blob
echo "$blobs" | jq -c '.[]' | while read -r blob; do
  name=$(echo "$blob" | jq -r '.name')
  tier=$(echo "$blob" | jq -r '.tier')

  # Skip blobs already in Hot or Archive
  if [[ "$tier" == "Hot" ]]; then
    echo "Skipping blob '$name' (already in Hot tier)"
    continue
  elif [[ "$tier" == "Archive" ]]; then
    echo "Skipping blob '$name' (in Archive tier)"
    continue
  fi

  # Change blob to Hot tier
  echo "Changing tier to Hot for blob: $name (current tier: $tier)"
  az storage blob set-tier \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$STORAGE_KEY" \
    --container-name "$CONTAINER_NAME" \
    --name "$name" \
    --tier Hot \
    --only-show-errors
done

echo "Done processing eligible blobs."