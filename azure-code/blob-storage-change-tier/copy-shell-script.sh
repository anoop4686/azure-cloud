#!/bin/bash

# Variables
SRC_ACCOUNT="mydatastore96"
SRC_KEY="yz64kBEBgDvh75bvEIa4FCvrLpOgrTiLr"
SRC_CONTAINER="sources"

DEST_ACCOUNT="mydatastore96"
DEST_KEY="yz64kBEBgDvh75bvEIa4FCvrLpOgrTiLr"
DEST_CONTAINER="destination"

# List all blobs from source container
blobs=$(az storage blob list \
    --account-name "$SRC_ACCOUNT" \
    --account-key "$SRC_KEY" \
    --container-name "$SRC_CONTAINER" \
    --query "[].name" -o tsv)

for blob in $blobs; do
    if [ -n "$blob" ]; then  # ensure blob name is not empty
        echo "Copying: $blob"

        # URL encode blob name (handles special characters)
        encoded_blob=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$blob'''))")

        # Construct source URI
        SRC_URL="https://${SRC_ACCOUNT}.blob.core.windows.net/${SRC_CONTAINER}/${encoded_blob}"

        az storage blob copy start \
            --destination-blob "$blob" \
            --destination-container "$DEST_CONTAINER" \
            --account-name "$DEST_ACCOUNT" \
            --account-key "$DEST_KEY" \
            --source-uri "$SRC_URL"
    fi
done
